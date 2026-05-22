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
import '../../utils/utils.dart';

class ProperEdgeInsetsConstructorsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'proper_edge_insets_constructors',
    'Using incorrect EdgeInsets constructor and arguments.',
    correctionMessage: 'Consider replacing with {0}.',
    severity: DiagnosticSeverity.INFO,
  );

  ProperEdgeInsetsConstructorsRule()
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
    if (type == null || !edgeInsetsChecker.isExactlyType(type)) return;

    final replacement = _properEdgeInsetsReplacement(node);
    if (replacement == null) return;

    rule.reportAtNode(node, arguments: [replacement]);
  }
}

class ReplaceWithProperEdgeInsets extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithProperEdgeInsets',
    DartFixKindPriority.standard,
    'Replace with {0}',
  );

  ReplaceWithProperEdgeInsets({required super.context});

  late String _replacement;

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  List<String>? get fixArguments => [_replacement];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final replacement = _properEdgeInsetsReplacement(instanceCreation);
    if (replacement == null) return;

    _replacement = replacement;

    await builder.addDartFileEdit(file, (fileEdit) {
      fileEdit.addSimpleReplacement(range.node(instanceCreation), replacement);
    });
  }
}

String? _properEdgeInsetsReplacement(InstanceCreationExpression node) {
  return switch (node.constructorName.name?.name) {
    'fromLTRB' => _fromLtrbReplacement(node),
    'only' => _onlyReplacement(node),
    'symmetric' => _symmetricReplacement(node),
    _ => null,
  };
}

String? _fromLtrbReplacement(InstanceCreationExpression node) {
  final arguments = node.argumentList.positionalArguments.toList();
  if (arguments.length != 4) return null;

  final left = arguments[0];
  final top = arguments[1];
  final right = arguments[2];
  final bottom = arguments[3];

  switch ((left: left, top: top, right: right, bottom: bottom)) {
    case (
      left: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
      top: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
      right: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
      bottom: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
    ):
      return null;
    case (left: final l, top: final t, right: final r, bottom: final b)
        when l.toSource() == t.toSource() && t.toSource() == r.toSource() && r.toSource() == b.toSource():
      return 'EdgeInsets.all(${l.toSource()})';
    case (left: final l, top: final t, right: final r, bottom: final b)
        when l.toSource() == r.toSource() && t.toSource() == b.toSource():
      return 'EdgeInsets.symmetric(${[
        if (!isZeroExpression(l)) 'horizontal: ${l.toSource()}',
        if (!isZeroExpression(t)) 'vertical: ${t.toSource()}',
      ].join(', ')})';
    case (left: final l, top: final t, right: final r, bottom: final b) when [l, t, r, b].any(isZeroExpression):
      return 'EdgeInsets.only(${[
        if (!isZeroExpression(l)) 'left: ${l.toSource()}',
        if (!isZeroExpression(t)) 'top: ${t.toSource()}',
        if (!isZeroExpression(r)) 'right: ${r.toSource()}',
        if (!isZeroExpression(b)) 'bottom: ${b.toSource()}',
      ].join(', ')})';
    case _:
      return null;
  }
}

String? _onlyReplacement(InstanceCreationExpression node) {
  final left = node.argumentList.getArgumentByName('left')?.expression;
  final top = node.argumentList.getArgumentByName('top')?.expression;
  final right = node.argumentList.getArgumentByName('right')?.expression;
  final bottom = node.argumentList.getArgumentByName('bottom')?.expression;

  switch ((left: left, top: top, right: right, bottom: bottom)) {
    case (
      left: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
      top: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
      right: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
      bottom: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
    ):
      return null;
    case (left: final l?, top: final t?, right: final r?, bottom: final b?)
        when l.toSource() == r.toSource() && r.toSource() == b.toSource() && t.toSource() == b.toSource():
      return 'EdgeInsets.all(${l.toSource()})';
    case (left: final l, top: final t, right: final r, bottom: final b)
        when l?.toSource() == r?.toSource() && t?.toSource() == b?.toSource():
      return 'EdgeInsets.symmetric(${[
        if (l != null && !isZeroExpression(l)) 'horizontal: ${l.toSource()}',
        if (t != null && !isZeroExpression(t)) 'vertical: ${t.toSource()}',
      ].join(', ')})';
    case (left: final l, top: final t, right: final r, bottom: final b)
        when [l, t, r, b].any((e) => (e is IntegerLiteral && e.value == 0) || (e is DoubleLiteral && e.value == 0.0)):
      return 'EdgeInsets.only(${[
        if (l is IntegerLiteral && l.value != 0 || l is DoubleLiteral && l.value != 0.0) 'left: ${l?.toSource()}',
        if (t is IntegerLiteral && t.value != 0 || t is DoubleLiteral && t.value != 0.0) 'top: ${t?.toSource()}',
        if (r is IntegerLiteral && r.value != 0 || r is DoubleLiteral && r.value != 0.0) 'right: ${r?.toSource()}',
        if (b is IntegerLiteral && b.value != 0 || b is DoubleLiteral && b.value != 0.0) 'bottom: ${b?.toSource()}',
      ].join(', ')})';
    case (left: final l?, top: final t?, right: final r?, bottom: final b?):
      return 'EdgeInsets.fromLTRB(${[l.toSource(), t.toSource(), r.toSource(), b.toSource()].join(', ')})';
    case _:
      return null;
  }
}

String? _symmetricReplacement(InstanceCreationExpression node) {
  final vertical = node.argumentList.getArgumentByName('vertical')?.expression;
  final horizontal = node.argumentList.getArgumentByName('horizontal')?.expression;

  switch ((vertical: vertical, horizontal: horizontal)) {
    case (
      vertical: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
      horizontal: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
    ):
      return null;
    case (vertical: final v?, horizontal: final h?) when v.toSource() == h.toSource():
      return 'EdgeInsets.all(${v.toSource()})';
    case (vertical: final v?, horizontal: final h?) when [v, h].any(isZeroExpression):
      return 'EdgeInsets.symmetric(${[
        if (!isZeroExpression(v)) 'vertical: ${v.toSource()}',
        if (!isZeroExpression(h)) 'horizontal: ${h.toSource()}',
      ].join(', ')})';
    case _:
      return null;
  }
}
