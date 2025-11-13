import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class AvoidSingleChildInFlex extends PyramidLintRule {
  AvoidSingleChildInFlex({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Using {0} to position a single widget is inefficient.',
        correctionMessage: 'Consider replacing {0} with Align or Center.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'avoid_single_child_in_flex';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory AvoidSingleChildInFlex.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return AvoidSingleChildInFlex(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
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

      reporter.atNode(node.constructorName, code, arguments: [type.getDisplayString()]);
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
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.constructorName.sourceRange)) {
        return;
      }

      final childrenExpression = node.argumentList.childrenArgument?.expression;
      if (childrenExpression is! ListLiteral || childrenExpression.elements.length != 1) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Align',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final child = childrenExpression.elements.first;
        builder.addSimpleReplacement(node.sourceRange, 'Align(child: ${child.toSource()},)');
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
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.constructorName.sourceRange)) {
        return;
      }

      final childrenExpression = node.argumentList.childrenArgument?.expression;
      if (childrenExpression is! ListLiteral || childrenExpression.elements.length != 1) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Center',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final child = childrenExpression.elements.first;
        builder.addSimpleReplacement(node.sourceRange, 'Center(child: ${child.toSource()},)');
      });
    });
  }
}
