import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
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

      final elem = node.declaredElement;
      if (elem == null || elem is! LocalVariableElement) return;

      final functionDeclaration = node.thisOrAncestorMatching(
        (e) => e is MethodDeclaration || e is FunctionDeclaration,
      );

      final variableName = elem.name;
      final variableType = elem.type;
      final variableTypeName =
          variableType.getDisplayString(withNullability: true);

      if (functionDeclaration == null) return;

      int offset;
      final isNamedParam = !variableName.startsWith('_');

      final isRequired = isNamedParam &&
          !(variableTypeName.endsWith('?') || variableType is DynamicType);

      var addNameParamBrackets = isNamedParam;

      final FormalParameterList? paramList;

      if (functionDeclaration is MethodDeclaration) {
        paramList = functionDeclaration.parameters;
      } else {
        functionDeclaration as FunctionDeclaration;
        paramList = functionDeclaration.functionExpression.parameters;
      }

      if (paramList == null) return;

      final (calculatedOffset, hasANamedParam) =
          getOffset(paramList, variableName);
      if (calculatedOffset == null) return;
      offset = calculatedOffset;
      addNameParamBrackets = !hasANamedParam;

      final varDeclarationStatement =
          node.thisOrAncestorOfType<VariableDeclarationStatement>();

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Move variable to parameter list',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(offset, (builder) {
          if (!isNamedParam) {
            builder.write('$variableTypeName $variableName');
            return;
          }

          if (addNameParamBrackets) builder.write('{');
          if (isRequired) builder.write('required ');

          builder.write('$variableTypeName $variableName');

          if (addNameParamBrackets) builder.write('}');
        });

        final variables = varDeclarationStatement!.variables.variables;

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
            range = node.sourceRange
                .getUnion(node.beginToken.previous!.sourceRange);
          }

          builder.addDeletion(range);
        }
      });
    });
  }

  (int?, bool) getOffset(FormalParameterList paramList, String varName) {
    final paramElems = paramList.parameterElements.whereNotNull();

    if (paramElems.isEmpty) {
      return (paramList.leftParenthesis.end, false);
    } else {
      final alreadyHasAParam =
          paramElems.firstWhereOrNull((e) => e.name == varName) == null;

      if (alreadyHasAParam) return (null, false);
      final hasANamedParam =
          paramElems.firstWhereOrNull((e) => e.isNamed) != null;

      return (paramList.rightParenthesis.offset, hasANamedParam);
    }
  }
}
