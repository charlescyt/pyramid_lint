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
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../../utils/type_checker.dart';

class PreferBorderFromBorderSideRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_border_from_border_side',
    'Border.all is not a const constructor and it uses const constructor Border.fromBorderSide internally.',
    correctionMessage: 'Consider replacing Border.all with Border.fromBorderSide.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferBorderFromBorderSideRule()
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
    if (type == null || !borderChecker.isExactlyType(type)) return;

    final constructorNameIdentifier = node.constructorName.name;
    if (constructorNameIdentifier?.name != 'all') return;

    rule.reportAtNode(node.constructorName);
  }
}

class ReplaceWithBorderFromBorderSide extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithBorderFromBorderSide',
    DartFixKindPriority.standard,
    'Replace with Border.fromBorderSide',
  );

  ReplaceWithBorderFromBorderSide({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final argumentList = instanceCreation.argumentList;
    final replacement = 'Border.fromBorderSide(BorderSide${argumentList.toSource()})';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(instanceCreation), replacement);
    });
  }
}
