import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidDynamicRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_dynamic',
    'Avoid using dynamic where a more specific type would improve safety.',
    correctionMessage: 'Specify a type other than dynamic, or use Object? if needed.',
    severity: DiagnosticSeverity.INFO,
  );

  AvoidDynamicRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addNamedType(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitNamedType(NamedType node) {
    if (node.type is! DynamicType) return;
    if (_isUsedInMap(node)) return;

    rule.reportAtNode(node);
  }

  bool _isUsedInMap(NamedType node) {
    final parent = node.parent;
    if (parent is! TypeArgumentList) return false;

    final grandParent = parent.parent;

    // Map<String, dynamic>
    // node: dynamic
    // parent: <String, dynamic>
    // grandParent: Map
    if (grandParent is NamedType && grandParent.type?.isDartCoreMap == true) {
      return true;
    }

    // <String, dynamic>{}
    // node: dynamic
    // parent: <String, dynamic>
    // grandParent: <String, dynamic>{}
    if (grandParent is SetOrMapLiteral && grandParent.isMap) {
      return true;
    }

    return false;
  }
}
