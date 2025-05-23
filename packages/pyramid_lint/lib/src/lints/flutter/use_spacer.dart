import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class UseSpacer extends PyramidLintRule {
  UseSpacer({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Using Expanded with an empty {0} is unnecessary.',
        correctionMessage: 'Consider replacing Expanded with Spacer.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'use_spacer';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory UseSpacer.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return UseSpacer(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !expandedChecker.isExactlyType(type)) return;

      final childArgument = node.argumentList.childArgument;
      if (childArgument == null) return;

      final childExpression = childArgument.expression;
      if (childExpression is! InstanceCreationExpression) return;

      final childType = childArgument.staticType;
      if (childType == null ||
          (!containerChecker.isExactlyType(childType) &&
              !sizedBoxChecker.isExactlyType(childType))) {
        return;
      }

      final isChildArgumentEmpty =
          childExpression.argumentList.arguments.isEmpty;
      if (!isChildArgumentEmpty) return;

      reporter.atNode(
        node.constructorName,
        code,
        arguments: [childType.getDisplayString()],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithSpacer()];
}

class _ReplaceWithSpacer extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(
        node.constructorName.sourceRange,
      )) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Spacer',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final flexArgument = node.argumentList.findArgumentByName('flex');

        if (flexArgument == null) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'const Spacer()',
          );
        } else {
          builder.addSimpleReplacement(
            node.sourceRange,
            'Spacer(${flexArgument.toSource()})',
          );
        }
      });
    });
  }
}
