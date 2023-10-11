import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class PreferImmediateReturn extends DartLintRule {
  const PreferImmediateReturn() : super(code: _code);

  static const name = 'prefer_immediate_return';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Declaring a variable to return it on the next line is '
        'unnecessary.',
    correctionMessage: 'Return the value immediately.',
    url: '$docUrl#${PreferImmediateReturn.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlockFunctionBody((node) {
      final statements = node.block.statements;
      if (statements.length < 2) return;

      final secondLastStatement = statements[statements.length - 2];
      final lastStatement = statements.last;

      if (secondLastStatement is! VariableDeclarationStatement ||
          lastStatement is! ReturnStatement) return;

      final lastStatementExpression = lastStatement.expression;
      if (lastStatementExpression is! SimpleIdentifier) return;

      final variableDeclaration = secondLastStatement.variables.variables.first;
      if (variableDeclaration.name.lexeme != lastStatementExpression.name) {
        return;
      }

      reporter.reportErrorForNode(code, lastStatement);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithImmediateReturn()];
}

class _ReplaceWithImmediateReturn extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addBlockFunctionBody((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final statements = node.block.statements;
      if (statements.length < 2) return;

      final secondLastStatement = statements[statements.length - 2];
      final lastStatement = statements.last;

      if (secondLastStatement is! VariableDeclarationStatement ||
          lastStatement is! ReturnStatement) return;

      final lastStatementExpression = lastStatement.expression;
      if (lastStatementExpression is! SimpleIdentifier) return;

      final variableDeclaration = secondLastStatement.variables.variables.first;
      if (variableDeclaration.name.lexeme != lastStatementExpression.name) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Return the value immediately.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(range.deletionRange(secondLastStatement));
        builder.addSimpleReplacement(
          lastStatement.sourceRange,
          'return ${variableDeclaration.initializer};',
        );
      });
    });
  }
}
