import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AvoidEmptyBlock extends DartLintRule {
  const AvoidEmptyBlock() : super(code: _code);

  static const name = 'avoid_empty_block';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Empty block usually indicates a missing implementation.',
    correctionMessage: 'Try adding an implementation or a TODO comment.',
    url: '$docUrl#${AvoidEmptyBlock.name}',
    errorSeverity: ErrorSeverity.WARNING,
  );

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
