import 'package:analyzer/dart/ast/ast.dart';

extension AstNodeExtensions on AstNode {
  /// Returns the nearest ancestor node of this node that is of type
  /// [InstanceCreationExpression], or `null` if there are none.
  InstanceCreationExpression? get parentInstanceCreationExpression =>
      parent?.thisOrAncestorOfType<InstanceCreationExpression>();
}
