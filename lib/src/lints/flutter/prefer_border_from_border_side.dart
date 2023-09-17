import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/type_checker.dart';

class PreferBorderFromBorderSide extends DartLintRule {
  const PreferBorderFromBorderSide() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_border_from_border_side',
    problemMessage:
        'Border.all is not a const constructor and it uses const constructor '
        'Border.fromBorderSide internally.',
    correctionMessage: 'Try replacing Border.all with Border.fromBorderSide.',
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
      if (type == null || !borderChecker.isExactlyType(type)) return;

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier == null ||
          constructorNameIdentifier.name != 'all') return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  @override
  List<Fix> getFixes() => [PreferBorderFromBorderSideFix()];
}

class PreferBorderFromBorderSideFix extends DartFix {
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

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Border.fromBorderSide',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final argumentList = node.argumentList;

        builder.addSimpleReplacement(
          constructorNameIdentifier.sourceRange,
          'fromBorderSide',
        );

        builder.addSimpleInsertion(
          argumentList.leftParenthesis.end,
          'BorderSide(',
        );

        builder.addSimpleInsertion(
          argumentList.rightParenthesis.offset,
          '),',
        );
      });
    });
  }
}
