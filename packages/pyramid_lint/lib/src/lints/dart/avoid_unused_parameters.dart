import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:yaml/yaml.dart' show YamlList;

import '../../utils/constants.dart';
import '../../utils/typedef.dart';
import '../../utils/visitors.dart';

@immutable
class AvoidUnusedParametersOptions {
  const AvoidUnusedParametersOptions({
    List<String>? excludedParameters,
  }) : _excludedParameters = excludedParameters;

  final List<String>? _excludedParameters;

  List<String> get excludedParameters => [
        ...?_excludedParameters,
      ];

  factory AvoidUnusedParametersOptions.fromJson(Json json) {
    final excludedParameters = switch (json['excluded_parameters']) {
      final YamlList excludedParameters => excludedParameters.cast<String>(),
      _ => null,
    };

    return AvoidUnusedParametersOptions(
      excludedParameters: excludedParameters,
    );
  }
}

class AvoidUnusedParameters extends DartLintRule {
  const AvoidUnusedParameters._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'Unused parameter should be removed.',
            correctionMessage: 'Consider removing the unused parameter.',
            url: '$dartLintDocUrl/${AvoidUnusedParameters.name}',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const name = 'avoid_unused_parameters';

  final AvoidUnusedParametersOptions options;

  factory AvoidUnusedParameters.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[AvoidUnusedParameters.name]?.json ?? {};
    final options = AvoidUnusedParametersOptions.fromJson(json);

    return AvoidUnusedParameters._(options);
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
        if (options.excludedParameters.contains(parameter.name?.lexeme)) {
          continue;
        }

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
