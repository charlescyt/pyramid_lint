import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class NoSelfComparisons extends PyramidLintRule {
  NoSelfComparisons({required super.options})
      : super(
          name: name,
          problemMessage: 'Self comparison is usually a mistake.',
          correctionMessage:
              'Consider changing the comparison to something else.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const name = 'no_self_comparisons';
  static const url = '$dartLintDocUrl/$name';

  factory NoSelfComparisons.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return NoSelfComparisons(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      final expression = node.expression;
      if (expression is! BinaryExpression) return;

      final left = expression.leftOperand.unParenthesized;
      final right = expression.rightOperand.unParenthesized;
      if (left.toSource() != right.toSource()) return;

      reporter.reportErrorForNode(code, expression);
    });
  }
}
