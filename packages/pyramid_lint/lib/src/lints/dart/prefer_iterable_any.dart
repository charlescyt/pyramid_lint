import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class PreferIterableAny extends PyramidLintRule {
  PreferIterableAny({required super.options})
      : super(
          name: name,
          problemMessage:
              'Using Iterable.where(...).isNotEmpty is more verbose than Iterable.any.',
          correctionMessage:
              'Consider using Iterable.any for better readability.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const name = 'prefer_iterable_any';
  static const url = '$dartLintDocUrl/$name';

  factory PreferIterableAny.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferIterableAny(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
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

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterableAny()];
}

class _ReplaceWithIterableAny extends DartFix {
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Iterable.any',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(target.methodName.sourceRange, 'any');
        builder.addDeletion(range.startEnd(node.operator, node.propertyName));
      });
    });
  }
}
