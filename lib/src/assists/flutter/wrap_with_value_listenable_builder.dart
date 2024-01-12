import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class WrapWithValueListenableBuilder extends DartAssist {
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
      if (type == null || !widgetChecker.isSuperTypeOf(type)) return;

      final listenableVariable = node.valueNotifierIdentifier;
      if (listenableVariable == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with ValueListenableBuilder',
        priority: 29,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(
          node.offset,
          (builder) {
            builder.write('ValueListenableBuilder(');
            builder.write('valueListenable: ${listenableVariable.name},');
            builder.write('builder: (context, value, child) { return ');
          },
        );

        builder.addSimpleInsertion(node.end, '; },)');
      });
    });
  }
}
