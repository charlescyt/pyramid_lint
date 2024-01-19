import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ExtractVariableToParameter extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addVariableDeclaration((node) {
      if (!node.sourceRange.covers(target)) return;

      final paramList = _getParameterList(node);
      if (paramList == null) return;

      final variableName = node.name.lexeme;
      final paramAlreadyExists = paramList.parameters
              .firstWhereOrNull((e) => e.name?.lexeme == variableName) !=
          null;
      if (paramAlreadyExists) return;

      final varDeclarationStatement =
          node.thisOrAncestorOfType<VariableDeclarationStatement>()!;

      final positionalParamChangeBuilder = reporter.createChangeBuilder(
        message: 'Extract variable as parameter',
        priority: 79,
      );

      final namedParamChangeBuilder = reporter.createChangeBuilder(
        message: 'Extract variable as named parameter',
        priority: 80,
      );

      final variableTypeName =
          node.declaredElement!.type.getDisplayString(withNullability: true);
      final namedParams = paramList.parameters.where((e) => e.isNamed);
      final positionalParams =
          paramList.parameters.where((e) => e.isPositional);

      positionalParamChangeBuilder.addDartFileEdit((builder) {
        int offset;
        var addPreceedingComma = false;
        var addSucceedingComma = false;

        if (positionalParams.isEmpty) {
          offset = paramList.leftParenthesis.end;
          addSucceedingComma = namedParams.isNotEmpty;
        } else {
          addPreceedingComma = true;
          offset = positionalParams.last.endToken.next!.offset;
        }

        builder.addInsertion(offset, (builder) {
          if (addPreceedingComma) builder.write(',');
          builder.write('$variableTypeName $variableName');
          if (addSucceedingComma) builder.write(',');
        });

        _deleteOriginalVariable(varDeclarationStatement, builder, node);
      });

      namedParamChangeBuilder.addDartFileEdit((builder) {
        int offset;
        var addBracketPreceedingComma = false;
        var addEnclosingBrackets = false;
        var addPreceedingComma = false;

        if (namedParams.isEmpty && positionalParams.isEmpty) {
          addEnclosingBrackets = true;
          offset = paramList.leftParenthesis.end;
        } else if (namedParams.isEmpty && positionalParams.isNotEmpty) {
          final param = positionalParams.last;
          addEnclosingBrackets = true;
          addBracketPreceedingComma =
              param.endToken.next!.type != TokenType.COMMA;
          offset = param.end;
        } else {
          final param = namedParams.last;
          addPreceedingComma = param.endToken.next!.type != TokenType.COMMA;
          offset = param.end;
        }

        builder.addInsertion(offset, (builder) {
          if (addBracketPreceedingComma) builder.write(',');
          if (addEnclosingBrackets) builder.write('{');
          if (addPreceedingComma) builder.write(',');
          if (!variableTypeName.endsWith('?')) builder.write('required ');
          builder.write('$variableTypeName $variableName');
          if (addEnclosingBrackets) builder.write('}');
        });

        _deleteOriginalVariable(varDeclarationStatement, builder, node);
      });
    });
  }

  FormalParameterList? _getParameterList(VariableDeclaration node) {
    final elem = node.declaredElement;
    if (elem == null || elem is! LocalVariableElement) return null;

    final functionDeclaration = node.thisOrAncestorMatching(
      (e) => e is MethodDeclaration || e is FunctionDeclaration,
    );

    return switch (functionDeclaration) {
      MethodDeclaration() => functionDeclaration.parameters,
      FunctionDeclaration() =>
        functionDeclaration.functionExpression.parameters,
      _ => null
    };
  }

  void _deleteOriginalVariable(
    VariableDeclarationStatement varDeclarationStatement,
    DartFileEditBuilder builder,
    VariableDeclaration node,
  ) {
    final variables = varDeclarationStatement.variables.variables;

    // Delete the entire expression if there's only one variable
    if (variables.length == 1) {
      builder.addDeletion(varDeclarationStatement.sourceRange);
    } else {
      // We need to also delete the comma in case of multiple variables.
      SourceRange range;

      // If the next token is "comma" means the variable is in the middle or
      // at the begining.
      if (node.endToken.next?.type == TokenType.COMMA) {
        range = node.sourceRange.getUnion(node.endToken.next!.sourceRange);
      } else {
        // Variable is at the last.
        range =
            node.sourceRange.getUnion(node.beginToken.previous!.sourceRange);
      }

      builder.addDeletion(range);
    }
  }
}
