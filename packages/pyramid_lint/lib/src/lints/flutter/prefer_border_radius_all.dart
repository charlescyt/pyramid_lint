import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class PreferBorderRadiusAll extends PyramidLintRule {
  PreferBorderRadiusAll({required super.options})
    : super(
        name: ruleName,
        problemMessage:
            'BorderRadius.circular is not a const constructor and it uses const '
            'constructor BorderRadius.all internally.',
        correctionMessage: 'Consider replacing BorderRadius.circular with BorderRadius.all.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'prefer_border_radius_all';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferBorderRadiusAll.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferBorderRadiusAll(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !borderRadiusChecker.isExactlyType(type)) return;

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier?.name != 'circular') return;

      reporter.atNode(node.constructorName, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithBorderRadiusAll()];
}

class _ReplaceWithBorderRadiusAll extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.constructorName.sourceRange)) {
        return;
      }

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with BorderRadius.all',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(constructorNameIdentifier.sourceRange, 'all(Radius.circular');
        builder.addSimpleInsertion(node.endToken.offset, ')');
      });
    });
  }
}
