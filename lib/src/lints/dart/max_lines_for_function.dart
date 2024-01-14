import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/constants.dart';
import '../../utils/custom_lint_resolver_extension.dart';

@immutable
class MaxLinesForFunctionOptions {
  const MaxLinesForFunctionOptions({
    int? maxLines,
  }) : maxLines = maxLines ?? defaultMaxLines;

  static const defaultMaxLines = 100;

  final int maxLines;

  factory MaxLinesForFunctionOptions.fromJson(Map<String, dynamic>? json) {
    final maxLines = switch (json?['max_lines']) {
      final int maxLines => maxLines,
      _ => null,
    };

    return MaxLinesForFunctionOptions(
      maxLines: maxLines,
    );
  }
}

class MaxLinesForFunction extends DartLintRule {
  const MaxLinesForFunction._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'There are too many lines in this {0}.',
            correctionMessage:
                'Consider reducing the number of lines to {1} or less.',
            url: '$dartLintDocUrl/${MaxLinesForFunction.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'max_lines_for_function';

  final MaxLinesForFunctionOptions options;

  factory MaxLinesForFunction.fromConfigs(CustomLintConfigs configs) {
    final options = MaxLinesForFunctionOptions.fromJson(
      configs.rules[MaxLinesForFunction.name]?.json,
    );

    return MaxLinesForFunction._(options);
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
      if (lineCount <= options.maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        ['function', options.maxLines],
      );
    });

    context.registry.addMethodDeclaration((node) {
      final lineCount = resolver.getLineCountForNode(node.body);
      if (lineCount <= options.maxLines) return;

      reporter.reportErrorForNode(
        code,
        node,
        ['method', options.maxLines],
      );
    });
  }
}
