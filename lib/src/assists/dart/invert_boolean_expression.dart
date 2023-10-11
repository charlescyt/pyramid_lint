import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/utils.dart';

class InvertBooleanExpression extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addBinaryExpression((node) {
      if (!node.sourceRange.covers(target)) return;

      final childrenBinaryExpressions = node.childrenBinaryExpressions;
      final isTargetInsideChildrenBinaryExpressions = childrenBinaryExpressions
          .any((e) => e.sourceRange.intersects(target));
      if (isTargetInsideChildrenBinaryExpressions) return;

      final operator = node.operator.type;
      if (!operator.isEqualityOperator && !operator.isRelationalOperator) {
        return;
      }

      final invertedOperator = getInvertedOperator(operator);
      if (invertedOperator == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Invert boolean expression',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          '${node.leftOperand} ${invertedOperator.lexeme} ${node.rightOperand}',
        );
      });
    });
  }
}
