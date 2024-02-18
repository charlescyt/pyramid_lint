import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class PreferIterableLast extends PyramidLintRule {
  PreferIterableLast({required super.options})
      : super(
          name: name,
          problemMessage: '{0} is more verbose than iterable.last.',
          correctionMessage: 'Consider replacing {1} with {2}.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const name = 'prefer_iterable_last';
  static const url = '$dartLintDocUrl/$name';

  factory PreferIterableLast.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferIterableLast(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIndexExpression((node) {
      final targetType = node.realTarget.staticType;
      if (targetType == null || !listChecker.isAssignableFromType(targetType)) {
        return;
      }

      final indexExpression = node.index;
      if (indexExpression is! BinaryExpression ||
          indexExpression.operator.type != TokenType.MINUS) return;

      final leftOperand = indexExpression.leftOperand;
      if (leftOperand is! PrefixedIdentifier ||
          leftOperand.prefix.name != node.realTarget.toSource() ||
          leftOperand.identifier.name != 'length') return;

      final rightOperand = indexExpression.rightOperand;
      if (rightOperand is! IntegerLiteral || rightOperand.value != 1) {
        return;
      }

      reporter.reportErrorForNode(
        code,
        node,
        [
          'list[list.length - 1]',
          node.toSource(),
          '${node.realTarget.toSource()}.last',
        ],
      );
    });

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'elementAt') return;

      if (node.argumentList.arguments.length != 1) return;

      final argument = node.argumentList.arguments.first;
      if (argument is! BinaryExpression ||
          argument.operator.type != TokenType.MINUS) return;

      final leftOperand = argument.leftOperand;
      if (leftOperand is! PrefixedIdentifier ||
          leftOperand.prefix.name != node.realTarget?.toSource() ||
          leftOperand.identifier.name != 'length') return;

      final rightOperand = argument.rightOperand;
      if (rightOperand is! IntegerLiteral || rightOperand.value != 1) {
        return;
      }

      reporter.reportErrorForNode(
        code,
        node,
        [
          'iterable.elementAt(iterable.length - 1)',
          node.toSource(),
          '${node.realTarget?.toSource()}.last',
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterableLast()];
}

class _ReplaceWithIterableLast extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIndexExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.last',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final replacement = node.isCascaded ? 'last' : '.last';
        builder.addSimpleReplacement(
          range.startEnd(node.leftBracket, node.rightBracket),
          replacement,
        );
      });
    });

    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.last',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.startEnd(node.methodName, node.argumentList),
          'last',
        );
      });
    });
  }
}
