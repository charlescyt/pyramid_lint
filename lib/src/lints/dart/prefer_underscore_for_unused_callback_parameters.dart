import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/string_extensions.dart';
import '../../utils/visitors.dart';

class PreferUnderscoreForUnusedCallbackParameters extends DartLintRule {
  const PreferUnderscoreForUnusedCallbackParameters() : super(code: _code);

  static const name = 'prefer_underscore_for_unused_callback_parameters';

  static const _code = LintCode(
    name: name,
    problemMessage: 'The callback parameter is not used.',
    correctionMessage: 'Consider using underscores for the unused parameter.',
    url: '$dartLintDocUrl/${PreferUnderscoreForUnusedCallbackParameters.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

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
        final parameterElement = parameter.declaredElement;
        if (parameterElement == null) continue;

        final parameterName = parameterElement.name;
        if (parameterName.containsOnlyUnderscores) continue;

        var isParameterReferenced = false;
        final visitor = RecursiveSimpleIdentifierVisitor(
          onVisitSimpleIdentifier: (node) {
            if (node.staticElement == parameterElement) {
              isParameterReferenced = true;
            }
          },
        );

        node.body.accept(visitor);

        if (isParameterReferenced) continue;

        reporter.reportErrorForElement(code, parameterElement);
      }
    });
  }
}
