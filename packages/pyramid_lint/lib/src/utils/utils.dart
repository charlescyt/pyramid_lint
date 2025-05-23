import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';

import 'type_checker.dart';

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

AstNode? getAstNodeFromElement(Element element) {
  final session = element.session;
  if (session == null) return null;

  final elementLibrary = element.library;
  if (elementLibrary == null) return null;

  final parsedLibraryResult =
      session.getParsedLibraryByElement(elementLibrary) as ParsedLibraryResult;
  final elementDeclarationResult = parsedLibraryResult.getElementDeclaration(
    element,
  );

  return elementDeclarationResult?.node;
}

InstanceCreationExpression? findParentWidget(InstanceCreationExpression expr) {
  final parentExpr = expr.parent
      ?.thisOrAncestorOfType<InstanceCreationExpression>();
  if (parentExpr == null) return null;

  final parentType = parentExpr.staticType;
  if (parentType == null || !widgetChecker.isSuperTypeOf(parentType)) {
    return null;
  }

  return parentExpr;
}

int getLineCountForNode(AstNode node, LineInfo lineInfo) {
  final startLine = lineInfo.getLocation(node.offset).lineNumber;
  final endLine = lineInfo.getLocation(node.end).lineNumber;
  return endLine - startLine + 1;
}
