import 'package:analyzer/dart/ast/ast.dart';

bool isZeroExpression(Expression e) {
  if (e is IntegerLiteral) return e.value == 0;
  if (e is DoubleLiteral) return e.value == 0.0;
  return false;
}
