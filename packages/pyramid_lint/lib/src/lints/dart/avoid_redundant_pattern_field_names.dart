import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidRedundantPatternFieldNames extends PyramidLintRule {
  AvoidRedundantPatternFieldNames({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Using explicit getter names is redundant.',
        correctionMessage: 'Consider omitting the getter name.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'avoid_redundant_pattern_field_names';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidRedundantPatternFieldNames.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidRedundantPatternFieldNames(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPatternField((node) {
      final fieldName = node.name?.name?.lexeme;
      if (fieldName == null) return;

      final pattern = node.pattern;
      if (pattern is! DeclaredVariablePattern) return;

      final patternName = pattern.name.lexeme;
      if (fieldName != patternName) return;

      reporter.atNode(node, code);
    });
  }

  @override
  List<Fix> getFixes() => [_RemoveName()];
}

class _RemoveName extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPatternField((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final fieldName = node.name?.name;
      if (fieldName == null) return;

      final colonToken = node.name?.colon;
      if (colonToken == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove the field name',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(range.startStart(fieldName, colonToken));
        builder.addDeletion(range.endStart(colonToken, node.pattern));
      });
    });
  }
}
