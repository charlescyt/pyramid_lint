import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';

class PreferValueChanged extends PyramidLintRule {
  PreferValueChanged({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'There is a typedef ValueChanged<T> defined in flutter.',
          correctionMessage:
              'Consider using ValueChanged<{0}> instead of void Function({1}).',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'prefer_value_changed';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferValueChanged.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferValueChanged(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addGenericFunctionType((node) {
      final returnType = node.returnType?.type;
      if (returnType is! VoidType) return;

      final parameters = node.parameters.parameters;
      if (parameters.length != 1) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      final firstParameter = parameters.first;
      if (firstParameter is! SimpleFormalParameter) return;

      final firstParameterType = firstParameter.type?.type;
      if (firstParameterType == null) return;

      reporter.reportErrorForNode(
        code,
        node,
        [
          firstParameterType.getDisplayString(withNullability: false),
          firstParameter.toSource(),
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithValueChanged()];
}

class _ReplaceWithValueChanged extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addGenericFunctionType((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final parameters = node.parameters.parameters;
      if (parameters.length != 1) return;

      final firstParameter = parameters.first;
      if (firstParameter is! SimpleFormalParameter) return;

      final firstParameterType = firstParameter.type?.type;
      if (firstParameterType == null) return;

      final replacement = node.question == null
          ? 'ValueChanged<${firstParameter.type}>'
          : 'ValueChanged<${firstParameter.type}>?';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with $replacement',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          replacement,
        );
      });
    });
  }
}
