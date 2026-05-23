import 'dart:math' as math;

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class AlwaysPutDocCommentsBeforeAnnotationsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'always_put_doc_comments_before_annotations',
    'Doc comments should be placed before annotations.',
    correctionMessage: 'Consider moving the doc comment before the annotation.',
    severity: DiagnosticSeverity.INFO,
  );

  AlwaysPutDocCommentsBeforeAnnotationsRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends GeneralizingAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitAnnotatedNode(AnnotatedNode node) {
    final comment = node.documentationComment;
    if (comment != null) {
      final annotations = node.metadata;
      if (annotations.isNotEmpty) {
        final commentOffset = comment.offset;
        final annotationOffset = annotations.first.offset;
        if (commentOffset >= annotationOffset) {
          rule.reportAtNode(comment);
        }
      }
    }

    super.visitAnnotatedNode(node);
  }
}

class PutDocCommentsBeforeAnnotations extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.putDocCommentsBeforeAnnotations',
    DartFixKindPriority.standard,
    'Put doc comment before annotations.',
  );

  PutDocCommentsBeforeAnnotations({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final annotatedNode = node.thisOrAncestorOfType<AnnotatedNode>();
    if (annotatedNode == null) return;

    final comment = annotatedNode.documentationComment;
    if (comment == null) return;

    final annotations = annotatedNode.metadata;
    if (annotations.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      final sourceRange = range.startOffsetEndOffset(
        annotatedNode.offset,
        math.max(annotations.last.end, comment.end),
      );
      final newCommentAndAnnotations = [
        ...comment.tokens.map((token) => token.lexeme),
        ...annotations.map((annotation) => annotation.toSource()),
      ].join('\n');

      builder.addSimpleReplacement(sourceRange, newCommentAndAnnotations);
    });
  }
}
