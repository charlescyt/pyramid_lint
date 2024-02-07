import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';

class PreferVoidCallback extends DartLintRule {
  const PreferVoidCallback()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'There is a typedef VoidCallback defined in flutter.',
            correctionMessage:
                'Consider using VoidCallback instead of void Function().',
            url: '$flutterLintDocUrl/${PreferVoidCallback.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'prefer_void_callback';

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

      reporter.reportErrorForNode(code, node);
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

      final replacement =
          node.question == null ? 'VoidCallback' : 'VoidCallback?';

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
