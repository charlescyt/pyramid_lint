import 'package:analyzer/dart/ast/token.dart';

extension TokenTypeExtensions on TokenType {
  bool get isLogicalOperator {
    return this == TokenType.AMPERSAND_AMPERSAND || this == TokenType.BAR_BAR;
  }

  bool get isEqualityOrRelationalOperator {
    return isEqualityOperator || isRelationalOperator;
  }
}
