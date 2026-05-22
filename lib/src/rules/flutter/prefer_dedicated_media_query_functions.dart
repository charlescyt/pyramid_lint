import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../../utils/extensions/string.dart';
import '../../utils/type_checker.dart';
import '../../utils/utils.dart';

const Set<String> _mediaQueryProperties = {
  'accessibleNavigation',
  'alwaysUse24HourFormat',
  'boldText',
  'devicePixelRatio',
  'disableAnimations',
  'displayFeatures',
  'gestureSettings',
  'highContrast',
  'invertColors',
  'navigationMode',
  'onOffSwitchLabels',
  'orientation',
  'padding',
  'platformBrightness',
  'size',
  'systemGestureInsets',
  // TODO(charlescyt): Remove textScaleFactor later since it was deprecated.
  'textScaleFactor',
  'textScaler',
  'viewInsets',
  'viewPadding',
};

class PreferDedicatedMediaQueryFunctionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_dedicated_media_query_functions',
    'Using {0} will cause unnecessary rebuilds.',
    correctionMessage: 'Consider using {1} instead.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferDedicatedMediaQueryFunctionsRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final contextInfo = _extractContextInformationForPrefixedIdentifier(node);
    if (contextInfo == null) return;

    rule.reportAtNode(
      node,
      arguments: [contextInfo.problemDescription, contextInfo.dedicatedMethod],
    );
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final contextInfo = _extractContextInformationForPropertyAccess(node);
    if (contextInfo == null) return;

    rule.reportAtNode(
      node,
      arguments: [contextInfo.problemDescription, contextInfo.dedicatedMethod],
    );
  }
}

class ReplaceWithDedicatedMediaQueryFunction extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithDedicatedMediaQueryFunction',
    DartFixKindPriority.standard,
    'Replace with {0}',
  );

  ReplaceWithDedicatedMediaQueryFunction({required super.context});

  late String _replacement;

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  List<String>? get fixArguments => [_replacement];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final contextInfo = _extractContextInformation(node);
    if (contextInfo == null) return;

    _replacement = contextInfo.replacement;

    await builder.addDartFileEdit(file, (fileEdit) {
      fileEdit.addSimpleReplacement(range.node(node), contextInfo.replacement);
    });
  }
}

class _Context {
  final String problemDescription;
  final String dedicatedMethod;
  final String replacement;

  const _Context({
    required this.problemDescription,
    required this.dedicatedMethod,
    required this.replacement,
  });
}

_Context? _extractContextInformation(AstNode node) {
  if (node is PrefixedIdentifier) {
    return _extractContextInformationForPrefixedIdentifier(node);
  }
  if (node is PropertyAccess) {
    return _extractContextInformationForPropertyAccess(node);
  }

  return null;
}

_Context? _extractContextInformationForPrefixedIdentifier(
  PrefixedIdentifier node,
) {
  final propertyName = node.identifier.name;
  if (!_mediaQueryProperties.contains(propertyName)) return null;

  final targetType = node.prefix.staticType;
  if (targetType == null || !mediaQueryDataChecker.isExactlyType(targetType)) return null;

  final prefixElement = node.prefix.element;
  if (prefixElement is! LocalVariableElement) return null;

  final prefixNode = getAstNodeFromElement(prefixElement);
  if (prefixNode is! VariableDeclaration) return null;

  final argumentName = _contextArgumentName(prefixNode.initializer);
  if (argumentName == null) return null;

  final dedicatedMethod = 'MediaQuery.${propertyName}Of';
  return _Context(
    problemDescription: 'MediaQuery.of and accessing $propertyName',
    dedicatedMethod: dedicatedMethod,
    replacement: '$dedicatedMethod($argumentName)',
  );
}

_Context? _extractContextInformationForPropertyAccess(
  PropertyAccess node,
) {
  final propertyName = node.propertyName.name;
  if (!_mediaQueryProperties.contains(propertyName)) return null;

  final target = node.realTarget;
  final targetType = target.staticType;
  if (targetType == null || !mediaQueryDataChecker.isExactlyType(targetType)) return null;

  if (target is SimpleIdentifier) {
    final targetElement = target.element;
    if (targetElement is! LocalVariableElement) return null;

    final variableDeclaration = getAstNodeFromElement(targetElement);
    if (variableDeclaration is! VariableDeclaration) return null;

    final initializer = variableDeclaration.initializer;
    if (initializer is! MethodInvocation) return null;

    final methodName = initializer.methodName.name;
    if (methodName != 'maybeOf') return null;

    final initializerType = initializer.realTarget?.staticType;
    if (initializerType != null && mediaQueryChecker.isExactlyType(initializerType)) return null;

    final contextName = _contextArgumentName(initializer);
    if (contextName == null) return null;

    final dedicatedMethod = 'MediaQuery.maybe${propertyName.capitalize()}Of';
    return _Context(
      problemDescription: 'MediaQuery.maybeOf and accessing $propertyName',
      dedicatedMethod: dedicatedMethod,
      replacement: '$dedicatedMethod($contextName)',
    );
  }

  if (target is MethodInvocation) {
    final methodName = target.methodName.name;
    if (methodName != 'of' && methodName != 'maybeOf') return null;

    if (target.argumentList.arguments.length != 1) return null;

    final argumentSource = target.argumentList.arguments.first.toSource();
    final dedicatedMethod = methodName == 'of'
        ? 'MediaQuery.${propertyName}Of'
        : 'MediaQuery.maybe${propertyName.capitalize()}Of';

    return _Context(
      problemDescription: node.toSource(),
      dedicatedMethod: dedicatedMethod,
      replacement: '$dedicatedMethod($argumentSource)',
    );
  }

  return null;
}

String? _contextArgumentName(Expression? initializer) {
  if (initializer is! MethodInvocation) return null;

  final initializerType = initializer.realTarget?.staticType;
  if (initializerType != null && !mediaQueryChecker.isExactlyType(initializerType)) return null;

  if (initializer.methodName.name != 'of' && initializer.methodName.name != 'maybeOf') return null;

  if (initializer.argumentList.arguments.length != 1) return null;

  final argument = initializer.argumentList.arguments.first;
  if (argument is! SimpleIdentifier) return null;

  return argument.name;
}
