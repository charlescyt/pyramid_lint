import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class PreferBorderFromBorderSide extends PyramidLintRule {
  PreferBorderFromBorderSide({required super.options})
    : super(
        name: ruleName,
        problemMessage:
            'Border.all is not a const constructor and it uses const constructor '
            'Border.fromBorderSide internally.',
        correctionMessage: 'Consider replacing Border.all with Border.fromBorderSide.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'prefer_border_from_border_side';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferBorderFromBorderSide.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferBorderFromBorderSide(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !borderChecker.isExactlyType(type)) return;

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier?.name != 'all') return;

      reporter.atNode(node.constructorName, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithBorderFromBorderSide()];
}

class _ReplaceWithBorderFromBorderSide extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.constructorName.sourceRange)) {
        return;
      }

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Border.fromBorderSide',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(constructorNameIdentifier.sourceRange, 'fromBorderSide(BorderSide');
        builder.addSimpleInsertion(node.endToken.offset, '),');
      });
    });
  }
}
