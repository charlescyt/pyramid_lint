import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'type_checker.dart';

class SingleLevelValueNotifierIdentifierVisitor
    extends RecursiveAstVisitor<void> {
  const SingleLevelValueNotifierIdentifierVisitor({
    required this.onVisitNotifierIdentifier,
  });

  final void Function(SimpleIdentifier node) onVisitNotifierIdentifier;

  @override
  void visitNamedExpression(NamedExpression node) {
    //We only want to traverse the current node not the node's child subtree
    if (node.name.label.name == 'child' &&
        node.expression is InstanceCreationExpression) {
      return;
    }

    node.visitChildren(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.staticType != null &&
        valueNotifierChecker.isAssignableFromType(node.staticType!)) {
      onVisitNotifierIdentifier(node);
      return;
    }

    node.visitChildren(this);
  }
}

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

class RecursiveSimpleIdentifierVisitor extends RecursiveAstVisitor<void> {
  const RecursiveSimpleIdentifierVisitor({
    required this.onVisitSimpleIdentifier,
  });

  final void Function(SimpleIdentifier node) onVisitSimpleIdentifier;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    onVisitSimpleIdentifier(node);
    node.visitChildren(this);
  }
}

class RecursiveReturnStatementVisitor extends RecursiveAstVisitor<void> {
  RecursiveReturnStatementVisitor();

  final returnStatements = <ReturnStatement>[];

  @override
  void visitReturnStatement(ReturnStatement node) {
    returnStatements.add(node);
    node.visitChildren(this);
  }
}
