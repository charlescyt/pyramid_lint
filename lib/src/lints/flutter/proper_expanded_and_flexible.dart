import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class ProperExpandedAndFlexible extends DartLintRule {
  const ProperExpandedAndFlexible() : super(code: _code);

  static const name = 'proper_expanded_and_flexible';

  static const _code = LintCode(
    name: name,
    problemMessage: '{0} should be placed inside a Row, Column, or Flex.',
    correctionMessage:
        'Try placing {0} inside a Row, Column, or Flex, or remove it.',
    url: '$flutterLintDocUrl/${ProperExpandedAndFlexible.name}',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

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
