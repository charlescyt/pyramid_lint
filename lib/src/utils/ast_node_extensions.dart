import 'package:analyzer/dart/ast/ast.dart';

import 'visitors.dart';

extension AstNodeExtensions on AstNode {
  /// Returns the nearest [InstanceCreationExpression] that is an ancestor
  /// of this [AstNode], or `null` if there is none.
  InstanceCreationExpression? get parentInstanceCreationExpression =>
      parent?.thisOrAncestorOfType<InstanceCreationExpression>();

  /// Returns an iterable of all the [IfStatement] that are
  /// children of this [AstNode].
  Iterable<IfStatement> get childrenIfStatements {
    final ifStatements = <IfStatement>[];

    visitChildren(
      RecursiveIfStatementVisitor(
        onVisitIfStatement: ifStatements.add,
      ),
    );

    return ifStatements;
  }

  /// Returns an iterable of all the [ConditionalExpression] that are
  /// children of this [AstNode].
  Iterable<ConditionalExpression> get childrenConditionalExpressions {
    final conditionalExpressions = <ConditionalExpression>[];

    visitChildren(
      RecursiveConditionalExpressionVisitor(
        onVisitConditionalExpression: conditionalExpressions.add,
      ),
    );

    return conditionalExpressions;
  }

  /// Returns an iterable of all the [BinaryExpression] that are
  /// children of this [AstNode].
  Iterable<BinaryExpression> get childrenBinaryExpressions {
    final binaryExpressions = <BinaryExpression>[];

    visitChildren(
      RecursiveBinaryExpressionVisitor(
        onVisitBinaryExpression: binaryExpressions.add,
      ),
    );

    return binaryExpressions;
  }

  /// Returns a single [SimpleIdentifier] instance with staticType assignable
  /// to ValueNotifier that is the child of this [AstNode].
  SimpleIdentifier? get valueNotifierIdentifier {
    SimpleIdentifier? identifier;

    visitChildren(
      SingleLevelValueNotifierIdentifierVisitor(
        onVisitNotifierIdentifier: (node) => identifier = node,
      ),
    );

    return identifier;
  }
}
