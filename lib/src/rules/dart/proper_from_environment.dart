import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class ProperFromEnvironmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'proper_from_environment',
    'The {0}.fromEnvironment constructor should be invoked with a const keyword.',
    correctionMessage: 'Try invoking the {0}.fromEnvironment constructor with a const keyword.',
    severity: DiagnosticSeverity.ERROR,
  );

  ProperFromEnvironmentRule()
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
    final constructorName = node.constructorName.name?.name;
    if (constructorName != 'fromEnvironment') return;

    if (node.isConst) return;

    final type = node.staticType;
    if (type == null) return;

    if (type.isDartCoreBool || type.isDartCoreInt || type.isDartCoreString) {
      rule.reportAtNode(node, arguments: [type.getDisplayString()]);
    }
  }
}

class InvokeAsConstConstructor extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.invokeAsConstConstructor',
    DartFixKindPriority.standard,
    '{0} const keyword',
  );

  InvokeAsConstConstructor({required super.context});

  late String fixAction;

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  List<String>? get fixArguments => [fixAction];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final keyword = instanceCreation.keyword;
    fixAction = keyword == null ? 'Add' : 'Replace with';

    await builder.addDartFileEdit(file, (builder) {
      if (keyword == null) {
        builder.addSimpleInsertion(instanceCreation.offset, 'const ');
      } else {
        builder.addSimpleReplacement(keyword.sourceRange, 'const');
      }
    });
  }
}
