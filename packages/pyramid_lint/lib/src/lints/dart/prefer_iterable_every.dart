import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/token_type_extension.dart';
import '../../utils/type_checker.dart';
import '../../utils/utils.dart';

class PreferIterableEvery extends PyramidLintRule {
  PreferIterableEvery({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Using Iterable.where(...).isEmpty is more verbose than Iterable.every.',
        correctionMessage: 'Consider using Iterable.every for better readability.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'prefer_iterable_every';
  static const url = '$dartLintDocUrl/$ruleName';

  factory PreferIterableEvery.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferIterableEvery(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
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

      reporter.atNode(node, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterableEvery()];
}

class _ReplaceWithIterableEvery extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPropertyAccess((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final target = node.realTarget;
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
        case BinaryExpression(:final operator) when !operator.type.isLogicalOperator:
          break;
        case _:
          return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Iterable.every',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
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
          case BinaryExpression(:final operator) when !operator.type.isLogicalOperator:
            final token = operator;
            final invertedToken = getInvertedOperator(token.type);
            if (invertedToken != null) {
              builder.addSimpleReplacement(token.sourceRange, invertedToken.lexeme);
            }
        }
        builder.addDeletion(range.startEnd(node.operator, node.propertyName));
      });
    });
  }
}
