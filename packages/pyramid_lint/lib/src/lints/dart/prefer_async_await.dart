import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class PreferAsyncAwait extends PyramidLintRule {
  PreferAsyncAwait({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Using Future.then() decreases readability.',
        correctionMessage: 'Consider using async/await instead.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'prefer_async_await';
  static const url = '$dartLintDocUrl/$ruleName';

  factory PreferAsyncAwait.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferAsyncAwait(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final target = node.realTarget;
      if (target == null) return;

      final targetType = target.staticType;
      if (targetType == null || !targetType.isDartAsyncFuture) return;

      final methodName = node.methodName.name;
      if (methodName != 'then') return;

      reporter.atNode(node, code);
    });
  }
}
