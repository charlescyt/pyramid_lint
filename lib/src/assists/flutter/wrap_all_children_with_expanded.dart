import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class WrapAllChildrenWithExpanded extends DartAssist {
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
      if (type == null || !flexChecker.isAssignableFromType(type)) return;

      final childrenArg = node.argumentList.childrenArgument;
      if (childrenArg == null) return;

      final childrenExpression = childrenArg.expression;
      if (childrenExpression is! ListLiteral) return;

      final childrenElements =
          childrenExpression.elements.whereType<InstanceCreationExpression>();

      final expandableChildren = childrenElements
          .where((e) => e.staticType != null)
          .whereNot(
            (e) =>
                expandedOrFlexibleOrSpacerChecker.isExactlyType(e.staticType!),
          );
      if (expandableChildren.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap all children with Expanded',
        priority: 27,
      );

      changeBuilder.addDartFileEdit((builder) {
        for (final child in expandableChildren) {
          builder.addSimpleInsertion(
            child.offset,
            'Expanded(child: ',
          );

          builder.addSimpleInsertion(
            child.end,
            ')',
          );
        }
      });
    });
  }
}
