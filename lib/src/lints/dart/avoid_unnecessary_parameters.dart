import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/visitors.dart';

class AvoidUnusedParameters extends DartLintRule {
  const AvoidUnusedParameters({
    this.excludedParameters = const [],
  }) : super(code: _code);

  static const name = 'avoid_unused_parameters';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Unused parameter should be removed.',
    correctionMessage: 'Try removing the unused parameter.',
    url: '$docUrl#${AvoidUnusedParameters.name}',
    errorSeverity: ErrorSeverity.WARNING,
  );

  final List<String> excludedParameters;

  factory AvoidUnusedParameters.fromConfigs(CustomLintConfigs configs) {
    final options = configs.rules[AvoidUnusedParameters.name];
    final jsonList = options?.json['excluded_parameters'] as List<Object?>?;
    final excludedParameters = jsonList?.cast<String>() ?? [];

    return AvoidUnusedParameters(
      excludedParameters: excludedParameters,
    );
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final parameters = node.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return;

      final body = node.functionExpression.body;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );
      body.accept(visitor);

      for (final parameter in parameters) {
        if (excludedParameters.contains(parameter.name?.lexeme)) continue;

        final parameterElement = parameter.declaredElement;
        if (parameterElement == null) continue;

        var isParameterReferenced = false;
        for (final simpleIdentifier in simpleIdentifiers) {
          if (simpleIdentifier.staticElement == parameterElement) {
            isParameterReferenced = true;
            break;
          }
        }

        if (isParameterReferenced) continue;

        reporter.reportErrorForNode(code, parameter);
      }
    });

    context.registry.addMethodDeclaration((node) {
      final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
      if (classDeclaration == null) return;

      final isAbstractClass = classDeclaration.abstractKeyword != null;
      if (isAbstractClass) return;

      final isOverrideMethod =
          node.metadata.any((e) => e.name.name == 'override');
      if (isOverrideMethod) return;

      final parameters = node.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return;

      final body = node.body;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );
      body.accept(visitor);

      for (final parameter in parameters) {
        final parameterElement = parameter.declaredElement;
        if (parameterElement == null) continue;

        var isParameterReferenced = false;
        for (final simpleIdentifier in simpleIdentifiers) {
          if (simpleIdentifier.staticElement == parameterElement) {
            isParameterReferenced = true;
            break;
          }
        }

        if (isParameterReferenced) continue;

        reporter.reportErrorForNode(code, parameter);
      }
    });
  }
}
