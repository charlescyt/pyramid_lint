import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/ast_node_extensions.dart';
import '../utils/type_checker.dart';

class WrapWithExpanded extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      if (!target.intersects(node.constructorName.sourceRange)) return;

      final type = node.staticType;
      if (type == null ||
          expandedOrFlexibleChecker.isExactlyType(type) ||
          !widgetChecker.isSuperTypeOf(type)) return;

      final parentInstanceCreationExpression =
          node.parentInstanceCreationExpression;
      if (parentInstanceCreationExpression == null) return;

      final parentType = parentInstanceCreationExpression.staticType;
      if (parentType == null || !flexChecker.isAssignableFromType(parentType)) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with Expanded',
        priority: 27,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(
          node.offset,
          'Expanded(child: ',
        );

        builder.addSimpleInsertion(
          node.end,
          ',)',
        );
      });
    });
  }
}
