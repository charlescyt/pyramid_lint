import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extensions.dart';
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
  'onOffSwitchLabels',
  'orientation',
  'padding',
  'platformBrightness',
  'size',
  'systemGestureInsets',
  // TODO(Charles): Remove textScaleFactor later since it was deprecated.
  'textScaleFactor',
  'textScaler',
  'viewInsets',
  'viewPadding',
];

class PreferDedicatedMediaQueryMethod extends DartLintRule {
  const PreferDedicatedMediaQueryMethod() : super(code: _code);

  static const name = 'prefer_dedicated_media_query_method';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Using {0} will cause unnecessary rebuilds.',
    correctionMessage: 'Consider using {1} instead.',
    url: '$docUrl#${PreferDedicatedMediaQueryMethod.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addPrefixedIdentifier((node) {
      final targetType = node.prefix.staticType;

      const mediaQueryDataChecker = TypeChecker.fromName(
        'MediaQueryData',
        packageName: 'flutter',
      );

      if (targetType == null ||
          !mediaQueryDataChecker.isExactlyType(targetType)) return;

      /// Lint should only work if the mediaQueryData variable is declared locally.
      if (node.prefix.staticElement is! LocalVariableElement) {
        return;
      }

      final propertyName = node.identifier.name;
      if (!_properties.contains(propertyName)) return;

      final actual = node.toSource();
      final expected = 'MediaQuery.${propertyName}Of(context)';

      reporter.reportErrorForNode(
        code,
        node,
        [
          actual,
          expected,
        ],
      );
    });

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
          'MediaQuery.of(context).$propertyName',
          'MediaQuery.$newMethodName()',
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithDedicatedMethod()];
}

class _ReplaceWithDedicatedMethod extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final methodName = node.identifier.name;

      final dedicatedMethod = 'MediaQuery.${methodName}Of(context)';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Use $dedicatedMethod',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          dedicatedMethod,
        );
      });
    });

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
        final deletionRange = range.startEnd(node.operator, node.propertyName);
        builder.addDeletion(deletionRange);
        builder.addSimpleReplacement(
          target.methodName.sourceRange,
          newMethodName,
        );
      });
    });
  }
}
