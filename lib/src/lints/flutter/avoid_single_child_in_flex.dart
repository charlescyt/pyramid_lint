import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/argument_list_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class AvoidSingleChildInFlex extends DartLintRule {
  const AvoidSingleChildInFlex()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'Using {0} to position a single widget is inefficient.',
            correctionMessage: 'Consider replacing {0} with Align or Center.',
            url: '$flutterLintDocUrl/${AvoidSingleChildInFlex.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'avoid_single_child_in_flex';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !flexChecker.isAssignableFromType(type)) return;

      final childrenExpression = node.argumentList.childrenArgument?.expression;
      if (childrenExpression is! ListLiteral) return;

      if (childrenExpression.elements.length != 1) return;

      final firstElement = childrenExpression.elements.first;
      if (firstElement is SpreadElement || firstElement is ForElement) return;

      reporter.reportErrorForNode(
        code,
        node.constructorName,
        [type.getDisplayString(withNullability: false)],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithAlign(), _ReplaceWithCenter()];
}

class _ReplaceWithAlign extends DartFix {
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

      final childrenExpression = node.argumentList.childrenArgument?.expression;
      if (childrenExpression is! ListLiteral ||
          childrenExpression.elements.length != 1) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Align',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final child = childrenExpression.elements.first;

        builder.addSimpleReplacement(
          node.sourceRange,
          'Align(child: ${child.toSource()},)',
        );
      });
    });
  }
}

class _ReplaceWithCenter extends DartFix {
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

      final childrenExpression = node.argumentList.childrenArgument?.expression;
      if (childrenExpression is! ListLiteral ||
          childrenExpression.elements.length != 1) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Center',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final child = childrenExpression.elements.first;

        builder.addSimpleReplacement(
          node.sourceRange,
          'Center(child: ${child.toSource()},)',
        );
      });
    });
  }
}
