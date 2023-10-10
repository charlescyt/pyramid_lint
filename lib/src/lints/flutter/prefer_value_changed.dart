import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class PreferValueChanged extends DartLintRule {
  const PreferValueChanged() : super(code: _code);

  static const name = 'prefer_value_changed';

  static const _code = LintCode(
    name: name,
    problemMessage: 'There is a typedef ValueChanged<T> defined in flutter.',
    correctionMessage:
        'Try using ValueChanged<{0}> instead of void Function({1}).',
    url: '$docUrl#${PreferValueChanged.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addGenericFunctionType((node) {
      final returnType = node.returnType?.type;
      if (returnType is! VoidType) return;

      final parameters = node.parameters.parameters;
      if (parameters.length != 1) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      final firstParameter = parameters.first;
      if (firstParameter is! SimpleFormalParameter) return;

      final firstParameterType = firstParameter.type?.type;
      if (firstParameterType == null) return;

      reporter.reportErrorForNode(
        code,
        node,
        [
          firstParameterType.getDisplayString(withNullability: false),
          firstParameter.toSource(),
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_UseValueChanged()];
}

class _UseValueChanged extends DartFix {
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

      final parameters = node.parameters.parameters;
      if (parameters.length != 1) return;

      final firstParameter = parameters.first;
      if (firstParameter is! SimpleFormalParameter) return;

      final firstParameterType = firstParameter.type?.type;
      if (firstParameterType == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with ValueChanged<${firstParameter.type}>',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          'ValueChanged<${firstParameter.type}>',
        );
      });
    });
  }
}
