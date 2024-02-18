import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidEmptyBlocks extends PyramidLintRule {
  AvoidEmptyBlocks({required super.options})
      : super(
          name: name,
          problemMessage:
              'Empty block usually indicates a missing implementation.',
          correctionMessage:
              'Consider adding an implementation or a TODO comment.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const name = 'avoid_empty_blocks';
  static const url = '$dartLintDocUrl/$name';

  factory AvoidEmptyBlocks.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidEmptyBlocks(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlock((node) {
      if (node.statements.isNotEmpty) return;

      if (node.endToken.precedingComments?.lexeme.startsWith('// TODO') ==
          true) {
        return;
      }

      reporter.reportErrorForNode(code, node);
    });
  }
}
