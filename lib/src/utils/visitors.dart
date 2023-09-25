import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class RecursiveIfStatementVisitor extends RecursiveAstVisitor<void> {
  const RecursiveIfStatementVisitor({
    required this.onVisitIfStatement,
  });

  final void Function(IfStatement node) onVisitIfStatement;

  @override
  void visitIfStatement(IfStatement node) {
    onVisitIfStatement(node);
    node.visitChildren(this);
  }
}

class RecursiveConditionalExpressionVisitor extends RecursiveAstVisitor<void> {
  const RecursiveConditionalExpressionVisitor({
    required this.onVisitConditionalExpression,
  });

  final void Function(ConditionalExpression node) onVisitConditionalExpression;

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    onVisitConditionalExpression(node);
    node.visitChildren(this);
  }
}

class RecursiveBinaryExpressionVisitor extends RecursiveAstVisitor<void> {
  const RecursiveBinaryExpressionVisitor({
    required this.onVisitBinaryExpression,
  });

  final void Function(BinaryExpression node) onVisitBinaryExpression;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    onVisitBinaryExpression(node);
    node.visitChildren(this);
  }
}
