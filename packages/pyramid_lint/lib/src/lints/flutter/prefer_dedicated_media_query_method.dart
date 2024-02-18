import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/string_extension.dart';
import '../../utils/type_checker.dart';
import '../../utils/utils.dart';

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

class PreferDedicatedMediaQueryMethod extends PyramidLintRule {
  PreferDedicatedMediaQueryMethod({required super.options})
      : super(
          name: name,
          problemMessage: 'Using {0} will cause unnecessary rebuilds.',
          correctionMessage: 'Consider using {1} instead.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const name = 'prefer_dedicated_media_query_method';
  static const url = '$flutterLintDocUrl/$name';

  factory PreferDedicatedMediaQueryMethod.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferDedicatedMediaQueryMethod(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addPrefixedIdentifier((node) {
      final propertyName = node.identifier.name;
      if (!_properties.contains(propertyName)) return;

      final targetType = node.prefix.staticType;
      if (targetType == null ||
          !mediaQueryDataChecker.isExactlyType(targetType)) return;

      final prefixElement = node.prefix.staticElement;

      // Lint should only work if the MediaQueryData variable is declared locally
      // and initialized with MediaQuery.of(context).
      if (prefixElement is! LocalVariableElement) return;

      final prefixNode = getAstNodeFromElement(prefixElement);
      if (prefixNode is! VariableDeclaration) return;
      if (!_isInitializedWithMediaQueryOfOrMaybeOf(prefixNode)) return;

      final dedicatedMethod = 'MediaQuery.${propertyName}Of';

      reporter.reportErrorForNode(
        code,
        node,
        [
          'MediaQuery.of and accessing $propertyName',
          dedicatedMethod,
        ],
      );
    });

    context.registry.addPropertyAccess((node) {
      final propertyName = node.propertyName.name;
      if (!_properties.contains(propertyName)) return;

      final target = node.realTarget;
      final targetType = target.staticType;
      if (targetType == null ||
          !mediaQueryDataChecker.isExactlyType(targetType)) return;

      if (target is SimpleIdentifier) {
        final prefixElement = target.staticElement;

        // Lint should only work if the MediaQueryData variable is declared locally
        // and initialized with MediaQuery.maybeOf(context).
        if (prefixElement is! LocalVariableElement) return;

        final prefixNode = getAstNodeFromElement(prefixElement);
        if (prefixNode is! VariableDeclaration) return;
        if (!_isInitializedWithMediaQueryOfOrMaybeOf(prefixNode)) return;

        final dedicatedMethod =
            'MediaQuery.maybe${propertyName.capitalize()}Of';

        reporter.reportErrorForNode(
          code,
          node,
          [
            'MediaQuery.maybeOf and accessing $propertyName',
            dedicatedMethod,
          ],
        );
      }

      if (target is MethodInvocation) {
        final methodName = target.methodName.name;
        if (methodName != 'of' && methodName != 'maybeOf') return;

        final dedicatedMethod = methodName == 'of'
            ? 'MediaQuery.${propertyName}Of'
            : 'MediaQuery.maybe${propertyName.capitalize()}Of';

        reporter.reportErrorForNode(
          code,
          node,
          [
            node.toSource(),
            dedicatedMethod,
          ],
        );
      }
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

      final prefixElement = node.prefix.staticElement;
      if (prefixElement is! LocalVariableElement) return;

      final prefixNode = getAstNodeFromElement(prefixElement);
      if (prefixNode is! VariableDeclaration) return;

      final initializer = prefixNode.initializer;
      if (initializer is! MethodInvocation) return;
      if (initializer.methodName.name != 'of') return;

      final initializerType = initializer.realTarget?.staticType;
      if (initializerType != null &&
          mediaQueryChecker.isExactlyType(initializerType)) return;

      if (initializer.argumentList.arguments.length != 1) return;

      final argument = initializer.argumentList.arguments.first;
      if (argument is! SimpleIdentifier) return;

      final methodName = node.identifier.name;
      final argumentName = argument.name;
      final dedicatedMethod = 'MediaQuery.${methodName}Of($argumentName)';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with $dedicatedMethod',
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

      if (target is SimpleIdentifier) {
        final targetElement = target.staticElement;

        // Lint should only work if the MediaQueryData variable is declared locally
        // and initialized with MediaQuery.maybeOf(context).
        if (targetElement is! LocalVariableElement) return;

        final prefixNode = getAstNodeFromElement(targetElement);
        if (prefixNode is! VariableDeclaration) return;

        final initializer = prefixNode.initializer;
        if (initializer is! MethodInvocation) return;
        if (initializer.methodName.name != 'maybeOf') return;

        final initializerType = initializer.realTarget?.staticType;
        if (initializerType != null &&
            mediaQueryChecker.isExactlyType(initializerType)) return;

        if (initializer.argumentList.arguments.length != 1) return;

        final argument = initializer.argumentList.arguments.first;
        if (argument is! SimpleIdentifier) return;

        final methodName = node.propertyName.name;
        final argumentName = argument.name;
        final dedicatedMethod = 'MediaQuery.${methodName}Of($argumentName)';

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with $dedicatedMethod',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            dedicatedMethod,
          );
        });
      }

      if (target is MethodInvocation) {
        final propertyName = node.propertyName.name;
        final methodName = target.methodName.name;

        if (target.argumentList.arguments.length != 1) return;
        final argumentName = target.argumentList.arguments.first.toSource();

        final newMethodName = methodName == 'of'
            ? '${propertyName}Of'
            : 'maybe${propertyName.capitalize()}Of';

        final dedicatedMethod = 'MediaQuery.$newMethodName($argumentName)';

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with $dedicatedMethod',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            dedicatedMethod,
          );
        });
      }
    });
  }
}

/// Check if the VariableDeclaration is initialized with MediaQuery.of(context)
/// or MediaQuery.maybeOf(context).
bool _isInitializedWithMediaQueryOfOrMaybeOf(VariableDeclaration node) {
  final initializer = node.initializer;
  if (initializer is! MethodInvocation) return false;

  final initializerType = initializer.realTarget?.staticType;
  if (initializerType != null &&
      !mediaQueryChecker.isExactlyType(initializerType)) return false;

  if (initializer.methodName.name != 'of' &&
      initializer.methodName.name != 'maybeOf') return false;

  if (initializer.argumentList.arguments.length != 1) return false;

  final argument = initializer.argumentList.arguments.first;
  if (argument is! SimpleIdentifier) return false;

  return true;
}
