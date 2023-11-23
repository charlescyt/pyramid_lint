import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class PreferBorderFromBorderSide extends DartLintRule {
  const PreferBorderFromBorderSide() : super(code: _code);

  static const name = 'prefer_border_from_border_side';

  static const _code = LintCode(
    name: name,
    problemMessage:
        'Border.all is not a const constructor and it uses const constructor '
        'Border.fromBorderSide internally.',
    correctionMessage:
        'Consider replacing Border.all with Border.fromBorderSide.',
    url: '$docUrl#${PreferBorderFromBorderSide.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !borderChecker.isExactlyType(type)) return;

      final constructorNameIdentifier = node.constructorName.name;
      if (constructorNameIdentifier?.name != 'all') return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithBorderFromBorderSide()];
}

class _ReplaceWithBorderFromBorderSide extends DartFix {
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
        builder.addSimpleReplacement(
          constructorNameIdentifier.sourceRange,
          'fromBorderSide(BorderSide',
        );
        builder.addSimpleInsertion(
          node.endToken.offset,
          '),',
        );
      });
    });
  }
}
