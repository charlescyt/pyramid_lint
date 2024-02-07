import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class PreferTextRich extends DartLintRule {
  const PreferTextRich()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'RichText does not inherit TextStyle from DefaultTextStyle.',
            correctionMessage: 'Consider replacing RichText with Text.rich.',
            url: '$flutterLintDocUrl/${PreferTextRich.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'prefer_text_rich';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !richTextChecker.isAssignableFromType(type)) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithTextRich()];
}

class _ReplaceWithTextRich extends DartFix {
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