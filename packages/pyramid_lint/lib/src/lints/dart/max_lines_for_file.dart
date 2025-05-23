import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/typedef.dart';

@immutable
class MaxLinesForFileOptions {
  const MaxLinesForFileOptions({
    int? maxLines,
  }) : maxLines = maxLines ?? defaultMaxLines;

  static const defaultMaxLines = 200;

  final int maxLines;

  factory MaxLinesForFileOptions.fromJson(Json json) {
    final maxLines = switch (json['max_lines']) {
      final int maxLines => maxLines,
      _ => null,
    };

    return MaxLinesForFileOptions(
      maxLines: maxLines,
    );
  }
}

class MaxLinesForFile extends PyramidLintRule<MaxLinesForFileOptions> {
  MaxLinesForFile({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'There are too many lines in this file.',
        correctionMessage:
            'Consider reducing the number of lines to {0} or less.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'max_lines_for_file';
  static const url = '$dartLintDocUrl/$ruleName';

  factory MaxLinesForFile.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: MaxLinesForFileOptions.fromJson,
    );

    return MaxLinesForFile(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final lineCount = node.lineInfo.lineCount;
      if (lineCount <= options.params.maxLines) return;

      reporter.atNode(
        node,
        code,
        arguments: [options.params.maxLines],
      );
    });
  }
}
