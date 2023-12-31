import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class PreferAsyncAwait extends DartLintRule {
  const PreferAsyncAwait() : super(code: _code);

  static const name = 'prefer_async_await';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Using Future.then() decreases readability.',
    correctionMessage: 'Consider using async/await instead.',
    url: '$docUrl#${PreferAsyncAwait.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final target = node.realTarget;
      if (target == null) return;

      final targetType = target.staticType;
      if (targetType == null || !targetType.isDartAsyncFuture) return;

      final methodName = node.methodName.name;
      if (methodName != 'then') return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
