import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/typedef.dart';

@immutable
class MaxSwitchCasesOptions {
  const MaxSwitchCasesOptions({
    int? maxSwitchCases,
  }) : maxCases = maxSwitchCases ?? defaultMaxCases;

  static const defaultMaxCases = 10;

  final int maxCases;

  factory MaxSwitchCasesOptions.fromJson(Json json) {
    final maxSwitchCases = switch (json['max_cases']) {
      final int maxSwitchCases => maxSwitchCases,
      _ => null,
    };

    return MaxSwitchCasesOptions(maxSwitchCases: maxSwitchCases);
  }
}

class MaxSwitchCases extends PyramidLintRule<MaxSwitchCasesOptions> {
  MaxSwitchCases({required super.options})
      : super(
          name: ruleName,
          problemMessage: 'There are too many cases in this switch statement.',
          correctionMessage:
              'Consider reducing the number of cases to {0} or less.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const ruleName = 'max_switch_cases';
  static const url = '$dartLintDocUrl/$ruleName';

  factory MaxSwitchCases.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: MaxSwitchCasesOptions.fromJson,
    );

    return MaxSwitchCases(options: options);
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
      if (cases.length <= options.params.maxCases) return;

      reporter.reportErrorForNode(code, node, [options.params.maxCases]);
    });

    context.registry.addSwitchExpression((node) {
      final cases = node.cases;
      if (cases.length <= options.params.maxCases) return;

      reporter.reportErrorForNode(code, node, [options.params.maxCases]);
    });
  }
}
