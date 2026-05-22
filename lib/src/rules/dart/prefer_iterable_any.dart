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

class PreferIterableAnyRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_iterable_any',
    'Using Iterable.where(...).isNotEmpty is more verbose than Iterable.any.',
    correctionMessage: 'Consider using Iterable.any for better readability.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferIterableAnyRule()
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
    final propertyName = node.propertyName.name;
    if (propertyName != 'isNotEmpty') return;

    final propertyAccessTarget = node.realTarget;
    if (propertyAccessTarget is! MethodInvocation) return;

    final methodName = propertyAccessTarget.methodName.name;
    if (methodName != 'where') return;

    final target = propertyAccessTarget.realTarget;
    final targetType = target?.staticType;
    if (targetType == null) return;

    if (!iterableChecker.isAssignableFromType(targetType)) return;

    rule.reportAtNode(node);
  }
}

class ReplaceWithIterableAny extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithIterableAny',
    DartFixKindPriority.standard,
    'Replace with Iterable.any',
  );

  ReplaceWithIterableAny({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final propertyAccess = node;
    if (propertyAccess is! PropertyAccess) return;

    final target = propertyAccess.realTarget;
    if (target is! MethodInvocation) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(target.methodName.sourceRange, 'any');
      builder.addDeletion(range.startEnd(propertyAccess.operator, propertyAccess.propertyName));
    });
  }
}
