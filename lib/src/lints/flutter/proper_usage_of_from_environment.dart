import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ProperUsageOfFromEnvironment extends DartLintRule {
  const ProperUsageOfFromEnvironment() : super(code: _code);

  static const _code = LintCode(
    name: 'proper_usage_of_from_environment',
    problemMessage: 'The {0}.fromEnvironment constructor should be invoked '
        'as a const constructor.',
    correctionMessage: 'Try invoking the {0}.fromEnvironment constructor as a '
        'const constructor.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final methodName = node.constructorName.name?.name;
      if (methodName != 'fromEnvironment') return;

      final type = node.constructorName.type.type;
      if (type == null ||
          (!type.isDartCoreBool &&
              !type.isDartCoreInt &&
              !type.isDartCoreString)) return;

      if (node.isConst) return;

      reporter.reportErrorForNode(
        code,
        node,
        [type.getDisplayString(withNullability: false)],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_UseConst()];
}

class _UseConst extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final keyword = node.keyword;
      final changeBuilder = reporter.createChangeBuilder(
        message:
            keyword == null ? 'Add const keyword' : 'Replace new with const',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        if (keyword == null) {
          builder.addSimpleInsertion(
            node.offset,
            'const ',
          );
        } else {
          builder.addSimpleReplacement(
            keyword.sourceRange,
            'const',
          );
        }
      });
    });
  }
}
