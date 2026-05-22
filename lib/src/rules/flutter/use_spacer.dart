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

class UseSpacerRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'use_spacer',
    'Using Expanded with an empty {0} is unnecessary.',
    correctionMessage: 'Consider replacing Expanded with Spacer.',
    severity: DiagnosticSeverity.INFO,
  );

  UseSpacerRule()
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
    if (type == null || !expandedChecker.isExactlyType(type)) return;

    final childArgument = node.argumentList.childArgument;
    if (childArgument == null) return;

    final childExpression = childArgument.expression;
    if (childExpression is! InstanceCreationExpression) return;

    final childType = childExpression.staticType;
    if (childType == null) return;

    if (!containerOrSizedBoxChecker.isExactlyType(childType)) return;

    if (childExpression.argumentList.arguments.isNotEmpty) return;

    rule.reportAtNode(node, arguments: [childType.getDisplayString()]);
  }
}

class ReplaceWithSpacer extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithSpacer',
    DartFixKindPriority.standard,
    'Replace with Spacer',
  );

  ReplaceWithSpacer({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreationExpression = node;
    if (instanceCreationExpression is! InstanceCreationExpression) return;

    final flexArgument = instanceCreationExpression.argumentList.getArgumentByName('flex');
    final replacement = flexArgument == null ? 'const Spacer()' : 'const Spacer(${flexArgument.toSource()})';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(instanceCreationExpression), replacement);
    });
  }
}
