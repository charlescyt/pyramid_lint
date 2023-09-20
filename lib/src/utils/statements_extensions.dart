import 'package:analyzer/dart/ast/ast.dart';

extension StatementsExtensions on NodeList<Statement> {
  /// Returns the expression statements in this list.
  Iterable<ExpressionStatement> get expressionStatements {
    return whereType<ExpressionStatement>();
  }
}
