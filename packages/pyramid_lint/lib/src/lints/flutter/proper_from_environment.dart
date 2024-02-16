import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';

class ProperFromEnvironment extends DartLintRule {
  const ProperFromEnvironment()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'The {0}.fromEnvironment constructor should be invoked '
                'as a const constructor.',
            correctionMessage:
                'Try invoking the {0}.fromEnvironment constructor as a '
                'const constructor.',
            url: url,
            errorSeverity: ErrorSeverity.ERROR,
          ),
        );

  static const name = 'proper_from_environment';
  static const url = '$flutterLintDocUrl/$name';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.name?.name;
      if (constructorName != 'fromEnvironment') return;

      if (node.isConst) return;

      final type = node.staticType;
      if (type == null ||
          (!type.isDartCoreBool &&
              !type.isDartCoreInt &&
              !type.isDartCoreString)) return;

      reporter.reportErrorForNode(
        code,
        node,
        [type.getDisplayString(withNullability: false)],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_InvokeAsConstConstructor()];
}

class _InvokeAsConstConstructor extends DartFix {
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
