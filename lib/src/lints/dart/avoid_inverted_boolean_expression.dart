import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _validOperator = {
  TokenType.EQ_EQ,
  TokenType.BANG_EQ,
  TokenType.GT,
  TokenType.GT_EQ,
  TokenType.LT,
  TokenType.LT_EQ,
};

TokenType? _getInvertedOperator(TokenType operator) {
  return switch (operator) {
    TokenType.EQ_EQ => TokenType.BANG_EQ,
    TokenType.BANG_EQ => TokenType.EQ_EQ,
    TokenType.GT => TokenType.LT_EQ,
    TokenType.LT => TokenType.GT_EQ,
    TokenType.GT_EQ => TokenType.LT,
    TokenType.LT_EQ => TokenType.GT,
    _ => null,
  };
}

class AvoidInvertedBooleanExpression extends DartLintRule {
  const AvoidInvertedBooleanExpression() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_inverted_boolean_expression',
    problemMessage:
        'Using inverted boolean expression decreases code readability.',
    correctionMessage: 'Consider using {0} instead.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixExpression((node) {
      final prefix = node.operator;
      if (prefix.type != TokenType.BANG) return;

      final operand = node.operand;
      if (operand is! ParenthesizedExpression) return;

      final operandExpression = operand.expression;
      if (operandExpression is! BinaryExpression) return;

      final operator = operandExpression.operator.type;
      if (!_validOperator.contains(operator)) return;

      final invertedOperator = _getInvertedOperator(operator);
      if (invertedOperator == null) return;

      final parent = node.parent;
      if (parent is! IfStatement &&
          parent is! ConditionalExpression &&
          parent is! VariableDeclaration &&
          parent is! AssignmentExpression) return;

      String correctExpression;

      if (parent is ConditionalExpression) {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}'
            ' ? ${parent.elseExpression.toSource()} : ${parent.thenExpression.toSource()}';

        reporter.reportErrorForNode(
          code,
          parent,
          [correctExpression],
        );
      } else {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}';

        reporter.reportErrorForNode(
          code,
          node,
          [correctExpression],
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [AvoidInvertedBooleanExpressionFix()];
}

class AvoidInvertedBooleanExpressionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPrefixExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final expression = node.operand;
      if (expression is! ParenthesizedExpression) return;

      final operandExpression = expression.expression;
      if (operandExpression is! BinaryExpression) return;

      final operator = operandExpression.operator.type;
      if (!_validOperator.contains(operator)) return;

      final invertedOperator = _getInvertedOperator(operator);
      if (invertedOperator == null) return;

      final parent = node.parent;
      if (parent is! IfStatement &&
          parent is! ConditionalExpression &&
          parent is! VariableDeclaration &&
          parent is! AssignmentExpression) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with positive boolean expression',
        priority: 80,
      );

      String correctExpression;

      if (parent is ConditionalExpression) {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}'
            ' ? ${parent.elseExpression.toSource()} : ${parent.thenExpression.toSource()}';

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(parent.sourceRange, correctExpression);
        });
      } else {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}';

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(node.sourceRange, correctExpression);
        });
      }
    });
  }
}
