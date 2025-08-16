import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/string_extension.dart';
import '../../utils/visitors.dart';

class PreferUnderscoreForUnusedCallbackParameters extends PyramidLintRule {
  PreferUnderscoreForUnusedCallbackParameters({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'The callback parameter is not used.',
        correctionMessage: 'Consider using underscores for the unused parameter.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'prefer_underscore_for_unused_callback_parameters';
  static const url = '$dartLintDocUrl/$ruleName';

  factory PreferUnderscoreForUnusedCallbackParameters.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferUnderscoreForUnusedCallbackParameters(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionExpression((node) {
      final parameters = node.parameters?.parameters;
      if (parameters == null) return;

      final parent = node.parent;
      if (parent is FunctionDeclaration) return;

      for (final parameter in parameters) {
        final parameterElement = parameter.declaredFragment?.element;
        if (parameterElement == null) continue;

        final parameterName = parameterElement.name3;
        if (parameterName?.containsOnlyUnderscores == true) continue;

        var isParameterReferenced = false;
        final visitor = RecursiveSimpleIdentifierVisitor(
          onVisitSimpleIdentifier: (node) {
            if (node.element == parameterElement) {
              isParameterReferenced = true;
            }
          },
        );

        node.body.accept(visitor);

        if (isParameterReferenced) continue;

        reporter.atElement2(parameterElement, code);
      }
    });
  }
}
