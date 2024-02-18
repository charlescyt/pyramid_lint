import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/typedef.dart';

@immutable
class AvoidNestedIfOptions {
  const AvoidNestedIfOptions({
    int? maxNestingLevel,
  }) : maxNestingLevel = maxNestingLevel ?? defaultMaxNestingLevel;

  static const defaultMaxNestingLevel = 2;

  final int maxNestingLevel;

  factory AvoidNestedIfOptions.fromJson(Json json) {
    final maxNestingLevel = switch (json['max_nesting_level']) {
      final int maxNestingLevel => maxNestingLevel,
      _ => null,
    };

    return AvoidNestedIfOptions(maxNestingLevel: maxNestingLevel);
  }
}

class AvoidNestedIf extends PyramidLintRule<AvoidNestedIfOptions> {
  AvoidNestedIf({required super.options})
      : super(
          name: name,
          problemMessage:
              'Avoid nested if statements to reduce code complexity.',
          correctionMessage:
              'Try reducing the nesting level to less than ${options.params.maxNestingLevel}.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const name = 'avoid_nested_if';
  static const url = '$dartLintDocUrl/$name';

  factory AvoidNestedIf.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: AvoidNestedIfOptions.fromJson,
    );

    return AvoidNestedIf(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      final parentIf = node.parent?.thisOrAncestorOfType<IfStatement>();
      if (parentIf != null) return;

      final ifStatements = node.childrenIfStatements;
      if (ifStatements.length < options.params.maxNestingLevel) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
