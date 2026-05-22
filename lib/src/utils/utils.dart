import 'package:analyzer/dart/ast/ast.dart';

/// Whether the [expression] is the zero number literal.
bool isZeroExpression(Expression expression) {
  if (expression is IntegerLiteral) return expression.value == 0;
  if (expression is DoubleLiteral) return expression.value == 0.0;
  return false;
}
