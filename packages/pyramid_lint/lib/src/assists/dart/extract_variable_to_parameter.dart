import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
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

      final paramAlreadyExists =
          paramList.parameters.any((e) => e.name?.lexeme == variableName);
      if (paramAlreadyExists) return;

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
        var addPrecedingComma = false;
        var addSucceedingComma = false;

        if (positionalParams.isEmpty) {
          offset = paramList.leftParenthesis.end;
          addSucceedingComma = namedParams.isNotEmpty;
        } else {
          addPrecedingComma = true;
          offset = positionalParams.last.endToken.next!.offset;
        }

        builder.addInsertion(offset, (builder) {
          if (addPrecedingComma) builder.write(',');
          builder.write('$variableTypeName $variableName');
          if (addSucceedingComma) builder.write(',');
        });

        _deleteOriginalVariable(node, builder);
      });

      namedParamChangeBuilder.addDartFileEdit((builder) {
        int offset;
        bool addBracketPrecedingComma;
        bool addEnclosingBrackets;
        bool addPrecedingComma;

        if (namedParams.isEmpty && positionalParams.isEmpty) {
          offset = paramList.leftParenthesis.end;
          addBracketPrecedingComma = false;
          addEnclosingBrackets = true;
          addPrecedingComma = false;
        } else if (namedParams.isEmpty && positionalParams.isNotEmpty) {
          final param = positionalParams.last;

          offset = param.end;
          addBracketPrecedingComma =
              param.endToken.next!.type != TokenType.COMMA;
          addEnclosingBrackets = true;
          addPrecedingComma = false;
        } else {
          final param = namedParams.last;

          offset = param.end;
          addBracketPrecedingComma = false;
          addEnclosingBrackets = false;
          addPrecedingComma = param.endToken.next!.type != TokenType.COMMA;
        }

        builder.addInsertion(offset, (builder) {
          if (addBracketPrecedingComma) builder.write(',');
          if (addEnclosingBrackets) builder.write('{');
          if (addPrecedingComma) builder.write(',');
          if (!variableTypeName.endsWith('?')) builder.write('required ');
          builder.write('$variableTypeName $variableName');
          if (addEnclosingBrackets) builder.write('}');
        });

        _deleteOriginalVariable(node, builder);
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
    VariableDeclaration node,
    DartFileEditBuilder builder,
  ) {
    final varDeclarationStatement =
        node.thisOrAncestorOfType<VariableDeclarationStatement>()!;

    final variables = varDeclarationStatement.variables.variables;

    final rangeFactory = RangeFactory();

    // Delete the entire expression if there's only one variable
    if (variables.length == 1) {
      final deletionRange = rangeFactory.deletionRange(varDeclarationStatement);
      builder.addDeletion(deletionRange);
    } else {
      // We need to also delete the comma in case of multiple variables.
      SourceRange range;

      // If the next token is "comma" means the variable is in the middle or
      // at the begining.
      final nextToken = node.endToken.next!;
      if (nextToken.type == TokenType.COMMA) {
        range = rangeFactory.startEnd(node, nextToken);
      } else {
        // Variable is at the last.
        final previousToken = node.beginToken.previous!;
        range = rangeFactory.startEnd(previousToken, node);
      }

      builder.addDeletion(range);
    }
  }
}
