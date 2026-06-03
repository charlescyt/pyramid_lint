import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidPositionalFieldsInRecordsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_positional_fields_in_records',
    'Using positional field getters decreases readability.',
    correctionMessage: 'Consider using named field getters instead.',
    severity: DiagnosticSeverity.INFO,
  );

  AvoidPositionalFieldsInRecordsRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final targetType = node.realTarget.staticType;
    if (targetType is! RecordType) return;

    final propertyName = node.propertyName;
    if (!propertyName.name.startsWith(r'$')) return;

    rule.reportAtNode(propertyName);
  }
}
