import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class PreferBorderRadiusAll extends DartLintRule {
  const PreferBorderRadiusAll() : super(code: _code);

  static const name = 'prefer_border_radius_all';

  static const _code = LintCode(
    name: name,
    problemMessage:
        'BorderRadius.circular is not a const constructor and it uses const '
        'constructor BorderRadius.all internally.',
    correctionMessage:
        'Try replacing BorderRadius.circular with BorderRadius.all.',
    url: '$docUrl#${PreferBorderRadiusAll.name}',
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
      if (type == null || !borderRadiusChecker.isExactlyType(type)) return;

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier == null ||
          constructorNameIdentifier.name != 'circular') return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  @override
  List<Fix> getFixes() => [PreferBorderRadiusAllFix()];
}

class PreferBorderRadiusAllFix extends DartFix {
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
        message: 'Replace with BorderRadius.all',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final argumentList = node.argumentList;

        builder.addSimpleReplacement(
          constructorNameIdentifier.sourceRange,
          'all',
        );

        builder.addSimpleInsertion(
          argumentList.leftParenthesis.end,
          'Radius.circular(',
        );

        builder.addSimpleInsertion(
          argumentList.rightParenthesis.end,
          ')',
        );
      });
    });
  }
}
