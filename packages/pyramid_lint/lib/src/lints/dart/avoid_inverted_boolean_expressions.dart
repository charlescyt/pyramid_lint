import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/token_type_extension.dart';
import '../../utils/utils.dart';

class AvoidInvertedBooleanExpressions extends PyramidLintRule {
  AvoidInvertedBooleanExpressions({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'Using inverted boolean expression decreases code readability.',
          correctionMessage: 'Consider using {0} instead.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'avoid_inverted_boolean_expressions';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidInvertedBooleanExpressions.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidInvertedBooleanExpressions(options: options);
  }

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
      if (!operator.isEqualityOrRelationalOperator) return;

      final invertedOperator = getInvertedOperator(operator);
      if (invertedOperator == null) return;

      final parent = node.parent;
      if (parent is! IfStatement &&
          parent is! ConditionalExpression &&
          parent is! VariableDeclaration &&
          parent is! AssignmentExpression) {
        return;
      }

      String correctExpression;

      if (parent is ConditionalExpression) {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}'
            ' ? ${parent.elseExpression.toSource()} : ${parent.thenExpression.toSource()}';

        reporter.atNode(
          parent,
          code,
          arguments: [correctExpression],
        );
      } else {
        correctExpression =
            '${operandExpression.leftOperand.toSource()} ${invertedOperator.lexeme} '
            '${operandExpression.rightOperand.toSource()}';

        reporter.atNode(
          node,
          code,
          arguments: [correctExpression],
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithPositiveBooleanExpression()];
}

class _ReplaceWithPositiveBooleanExpression extends DartFix {
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
      if (!operator.isEqualityOrRelationalOperator) return;

      final invertedOperator = getInvertedOperator(operator);
      if (invertedOperator == null) return;

      final parent = node.parent;
      if (parent is! IfStatement &&
          parent is! ConditionalExpression &&
          parent is! VariableDeclaration &&
          parent is! AssignmentExpression) {
        return;
      }

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
