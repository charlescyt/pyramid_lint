import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class MaxLinesForFile extends DartLintRule {
  MaxLinesForFile(this.configs)
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'There are too many lines in this file.',
            correctionMessage:
                'Consider reducing the number of lines to {0} or less.',
            url: '$dartLintDocUrl/${MaxLinesForFile.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        ) {
    init(configs);
  }

  final CustomLintConfigs configs;
  late final int maxLines;

  static const name = 'max_lines_for_file';

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
