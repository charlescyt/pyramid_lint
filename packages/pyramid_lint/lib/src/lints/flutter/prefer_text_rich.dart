import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class PreferTextRich extends PyramidLintRule {
  PreferTextRich({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'RichText does not inherit TextStyle from DefaultTextStyle.',
        correctionMessage: 'Consider replacing RichText with Text.rich.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'prefer_text_rich';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferTextRich.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferTextRich(options: options);
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
      if (type == null || !richTextChecker.isAssignableFromType(type)) return;

      reporter.atNode(node.constructorName, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithTextRich()];
}

class _ReplaceWithTextRich extends DartFix {
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Text.rich',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final textArgument = node.argumentList.findArgumentByName('text');

        builder.addSimpleReplacement(node.constructorName.sourceRange, 'Text.rich');

        if (textArgument != null) {
          builder.addDeletion(textArgument.name.sourceRange);
        }
      });
    });
  }
}
