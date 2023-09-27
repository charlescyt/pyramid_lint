import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/type_checker.dart';

class WrapWithLayoutBuilder extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      if (!(target.intersects(node.constructorName.sourceRange) ||
          target.intersects(node.keyword?.sourceRange))) return;

      final type = node.staticType;
      if (type == null || !widgetChecker.isSuperTypeOf(type)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with LayoutBuilder',
        priority: 29,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(
          node.offset,
          'LayoutBuilder(builder: (context, constraints) { return ',
        );
        builder.addSimpleInsertion(node.end, '; },)');
      });
    });
  }
}