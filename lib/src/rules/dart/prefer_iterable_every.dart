import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';

import '../../utils/type_checker.dart';

class PreferIterableEveryRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_iterable_every',
    'Using Iterable.where(...).isEmpty is more verbose than Iterable.every.',
    correctionMessage: 'Consider using Iterable.every for better readability.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferIterableEveryRule()
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
    if (propertyName != 'isEmpty') return;

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

class ReplaceWithIterableEvery extends ResolvedCorrectionProducer {
  static const _replaceWithIterableEveryKind = FixKind(
    'dart.fix.replaceWithIterableEvery',
    DartFixKindPriority.standard,
    'Replace with Iterable.every',
  );

  ReplaceWithIterableEvery({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _replaceWithIterableEveryKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final propertyAccess = node;
    if (propertyAccess is! PropertyAccess) return;

    final target = propertyAccess.realTarget;
    if (target is! MethodInvocation) return;

    final arg = target.argumentList.arguments.singleOrNull;
    if (arg is! FunctionExpression) return;

    final argType = arg.staticType;
    if (argType is! FunctionType) return;
    if (!argType.returnType.isDartCoreBool) return;

    final body = arg.body;
    final expression = switch (body) {
      BlockFunctionBody(:final block) => block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
      ExpressionFunctionBody(:final expression) => expression,
      _ => null,
    };
    if (expression == null) return;

    final type = expression.staticType;
    if (type == null || !type.isDartCoreBool) return;

    switch (expression) {
      case PrefixExpression() || PrefixedIdentifier() || SimpleIdentifier() || MethodInvocation() || IsExpression():
      case BinaryExpression(:final operator) when !_isLogicalOperator(operator.type):
        break;
      case _:
        return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(target.methodName.sourceRange, 'every');
      switch (expression) {
        case PrefixExpression(:final operator):
          if (operator.type == TokenType.BANG) {
            builder.addDeletion(operator.sourceRange);
          }
        case PrefixedIdentifier(:final offset) || SimpleIdentifier(:final offset) || MethodInvocation(:final offset):
          builder.addSimpleInsertion(offset, '!');
        case IsExpression(:final isOperator, :final notOperator):
          if (notOperator != null) {
            builder.addDeletion(notOperator.sourceRange);
          } else {
            builder.addSimpleInsertion(isOperator.end, '!');
          }
        case BinaryExpression(:final operator) when !_isLogicalOperator(operator.type):
          final invertedToken = _getInvertedOperator(operator.type);
          if (invertedToken != null) {
            builder.addSimpleReplacement(operator.sourceRange, invertedToken.lexeme);
          }
        default:
          break;
      }
      builder.addDeletion(range.startEnd(propertyAccess.operator, propertyAccess.propertyName));
    });
  }
}

bool _isLogicalOperator(TokenType type) {
  return type == TokenType.AMPERSAND_AMPERSAND || type == TokenType.BAR_BAR;
}

TokenType? _getInvertedOperator(TokenType operator) {
  return switch (operator) {
    TokenType.EQ_EQ => TokenType.BANG_EQ,
    TokenType.BANG_EQ => TokenType.EQ_EQ,
    TokenType.GT => TokenType.LT_EQ,
    TokenType.LT => TokenType.GT_EQ,
    TokenType.GT_EQ => TokenType.LT,
    TokenType.LT_EQ => TokenType.GT,
    _ => null,
  };
}
