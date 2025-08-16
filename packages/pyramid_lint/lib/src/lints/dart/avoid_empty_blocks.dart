import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidEmptyBlocks extends PyramidLintRule {
  AvoidEmptyBlocks({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Empty block usually indicates a missing implementation.',
        correctionMessage: 'Consider adding an implementation or a TODO comment.',
        url: url,
        errorSeverity: ErrorSeverity.WARNING,
      );

  static const ruleName = 'avoid_empty_blocks';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidEmptyBlocks.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

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

      final comment = node.endToken.precedingComments;
      if (comment != null && _hasTodoComment(comment)) return;

      reporter.atNode(node, code);
    });
  }

  bool _hasTodoComment(Token comment) {
    Token? current = comment;

    while (current != null) {
      if (_isTodoComment(current)) return true;
      current = current.next;
    }

    return false;
  }

  bool _isTodoComment(Token token) {
    final comment = token.lexeme;
    return comment.startsWith('// TODO');
  }
}
