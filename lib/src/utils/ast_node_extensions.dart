import 'package:analyzer/dart/ast/ast.dart';

import 'visitors.dart';

extension AstNodeExtension on AstNode {
  /// Returns an iterable of all the [IfStatement] that are
  /// children of this [AstNode].
  Iterable<IfStatement> get childrenIfStatements {
    final ifStatements = <IfStatement>[];
    final visitor = RecursiveIfStatementVisitor(
      onVisitIfStatement: ifStatements.add,
    );

    visitChildren(visitor);

    return ifStatements;
  }

  /// Returns an iterable of all the [ConditionalExpression] that are
  /// children of this [AstNode].
  Iterable<ConditionalExpression> get childrenConditionalExpressions {
    final conditionalExpressions = <ConditionalExpression>[];
    final visitor = RecursiveConditionalExpressionVisitor(
      onVisitConditionalExpression: conditionalExpressions.add,
    );

    visitChildren(visitor);

    return conditionalExpressions;
  }

  /// Returns an iterable of all the [BinaryExpression] that are
  /// children of this [AstNode].
  Iterable<BinaryExpression> get childrenBinaryExpressions {
    final binaryExpressions = <BinaryExpression>[];
    final visitor = RecursiveBinaryExpressionVisitor(
      onVisitBinaryExpression: binaryExpressions.add,
    );

    visitChildren(visitor);

    return binaryExpressions;
  }
}
