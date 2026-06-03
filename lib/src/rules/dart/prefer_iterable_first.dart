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

class PreferIterableFirstRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_iterable_first',
    '{0} is more verbose than iterable.first.',
    correctionMessage: 'Consider replacing {1} with {2}.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferIterableFirstRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addIndexExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitIndexExpression(IndexExpression node) {
    final targetType = node.realTarget.staticType;
    if (targetType == null || !listChecker.isAssignableFromType(targetType)) {
      return;
    }

    final indexExpression = node.index;
    if (indexExpression is! IntegerLiteral || indexExpression.value != 0) {
      return;
    }

    rule.reportAtNode(node, arguments: ['list[0]', node.toSource(), '${node.realTarget.toSource()}.first']);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final targetType = node.realTarget?.staticType;
    if (targetType == null || !iterableChecker.isAssignableFromType(targetType)) {
      return;
    }

    if (node.methodName.name != 'elementAt') return;

    final argument = node.argumentList.arguments.singleOrNull;
    if (argument is! IntegerLiteral || argument.value != 0) return;

    rule.reportAtNode(
      node,
      arguments: ['iterable.elementAt(0)', node.toSource(), '${node.realTarget?.toSource()}.first'],
    );
  }
}

class ReplaceWithIterableFirst extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithIterableFirst',
    DartFixKindPriority.standard,
    'Replace with Iterable.first',
  );

  ReplaceWithIterableFirst({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case IndexExpression(:final isCascaded, :final leftBracket, :final rightBracket)) {
      final replacement = isCascaded ? 'first' : '.first';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(
          range.startEnd(leftBracket, rightBracket),
          replacement,
        );
      });
    } else if (node case MethodInvocation(:final methodName, :final argumentList)) {
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(
          range.startEnd(methodName, argumentList),
          'first',
        );
      });
    }
  }
}
