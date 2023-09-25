import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

extension CustomLintResolverExtension on CustomLintResolver {
  int getLineCountForNode(AstNode node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    return endLine - startLine + 1;
  }
}
