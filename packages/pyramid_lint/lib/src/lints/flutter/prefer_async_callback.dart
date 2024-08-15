import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';

class PreferAsyncCallback extends PyramidLintRule {
  PreferAsyncCallback({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'There is a typedef AsyncCallback defined in flutter.',
          correctionMessage:
              'Consider using AsyncCallback instead of Future<void> Function().',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'prefer_async_callback';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory PreferAsyncCallback.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferAsyncCallback(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addGenericFunctionType((node) {
      final returnType = node.returnType;
      if (returnType == null || !_isFutureVoid(returnType)) return;

      final parameters = node.parameters.parameters;
      if (parameters.isNotEmpty) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      reporter.atNode(node, code);
    });
  }

  bool _isFutureVoid(TypeAnnotation typeAnnotation) {
    final type = typeAnnotation.type;
    if (type == null || !type.isDartAsyncFuture) return false;

    // Since we know it's a Future, we can safely cast it to NamedType.
    typeAnnotation as NamedType;
    final typeArgs = typeAnnotation.typeArguments?.arguments;

    return switch (typeArgs) {
      [final NamedType type] when type.type is VoidType => true,
      _ => false,
    };
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithAsyncCallback()];
}

class _ReplaceWithAsyncCallback extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addGenericFunctionType((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final replacement =
          node.question == null ? 'AsyncCallback' : 'AsyncCallback?';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with $replacement',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          replacement,
        );
      });
    });
  }
}
