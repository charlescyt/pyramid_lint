import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/rule_options.dart';

@immutable
class AvoidUnusedParametersOptions {
  final List<String> ignoredParameters;

  const AvoidUnusedParametersOptions({List<String>? ignoredParameters})
    : ignoredParameters = ignoredParameters ?? const [];

  factory AvoidUnusedParametersOptions.fromMap(Map<String, Object?> map) {
    final ignoredParameters = switch (map['ignored_parameters']) {
      final List<Object?> ignoredParameters => ignoredParameters.whereType<String>().toList(),
      _ => const <String>[],
    };

    return AvoidUnusedParametersOptions(ignoredParameters: ignoredParameters);
  }

  factory AvoidUnusedParametersOptions.fromRuleContext(RuleContext context) {
    final map = readPluginRuleOptions(context, AvoidUnusedParametersRule.code.lowerCaseName);
    return AvoidUnusedParametersOptions.fromMap(map);
  }

  bool isIgnored(String? name) => name != null && ignoredParameters.contains(name);
}

class AvoidUnusedParametersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unused_parameters',
    'Unused parameter should be removed.',
    correctionMessage: 'Consider removing the unused parameter.',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidUnusedParametersRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final options = AvoidUnusedParametersOptions.fromRuleContext(context);
    final visitor = _Visitor(this, context, options);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  final AvoidUnusedParametersOptions options;

  const _Visitor(this.rule, this.context, this.options);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final parameters = node.functionExpression.parameters?.parameters;
    if (parameters == null) return;

    _reportUnusedParameters(parameters, node.functionExpression.body);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;
    if (classDeclaration.abstractKeyword != null) return;
    if (node.metadata.any((annotation) => annotation.name.name == 'override')) return;

    final parameters = node.parameters?.parameters;
    if (parameters == null) return;

    _reportUnusedParameters(parameters, node.body);
  }

  void _reportUnusedParameters(
    List<FormalParameter> parameters,
    FunctionBody body,
  ) {
    if (parameters.isEmpty) return;

    final referencedParameterElements = _collectReferencedParameterElements(body);

    for (final parameter in parameters) {
      if (options.isIgnored(parameter.name?.lexeme)) continue;

      final parameterElement = parameter.declaredFragment?.element;
      if (parameterElement == null) continue;
      if (referencedParameterElements.contains(parameterElement)) continue;

      rule.reportAtNode(parameter);
    }
  }

  Set<Element> _collectReferencedParameterElements(FunctionBody body) {
    final collector = _ReferencedParameterCollector();
    body.accept(collector);
    return collector.referencedParameters;
  }
}

class _ReferencedParameterCollector extends RecursiveAstVisitor<void> {
  final Set<Element> referencedParameters = {};

  _ReferencedParameterCollector();

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final element = node.element;
    if (element is! VariableElement) return;
    referencedParameters.add(element);
  }
}
