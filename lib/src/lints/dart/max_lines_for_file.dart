import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class MaxLinesForFile extends DartLintRule {
  MaxLinesForFile(this.configs) : super(code: _code) {
    init(configs);
  }

  final CustomLintConfigs configs;
  late final int maxLines;

  static const name = 'max_lines_for_file';

  static const _code = LintCode(
    name: name,
    problemMessage: 'There are too many lines in this file.',
    correctionMessage: 'Try to reduce the number of lines to {0} or less.',
    url: '$docUrl#${MaxLinesForFile.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  void init(CustomLintConfigs configs) {
    final options = configs.rules[MaxLinesForFile.name];
    maxLines = options?.json['max_lines'] as int? ?? 200;
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final lineCount = node.lineInfo.lineCount;
      if (lineCount <= maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        [maxLines],
      );
    });
  }
}
