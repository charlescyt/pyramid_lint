import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';

TokenType? _getInvertedOperator(TokenType operator) {
  return switch (operator) {
    TokenType.EQ_EQ => TokenType.BANG_EQ,
    TokenType.BANG_EQ => TokenType.EQ_EQ,
    TokenType.GT => TokenType.LT_EQ,
    TokenType.LT => TokenType.GT_EQ,
    TokenType.GT_EQ => TokenType.LT,
    TokenType.LT_EQ => TokenType.GT,
    _ => null,
  };
}

class InvertBooleanExpression extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addBinaryExpression((node) {
      if (!target.intersects(node.sourceRange)) return;

      final childrenBinaryExpressions = node.childrenBinaryExpressions;
      final isTargetInsideChildrenBinaryExpressions = childrenBinaryExpressions
          .any((e) => e.sourceRange.intersects(target));
      if (isTargetInsideChildrenBinaryExpressions) return;

      final operator = node.operator.type;
      if (!operator.isEqualityOperator && !operator.isRelationalOperator) {
        return;
      }

      final invertedOperator = _getInvertedOperator(operator);
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
