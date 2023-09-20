import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/string_extensions.dart';

const List<String> _properties = [
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
  'orientation',
  'padding',
  'platformBrightness',
  'size',
  'systemGestureInsets',
  'textScaleFactor',
  'viewInsets',
  'viewPadding',
];

class PreferDedicatedMediaQueryMethod extends DartLintRule {
  const PreferDedicatedMediaQueryMethod() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_dedicated_media_query_method',
    problemMessage:
        'Using MediaQuery.of(context).{0} will cause unnecessary rebuilds.',
    correctionMessage: 'Use MediaQuery.{1}(context) instead.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
      final propertyName = node.propertyName.name;
      if (!_properties.contains(propertyName)) return;

      final target = node.realTarget;
      if (target is! MethodInvocation) return;

      final methodTarget = target.realTarget;
      if (methodTarget is! Identifier || methodTarget.name != 'MediaQuery') {
        return;
      }

      final methodName = target.methodName.name;
      if (methodName != 'of' && methodName != 'maybeOf') return;

      final newMethodName = methodName == 'of'
          ? '${propertyName}Of'
          : 'maybe${propertyName.capitalize()}Of';

      reporter.reportErrorForNode(
        code,
        node,
        [
          propertyName,
          newMethodName,
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [PreferDedicatedMediaQueryFix()];
}

class PreferDedicatedMediaQueryFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPropertyAccess((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final target = node.realTarget;
      if (target is! MethodInvocation) return;

      final propertyName = node.propertyName.name;
      final methodName = target.methodName.name;
      final newMethodName = methodName == 'of'
          ? '${propertyName}Of'
          : 'maybe${propertyName.capitalize()}Of';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Use MediaQuery.$newMethodName(context)',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(node.operator.sourceRange);
        builder.addDeletion(node.propertyName.sourceRange);
        builder.addSimpleReplacement(
          target.methodName.sourceRange,
          newMethodName,
        );
      });
    });
  }
}
