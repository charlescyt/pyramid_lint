import 'dart:math' as math;

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AlwaysPutDocCommentsBeforeAnnotations extends PyramidLintRule {
  AlwaysPutDocCommentsBeforeAnnotations({required super.options})
      : super(
          name: ruleName,
          problemMessage: 'Doc comments should be placed before annotations.',
          correctionMessage:
              'Consider moving the doc comment before the annotation.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'always_put_doc_comments_before_annotations';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AlwaysPutDocCommentsBeforeAnnotations.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AlwaysPutDocCommentsBeforeAnnotations(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addAnnotatedNode((node) {
      final comment = node.documentationComment;
      if (comment == null) return;

      final annotations = node.metadata;
      if (annotations.isEmpty) return;

      final commentOffset = comment.offset;
      final annotationOffset = annotations.first.offset;
      if (commentOffset < annotationOffset) return;

      reporter.reportErrorForNode(code, comment);
    });
  }

  @override
  List<Fix> getFixes() => [_PutDocCommentsBeforeAnnotations()];
}

class _PutDocCommentsBeforeAnnotations extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addAnnotatedNode((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final comment = node.documentationComment;
      if (comment == null) return;

      final annotations = node.metadata;
      if (annotations.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Put doc comment before annotations.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final sourceRange = range.startOffsetEndOffset(
          node.offset,
          math.max(annotations.last.end, comment.end),
        );
        final newCommentAndAnnotations = [
          ...comment.tokens.map((e) => e.lexeme),
          ...annotations.map((e) => e.toSource()),
        ].join('\n');

        builder.addSimpleReplacement(
          sourceRange,
          newCommentAndAnnotations,
        );
      });
    });
  }
}
