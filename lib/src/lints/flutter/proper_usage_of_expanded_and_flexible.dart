import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/type_checker.dart';

class ProperUsageOfExpandedAndFlexible extends DartLintRule {
  const ProperUsageOfExpandedAndFlexible() : super(code: _code);

  static const _code = LintCode(
    name: 'proper_usage_of_expanded_and_flexible',
    problemMessage: '{0} should be placed inside a Row, Column, or Flex.',
    correctionMessage:
        'Try placing {0} inside a Row, Column, or Flex, or remove it.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null ||
          !expandedOrFlexibleChecker.isAssignableFromType(type)) {
        return;
      }

      final parentInstanceCreationExpression =
          node.parentInstanceCreationExpression;
      if (parentInstanceCreationExpression == null) return;

      final parentType = parentInstanceCreationExpression.staticType;
      if (parentType == null || flexChecker.isAssignableFromType(parentType)) {
        return;
      }

      reporter.reportErrorForNode(
        code,
        node.constructorName,
        [type.getDisplayString(withNullability: false)],
      );
    });
  }
}
