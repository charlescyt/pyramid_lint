import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Whether the [expression] is the zero number literal.
bool isZeroExpression(Expression expression) {
  if (expression is IntegerLiteral) return expression.value == 0;
  if (expression is DoubleLiteral) return expression.value == 0.0;
  return false;
}

AstNode? getAstNodeFromElement(Element element) {
  final session = element.session;
  if (session == null) return null;

  final elementLibrary = element.library;
  if (elementLibrary == null) return null;

  final parsedLibraryResult = session.getParsedLibraryByElement(elementLibrary) as ParsedLibraryResult;
  final elementDeclarationResult = parsedLibraryResult.getFragmentDeclaration(element.firstFragment);

  return elementDeclarationResult?.node;
}
