import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class WrapWithExpanded extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = switch (node.keyword) {
        null => node.constructorName.sourceRange,
        final keyword => range.startEnd(
            keyword,
            node.constructorName,
          ),
      };
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;
      if (type == null ||
          expandedOrFlexibleChecker.isExactlyType(type) ||
          !widgetChecker.isSuperTypeOf(type)) return;

      final parentInstanceCreationExpression =
          node.parent?.thisOrAncestorOfType<InstanceCreationExpression>();
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
