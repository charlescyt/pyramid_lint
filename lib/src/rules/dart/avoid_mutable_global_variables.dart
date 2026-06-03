import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidMutableGlobalVariablesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_mutable_global_variables',
    'Using mutable global variables is discouraged.',
    correctionMessage: 'Consider declaring the variable as final or const.',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidMutableGlobalVariablesRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addTopLevelVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    final variables = node.variables;
    if (variables.isFinal || variables.isConst) return;

    for (final variable in variables.variables) {
      rule.reportAtToken(variable.name);
    }
  }
}
