import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class WrapWithStack extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.keywordAndConstructorNameSourceRange;
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;
      if (type == null || !widgetChecker.isSuperTypeOf(type)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with Stack',
        priority: 28,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(node.offset, 'Stack(children: [');
        builder.addSimpleInsertion(node.end, ',],)');
      });
    });
  }
}
