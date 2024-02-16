import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AvoidMutableGlobalVariables extends DartLintRule {
  const AvoidMutableGlobalVariables()
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'Using mutable global variables is discouraged.',
            correctionMessage:
                'Consider declaring the variable as final or const.',
            url: '$dartLintDocUrl#${AvoidMutableGlobalVariables.name}',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const name = 'avoid_mutable_global_variables';

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
