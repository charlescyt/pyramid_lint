import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';

class PreferVoidCallback extends PyramidLintRule<void> {
  PreferVoidCallback({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'There is a typedef VoidCallback defined in flutter.',
        correctionMessage:
            'Consider using VoidCallback instead of void Function().',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'prefer_void_callback';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferVoidCallback.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferVoidCallback(options: options);
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
      if (parameters.isNotEmpty) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      reporter.atNode(node, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithVoidCallBack()];
}

class _ReplaceWithVoidCallBack extends DartFix {
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

      final replacement = node.question == null
          ? 'VoidCallback'
          : 'VoidCallback?';

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
