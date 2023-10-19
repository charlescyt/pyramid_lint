import 'dart:math' as math;

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class DocCommentsBeforeAnnotations extends DartLintRule {
  const DocCommentsBeforeAnnotations() : super(code: _code);

  static const name = 'doc_comments_before_annotations';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Doc comments should be placed before annotations.',
    correctionMessage: 'Try moving the doc comment before the annotation.',
    url: '$docUrl#${DocCommentsBeforeAnnotations.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

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
