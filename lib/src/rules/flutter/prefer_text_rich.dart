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

import '../../utils/extensions/ast.dart';
import '../../utils/type_checker.dart';

class PreferTextRichRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_text_rich',
    'RichText does not inherit TextStyle from DefaultTextStyle.',
    correctionMessage: 'Consider replacing RichText with Text.rich.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferTextRichRule()
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
    if (type == null || !richTextChecker.isExactlyType(type)) return;

    rule.reportAtNode(node.constructorName);
  }
}

class ReplaceWithTextRich extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithTextRich',
    DartFixKindPriority.standard,
    'Replace with Text.rich',
  );

  ReplaceWithTextRich({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    final instanceCreationExpression = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreationExpression == null) return;

    final textArgument = instanceCreationExpression.argumentList.getArgumentByName('text');

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(node), 'Text.rich');
      if (textArgument != null) {
        builder.addDeletion(textArgument.name.sourceRange);
      }
    });
  }
}
