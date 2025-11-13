import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class PreferNewLineBeforeReturn extends PyramidLintRule {
  PreferNewLineBeforeReturn({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'There should be a new line before the return statement.',
        correctionMessage: 'Consider adding a new line before the return statement.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'prefer_new_line_before_return';
  static const url = '$dartLintDocUrl/$ruleName';

  factory PreferNewLineBeforeReturn.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return PreferNewLineBeforeReturn(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
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

        final previousTokenLine = lineInfo.getLocation(previousToken.offset).lineNumber;
        final returnTokenLine = lineInfo.getLocation(returnToken.offset).lineNumber;

        if (returnTokenLine - previousTokenLine == 1) {
          reporter.atToken(returnToken, code);
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
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    context.registry.addReturnStatement((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final returnToken = node.returnKeyword;
      final previousToken = returnToken.previous;
      if (previousToken == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add new line before return statement.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(previousToken.end, '\n');
      });
    });
  }
}
