import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/argument_list_extensions.dart';
import '../../utils/type_checker.dart';

class PreferTextRich extends DartLintRule {
  const PreferTextRich() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_text_rich',
    problemMessage:
        'RichText does not inherit TextStyle from DefaultTextStyle.',
    correctionMessage: 'Try replacing RichText with Text.rich.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !richTextChecker.isAssignableFromType(type)) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  @override
  List<Fix> getFixes() => [PreferTextRichFix()];
}

class PreferTextRichFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange
          .intersects(node.constructorName.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Text.rich',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final textArgument = node.argumentList.findArgumentByName('text');

        builder.addSimpleReplacement(
          node.constructorName.sourceRange,
          'Text.rich',
        );

        if (textArgument != null) {
          builder.addDeletion(textArgument.name.sourceRange);
        }
      });
    });
  }
}
