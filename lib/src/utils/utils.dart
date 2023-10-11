import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

bool isZeroExpression(Expression e) {
  if (e is IntegerLiteral) return e.value == 0;
  if (e is DoubleLiteral) return e.value == 0.0;
  return false;
}

TokenType? getInvertedOperator(TokenType operator) {
  return switch (operator) {
    TokenType.EQ_EQ => TokenType.BANG_EQ,
    TokenType.BANG_EQ => TokenType.EQ_EQ,
    TokenType.GT => TokenType.LT_EQ,
    TokenType.LT => TokenType.GT_EQ,
    TokenType.GT_EQ => TokenType.LT,
    TokenType.LT_EQ => TokenType.GT,
    _ => null,
  };
}
