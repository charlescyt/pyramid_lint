import 'package:analyzer/dart/ast/ast.dart';

import 'visitors.dart';

extension AstNodeExtensions on AstNode {
  /// Returns the nearest ancestor node of this node that is of type
  /// [InstanceCreationExpression], or `null` if there are none.
  InstanceCreationExpression? get parentInstanceCreationExpression =>
      parent?.thisOrAncestorOfType<InstanceCreationExpression>();

  // Returns the if statements in this node.
  Iterable<IfStatement> get childrenIfStatements {
    final ifStatements = <IfStatement>[];

    visitChildren(
      RecursiveIfStatementVisitor(
        onVisitIfStatement: ifStatements.add,
      ),
    );

    return ifStatements;
  }

  /// Returns the conditional expressions in this node.
  List<ConditionalExpression> get childrenConditionalExpressions {
    final conditionalExpressions = <ConditionalExpression>[];

    visitChildren(
      RecursiveConditionalExpressionVisitor(
        onVisitConditionalExpression: conditionalExpressions.add,
      ),
    );

    return conditionalExpressions;
  }

  Iterable<BinaryExpression> get childrenBinaryExpressions {
    final binaryExpressions = <BinaryExpression>[];

    visitChildren(
      RecursiveBinaryExpressionVisitor(
        onVisitBinaryExpression: binaryExpressions.add,
      ),
    );

    return binaryExpressions;
  }
}
