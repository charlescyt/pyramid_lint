import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferAsyncAwaitRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_async_await',
    'Using Future.then() decreases readability.',
    correctionMessage: 'Consider using async/await instead.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferAsyncAwaitRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.realTarget;
    if (target == null) return;

    final targetType = target.staticType;
    if (targetType == null || !targetType.isDartAsyncFuture) return;

    final methodName = node.methodName.name;
    if (methodName != 'then') return;

    rule.reportAtNode(node);
  }
}
