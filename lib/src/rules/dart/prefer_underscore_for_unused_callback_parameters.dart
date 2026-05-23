import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/extensions/string.dart';

class PreferUnderscoreForUnusedCallbackParametersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_underscore_for_unused_callback_parameters',
    'The callback parameter is not used.',
    correctionMessage: 'Consider using underscores for the unused parameter.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferUnderscoreForUnusedCallbackParametersRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addFunctionExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is FunctionDeclaration) return;

    final parameters = node.parameters?.parameters;
    if (parameters == null || parameters.isEmpty) return;

    final referencedParameterElements = _collectReferencedParameterElements(node.body);

    for (final parameter in parameters) {
      final parameterElement = parameter.declaredFragment?.element;
      if (parameterElement == null) continue;

      final parameterName = parameterElement.name;
      if (parameterName?.isJustUnderscores == true) continue;
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
    if (element is! FormalParameterElement) return;
    referencedParameters.add(element);
  }
}
