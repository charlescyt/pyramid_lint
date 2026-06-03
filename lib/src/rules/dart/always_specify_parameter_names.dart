import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AlwaysSpecifyParameterNamesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'always_specify_parameter_names',
    'Parameter names in function type signatures should be specified to improve readability and IDE parameter hints.',
    correctionMessage: 'Consider adding a descriptive parameter name.',
    severity: DiagnosticSeverity.INFO,
  );

  AlwaysSpecifyParameterNamesRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addRegularFormalParameter(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitRegularFormalParameter(RegularFormalParameter node) {
    if (node.name == null) {
      rule.reportAtNode(node);
    }
  }
}
