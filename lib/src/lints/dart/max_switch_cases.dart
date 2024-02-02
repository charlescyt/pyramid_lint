import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/constants.dart';

@immutable
class MaxSwitchCasesOptions {
  const MaxSwitchCasesOptions({
    int? maxSwitchCases,
  }) : maxCases = maxSwitchCases ?? defaultMaxCases;

  static const defaultMaxCases = 10;

  final int maxCases;

  factory MaxSwitchCasesOptions.fromJson(Map<String, dynamic>? json) {
    final maxSwitchCases = switch (json?['max_cases']) {
      final int maxSwitchCases => maxSwitchCases,
      _ => null,
    };

    return MaxSwitchCasesOptions(maxSwitchCases: maxSwitchCases);
  }
}

class MaxSwitchCases extends DartLintRule {
  const MaxSwitchCases._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'There are too many cases in this switch statement.',
            correctionMessage:
                'Consider reducing the number of cases to {0} or less.',
            url: '$dartLintDocUrl#${MaxSwitchCases.name}',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const name = 'max_switch_cases';

  final MaxSwitchCasesOptions options;

  factory MaxSwitchCases.fromConfigs(CustomLintConfigs configs) {
    final options = MaxSwitchCasesOptions.fromJson(
      configs.rules[MaxSwitchCases.name]?.json,
    );

    return MaxSwitchCases._(options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSwitchStatement((node) {
      final cases =
          node.members.where((e) => e is SwitchCase || e is SwitchPatternCase);
      if (cases.length <= options.maxCases) return;

      reporter.reportErrorForNode(code, node, [options.maxCases]);
    });

    context.registry.addSwitchExpression((node) {
      final cases = node.cases;
      if (cases.length <= options.maxCases) return;

      reporter.reportErrorForNode(code, node, [options.maxCases]);
    });
  }
}
