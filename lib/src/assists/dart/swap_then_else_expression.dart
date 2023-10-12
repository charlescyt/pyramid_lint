import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';

class SwapThenElseExpression extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addIfStatement((node) {
      if (!node.sourceRange.covers(target)) return;

      final childrenIfStatements = node.childrenIfStatements;
      final isTargetInsideChildrenIfStatements =
          childrenIfStatements.any((e) => e.sourceRange.intersects(target));
      if (isTargetInsideChildrenIfStatements) return;

      final thenStatement = node.thenStatement;
      final elseStatement = node.elseStatement;
      if (elseStatement == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Swap then and else expression',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          thenStatement.sourceRange,
          elseStatement.toSource(),
        );
        builder.addSimpleReplacement(
          elseStatement.sourceRange,
          thenStatement.toSource(),
        );
      });
    });

    context.registry.addConditionalExpression((node) {
      if (!node.sourceRange.covers(target)) return;

      final childrenConditionalExpressions =
          node.childrenConditionalExpressions;
      final isTargetInsideChildrenConditionalExpressions =
          childrenConditionalExpressions
              .any((e) => e.sourceRange.intersects(target));
      if (isTargetInsideChildrenConditionalExpressions) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Swap then and else expression',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.startOffsetEndOffset(
            node.thenExpression.offset,
            node.elseExpression.end,
          ),
          '${node.elseExpression.toSource()} : ${node.thenExpression.toSource()}',
        );
      });
    });
  }
}
