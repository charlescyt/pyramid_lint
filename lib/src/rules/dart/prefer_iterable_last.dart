import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../../utils/type_checker.dart';

class PreferIterableLastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_iterable_last',
    '{0} is more verbose than iterable.last.',
    correctionMessage: 'Consider replacing {1} with {2}.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferIterableLastRule()
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
    if (indexExpression is! BinaryExpression || indexExpression.operator.type != TokenType.MINUS) {
      return;
    }

    final leftOperand = indexExpression.leftOperand;
    if (leftOperand is! PrefixedIdentifier ||
        leftOperand.prefix.name != node.realTarget.toSource() ||
        leftOperand.identifier.name != 'length') {
      return;
    }

    final rightOperand = indexExpression.rightOperand;
    if (rightOperand is! IntegerLiteral || rightOperand.value != 1) {
      return;
    }

    rule.reportAtNode(
      node,
      arguments: ['list[list.length - 1]', node.toSource(), '${node.realTarget.toSource()}.last'],
    );
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final targetType = node.realTarget?.staticType;
    if (targetType == null || !iterableChecker.isAssignableFromType(targetType)) {
      return;
    }

    if (node.methodName.name != 'elementAt') return;

    final argument = node.argumentList.arguments.singleOrNull;
    if (argument is! BinaryExpression || argument.operator.type != TokenType.MINUS) return;

    final leftOperand = argument.leftOperand;
    if (leftOperand is! PrefixedIdentifier ||
        leftOperand.prefix.name != node.realTarget?.toSource() ||
        leftOperand.identifier.name != 'length') {
      return;
    }

    final rightOperand = argument.rightOperand;
    if (rightOperand is! IntegerLiteral || rightOperand.value != 1) {
      return;
    }

    rule.reportAtNode(
      node,
      arguments: ['iterable.elementAt(iterable.length - 1)', node.toSource(), '${node.realTarget?.toSource()}.last'],
    );
  }
}

class ReplaceWithIterableLast extends ResolvedCorrectionProducer {
  static const _replaceWithIterableLastKind = FixKind(
    'dart.fix.replaceWithIterableLast',
    DartFixKindPriority.standard,
    'Replace with Iterable.last',
  );

  ReplaceWithIterableLast({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _replaceWithIterableLastKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case IndexExpression(:final isCascaded, :final leftBracket, :final rightBracket)) {
      final replacement = isCascaded ? 'last' : '.last';
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
          'last',
        );
      });
    }
  }
}
