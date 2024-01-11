import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class PreferNewLineBeforeReturn extends DartLintRule {
  const PreferNewLineBeforeReturn() : super(code: _code);

  static const name = 'prefer_new_line_before_return';

  static const _code = LintCode(
    name: name,
    problemMessage: 'There should be a new line before the return statement.',
    correctionMessage:
        'Consider adding a new line before the return statement.',
    url: '$dartLintDocUrl/${PreferNewLineBeforeReturn.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlock((node) {
      final statements = node.statements;
      if (statements.length < 2) return;

      for (final statement in statements) {
        if (statement is! ReturnStatement) continue;

        final returnToken = statement.returnKeyword;
        final previousToken = returnToken.previous;
        if (previousToken is! Token) return;

        final lineInfo = resolver.lineInfo;

        final previousTokenLine =
            lineInfo.getLocation(previousToken.offset).lineNumber;
        final returnTokenLine =
            lineInfo.getLocation(returnToken.offset).lineNumber;

        if (previousTokenLine + 1 >= returnTokenLine) {
          reporter.reportErrorForToken(code, returnToken);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AddNewLineBeforeReturn()];
}

class _AddNewLineBeforeReturn extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addReturnStatement((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add new line before return statement.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final returnToken = node.returnKeyword;
        final previousToken = returnToken.previous;
        if (previousToken == null) return;

        builder.addSimpleInsertion(previousToken.end, '\n');
      });
    });
  }
}
