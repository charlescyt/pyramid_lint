import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AlwaysDeclareParameterNames extends DartLintRule {
  const AlwaysDeclareParameterNames()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'Parameter names should always be declared to enhance code readability and '
                'enable IDEs to provide code completion suggestions.',
            correctionMessage:
                'Consider declaring a descriptive parameter name.',
            url: url,
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'always_declare_parameter_names';
  static const url = '$dartLintDocUrl/$name';

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
