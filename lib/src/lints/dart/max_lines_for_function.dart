import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/custom_lint_resolver_extension.dart';

class MaxLinesForFunction extends DartLintRule {
  MaxLinesForFunction(this.configs)
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'There are too many lines in this function.',
            correctionMessage:
                'Consider reducing the number of lines to {0} or less.',
            url: '$dartLintDocUrl/${MaxLinesForFunction.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        ) {
    init(configs);
  }

  final CustomLintConfigs configs;
  late final int maxLines;

  static const name = 'max_lines_for_function';

  void init(CustomLintConfigs configs) {
    final options = configs.rules[MaxLinesForFunction.name];
    maxLines = options?.json['max_lines'] as int? ?? 100;
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final lineCount =
          resolver.getLineCountForNode(node.functionExpression.body);
      if (lineCount <= maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        [maxLines],
      );
    });

    context.registry.addMethodDeclaration((node) {
      final lineCount = resolver.getLineCountForNode(node.body);
      if (lineCount <= maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        [maxLines],
      );
    });
  }
}
