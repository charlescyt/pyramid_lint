import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class NoSelfComparisons extends DartLintRule {
  const NoSelfComparisons() : super(code: _code);

  static const name = 'no_self_comparisons';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Self comparison is usually a mistake.',
    correctionMessage: 'Consider changing the comparison to something else.',
    url: '$docUrl#${NoSelfComparisons.name}',
    errorSeverity: ErrorSeverity.WARNING,
  );

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
