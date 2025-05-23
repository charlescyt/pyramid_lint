import 'package:analyzer/dart/ast/ast.dart';
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
      final elseKeyword = node.elseKeyword;
      if (elseKeyword == null) return;

      final thenStatement = node.thenStatement;
      final elseStatement = node.elseStatement;
      if (elseStatement == null) return;

      if (!_isTargetOverIfConditionOrElseKeyword(
        target: target,
        node: node,
      )) {
        return;
      }

      final childrenIfStatements = node.childrenIfStatements;
      if (_isTargetInsideChildrenIfStatements(
        target: target,
        childrenIfStatements: childrenIfStatements,
      )) {
        return;
      }

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
        builder.format(node.sourceRange);
      });
    });

    context.registry.addConditionalExpression((node) {
      if (!node.sourceRange.covers(target)) return;

      final childrenConditionalExpressions =
          node.childrenConditionalExpressions;
      if (_isTargetInsideChildrenConditionalExpressions(
        target: target,
        childrenConditionalExpressions: childrenConditionalExpressions,
      )) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Swap then and else expression',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.startEnd(node.thenExpression, node.elseExpression),
          '${node.elseExpression.toSource()} : ${node.thenExpression.toSource()}',
        );
      });
    });
  }

  bool _isTargetOverIfConditionOrElseKeyword({
    required SourceRange target,
    required IfStatement node,
  }) {
    final ifConditionSourceRange = range.startEnd(
      node.ifKeyword,
      node.rightParenthesis,
    );
    final elseKeywordSourceRange = node.elseKeyword?.sourceRange;
    return ifConditionSourceRange.covers(target) ||
        elseKeywordSourceRange?.covers(target) == true;
  }

  bool _isTargetInsideChildrenIfStatements({
    required SourceRange target,
    required Iterable<IfStatement> childrenIfStatements,
  }) {
    return childrenIfStatements.any((e) => e.sourceRange.intersects(target));
  }

  bool _isTargetInsideChildrenConditionalExpressions({
    required SourceRange target,
    required Iterable<ConditionalExpression> childrenConditionalExpressions,
  }) {
    return childrenConditionalExpressions.any(
      (e) => e.sourceRange.intersects(target),
    );
  }
}
