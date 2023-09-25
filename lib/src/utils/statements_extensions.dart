import 'package:analyzer/dart/ast/ast.dart';

extension StatementsExtensions on NodeList<Statement> {
  /// Returns an iterable of all the [ExpressionStatement] in this [Statement]
  /// list.
  Iterable<ExpressionStatement> get expressionStatements {
    return whereType<ExpressionStatement>();
  }
}
