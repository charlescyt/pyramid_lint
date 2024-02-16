import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

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

class MaxLinesForFile extends DartLintRule {
  const MaxLinesForFile._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'There are too many lines in this file.',
            correctionMessage:
                'Consider reducing the number of lines to {0} or less.',
            url: url,
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'max_lines_for_file';
  static const url = '$dartLintDocUrl/$name';

  final MaxLinesForFileOptions options;

  factory MaxLinesForFile.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = MaxLinesForFileOptions.fromJson(json);

    return MaxLinesForFile._(options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final lineCount = node.lineInfo.lineCount;
      if (lineCount <= options.maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        [options.maxLines],
      );
    });
  }
}
