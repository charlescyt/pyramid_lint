import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class PreferAsyncCallback extends DartLintRule {
  const PreferAsyncCallback() : super(code: _code);

  static const name = 'prefer_async_callback';

  static const _code = LintCode(
    name: name,
    problemMessage: 'There is a typedef AsyncCallback defined in flutter.',
    correctionMessage:
        'Try using AsyncCallback instead of Future<void> Function().',
    url: '$docUrl#${PreferAsyncCallback.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addGenericFunctionType((node) {
      final returnType = node.returnType?.type;
      if (returnType?.isDartAsyncFuture != true) return;

      final parameters = node.parameters.parameters;
      if (parameters.isNotEmpty) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithAsyncCallback()];
}

class _ReplaceWithAsyncCallback extends DartFix {
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with AsyncCallback',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          'AsyncCallback',
        );
      });
    });
  }
}
