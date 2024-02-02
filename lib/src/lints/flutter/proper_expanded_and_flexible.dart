import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class ProperExpandedAndFlexible extends DartLintRule {
  const ProperExpandedAndFlexible()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                '{0} should be placed inside a Row, Column, or Flex.',
            correctionMessage:
                'Try placing {0} inside a Row, Column, or Flex, or remove it.',
            url: '$flutterLintDocUrl/${ProperExpandedAndFlexible.name}',
            errorSeverity: ErrorSeverity.ERROR,
          ),
        );

  static const name = 'proper_expanded_and_flexible';

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
          node.parent?.thisOrAncestorOfType<InstanceCreationExpression>();
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
