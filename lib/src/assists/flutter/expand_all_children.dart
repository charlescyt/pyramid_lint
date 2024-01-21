import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class ExpandAllChildren extends DartAssist {
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
          !widgetChecker.isSuperTypeOf(type) ||
          !flexChecker.isAssignableFromType(type)) return;

      final args = node.argumentList.arguments;

      final childrenArg = args
          .whereType<NamedExpression>()
          .where((NamedExpression e) => e.name.label.name == 'children')
          .where((e) => e.expression is ListLiteral)
          .firstOrNull;

      if (childrenArg == null) return;

      final childrenExpression = childrenArg.expression as ListLiteral;

      final childrenElements =
          childrenExpression.elements.whereType<InstanceCreationExpression>();

      final nonExpandedChildren = childrenElements
          .whereNot((e) => expandedChecker.isAssignableFromType(e.staticType!));

      if (nonExpandedChildren.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Expand all children',
        priority: 26,
      );

      changeBuilder.addDartFileEdit((builder) {
        for (final child in nonExpandedChildren) {
          if (flexibleChecker.isExactlyType(child.staticType!)) {
            builder.addReplacement(
              child.constructorName.sourceRange,
              (builder) => builder.write('Expanded'),
            );
          } else {
            builder.addSimpleInsertion(
              child.offset,
              'Expanded(child: ',
            );

            builder.addSimpleInsertion(
              child.end,
              ',)',
            );
          }
        }
      });
    });
  }
}
