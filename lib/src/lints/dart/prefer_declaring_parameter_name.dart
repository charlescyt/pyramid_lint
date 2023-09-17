import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferDeclaringParameterName extends DartLintRule {
  const PreferDeclaringParameterName() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_declaring_parameter_name',
    problemMessage:
        'Not declaring parameter name decreases code readability and '
        'the IDEs code completion will not be able to suggest the parameter name.',
    correctionMessage: 'Try declaring parameter name.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleFormalParameter((node) {
      if (node.name == null) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
