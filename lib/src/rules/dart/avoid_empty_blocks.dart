import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidEmptyBlocksRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_empty_blocks',
    'Empty block usually indicates a missing implementation.',
    correctionMessage: 'Consider adding an implementation or a TODO comment.',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidEmptyBlocksRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addBlock(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  static final RegExp _todoRegExp = RegExp(r'//+\s*TODO\b', caseSensitive: false);

  @override
  void visitBlock(Block node) {
    if (node.statements.isNotEmpty) return;
    if (_hasTodoCommentInBlock(node)) return;

    rule.reportAtNode(node);
  }

  bool _hasTodoCommentInBlock(Block node) {
    Token? current = node.endToken.precedingComments;
    while (current != null) {
      if (_isTodoComment(current)) return true;
      current = current.next;
    }
    return false;
  }

  bool _isTodoComment(Token token) {
    final content = token.lexeme;
    return content.startsWith(_todoRegExp);
  }
}
