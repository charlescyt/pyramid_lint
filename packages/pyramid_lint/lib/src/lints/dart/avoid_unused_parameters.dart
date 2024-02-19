import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:yaml/yaml.dart' show YamlList;

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/typedef.dart';
import '../../utils/visitors.dart';

@immutable
class AvoidUnusedParametersOptions {
  const AvoidUnusedParametersOptions({
    List<String>? ignoredParameters,
  }) : _ignoredParameters = ignoredParameters;

  final List<String>? _ignoredParameters;

  List<String> get ignoredParameters => [
        ...?_ignoredParameters,
      ];

  factory AvoidUnusedParametersOptions.fromJson(Json json) {
    final ignoredParameters = switch (json['ignored_parameters']) {
      final YamlList excludedParameters => excludedParameters.cast<String>(),
      _ => null,
    };

    return AvoidUnusedParametersOptions(
      ignoredParameters: ignoredParameters,
    );
  }
}

class AvoidUnusedParameters
    extends PyramidLintRule<AvoidUnusedParametersOptions> {
  AvoidUnusedParameters({required super.options})
      : super(
          name: name,
          problemMessage: 'Unused parameter should be removed.',
          correctionMessage: 'Consider removing the unused parameter.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const name = 'avoid_unused_parameters';
  static const url = '$dartLintDocUrl/$name';

  factory AvoidUnusedParameters.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: AvoidUnusedParametersOptions.fromJson,
    );

    return AvoidUnusedParameters(options: options);
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
        if (options.params.ignoredParameters.contains(parameter.name?.lexeme)) {
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

      classDeclaration.declaredElement?.isAbstract;
      final isAbstractClass = classDeclaration.abstractKeyword != null;
      if (isAbstractClass) return;

      node.declaredElement?.hasOverride;
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
