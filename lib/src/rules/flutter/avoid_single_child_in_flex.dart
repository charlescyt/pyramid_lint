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

class AvoidSingleChildInFlexRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_single_child_in_flex',
    'Using {0} to position a single widget is inefficient.',
    correctionMessage: 'Consider replacing {0} with Align or Center.',
    severity: DiagnosticSeverity.INFO,
  );

  AvoidSingleChildInFlexRule()
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
    if (type == null || !flexChecker.isAssignableFromType(type)) return;

    final childrenExpression = node.argumentList.childrenArgument?.argumentExpression;
    if (childrenExpression is! ListLiteral) return;

    if (childrenExpression.elements.length != 1) return;

    final firstElement = childrenExpression.elements.first;
    if (firstElement is SpreadElement || firstElement is ForElement) return;

    rule.reportAtNode(node.constructorName, arguments: [type.getDisplayString()]);
  }
}

class ReplaceWithAlign extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithAlign',
    DartFixKindPriority.standard,
    'Replace with Align',
  );

  ReplaceWithAlign({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final childrenExpression = instanceCreation.argumentList.childrenArgument?.argumentExpression;
    if (childrenExpression is! ListLiteral || childrenExpression.elements.length != 1) return;

    final child = childrenExpression.elements.first;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(instanceCreation),
        'Align(child: ${child.toSource()})',
      );
    });
  }
}

class ReplaceWithCenter extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithCenter',
    DartFixKindPriority.standard,
    'Replace with Center',
  );

  ReplaceWithCenter({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final childrenExpression = instanceCreation.argumentList.childrenArgument?.argumentExpression;
    if (childrenExpression is! ListLiteral || childrenExpression.elements.length != 1) return;

    final child = childrenExpression.elements.first;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(instanceCreation),
        'Center(child: ${child.toSource()})',
      );
    });
  }
}
