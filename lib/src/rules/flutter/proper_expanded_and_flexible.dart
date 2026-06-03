import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/type_checker.dart';

class ProperExpandedAndFlexibleRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'proper_expanded_and_flexible',
    '{0} should be placed inside a Row, Column, or Flex.',
    correctionMessage: 'Try placing {0} inside a Row, Column, or Flex, or remove it.',
    severity: DiagnosticSeverity.ERROR,
  );

  ProperExpandedAndFlexibleRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type == null || !expandedOrFlexibleChecker.isAssignableFromType(type)) return;

    final ancestorWidgetCreation = node.parent?.thisOrAncestorOfType<InstanceCreationExpression>();
    if (ancestorWidgetCreation == null) return;

    final ancestorWidgetType = ancestorWidgetCreation.staticType;
    if (ancestorWidgetType == null || flexChecker.isAssignableFromType(ancestorWidgetType)) {
      return;
    }

    rule.reportAtNode(node.constructorName, arguments: [type.getDisplayString()]);
  }
}
