import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AlwaysSpecifyParameterNames extends PyramidLintRule {
  AlwaysSpecifyParameterNames({required super.options})
    : super(
        name: ruleName,
        problemMessage:
            'Parameter names should always be specified to enhance code readability '
            'and enable IDEs to provide code completion suggestions.',
        correctionMessage: 'Consider declaring a descriptive parameter name.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'always_specify_parameter_names';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AlwaysSpecifyParameterNames.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return AlwaysSpecifyParameterNames(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleFormalParameter((node) {
      if (node.name == null) {
        reporter.atNode(node, code);
      }
    });
  }
}
