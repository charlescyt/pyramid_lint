import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidMutableGlobalVariables extends PyramidLintRule {
  AvoidMutableGlobalVariables({required super.options})
      : super(
          name: name,
          problemMessage: 'Using mutable global variables is discouraged.',
          correctionMessage:
              'Consider declaring the variable as final or const.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const name = 'avoid_mutable_global_variables';
  static const url = '$dartLintDocUrl/$name';

  factory AvoidMutableGlobalVariables.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidMutableGlobalVariables(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addTopLevelVariableDeclaration((node) {
      final variables = node.variables.variables;
      final isConstOrFinal = variables.every((v) => v.isConst || v.isFinal);
      if (isConstOrFinal) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
