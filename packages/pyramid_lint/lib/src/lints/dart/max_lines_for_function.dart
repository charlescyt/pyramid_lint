import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/typedef.dart';
import '../../utils/utils.dart';

@immutable
class MaxLinesForFunctionOptions {
  const MaxLinesForFunctionOptions({
    int? maxLines,
  }) : maxLines = maxLines ?? defaultMaxLines;

  static const defaultMaxLines = 100;

  final int maxLines;

  factory MaxLinesForFunctionOptions.fromJson(Json json) {
    final maxLines = switch (json['max_lines']) {
      final int maxLines => maxLines,
      _ => null,
    };

    return MaxLinesForFunctionOptions(maxLines: maxLines);
  }
}

class MaxLinesForFunction extends PyramidLintRule<MaxLinesForFunctionOptions> {
  MaxLinesForFunction({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'There are too many lines in this {0}.',
        correctionMessage: 'Consider reducing the number of lines to {1} or less.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'max_lines_for_function';
  static const url = '$dartLintDocUrl/$ruleName';

  factory MaxLinesForFunction.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: MaxLinesForFunctionOptions.fromJson);

    return MaxLinesForFunction(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final body = node.functionExpression.body;
      final lineInfo = resolver.lineInfo;
      final lineCount = getLineCountForNode(body, lineInfo);
      if (lineCount <= options.params.maxLines) return;

      reporter.atNode(node, code, arguments: ['function', options.params.maxLines]);
    });

    context.registry.addMethodDeclaration((node) {
      final body = node.body;
      final lineInfo = resolver.lineInfo;
      final lineCount = getLineCountForNode(body, lineInfo);
      if (lineCount <= options.params.maxLines) return;

      reporter.atNode(node, code, arguments: ['method', options.params.maxLines]);
    });
  }
}
