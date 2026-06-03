import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoSelfComparisonsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_self_comparisons',
    'Self comparison is usually a mistake.',
    correctionMessage: 'Consider changing the comparison to something else.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoSelfComparisonsRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitIfStatement(IfStatement node) {
    final expression = node.expression;
    if (expression is! BinaryExpression) return;

    final left = expression.leftOperand.unParenthesized;
    final right = expression.rightOperand.unParenthesized;
    if (left.toSource() != right.toSource()) return;

    rule.reportAtNode(expression);
  }
}
