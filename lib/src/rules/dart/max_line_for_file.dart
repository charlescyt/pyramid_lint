import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/rule_options.dart';

@immutable
class MaxLinesForFileOptions {
  static const defaultMaxLines = 200;

  final int maxLines;

  const MaxLinesForFileOptions({int? maxLines}) : maxLines = maxLines ?? defaultMaxLines;

  factory MaxLinesForFileOptions.fromMap(Map<String, Object?> map) {
    final maxLines = switch (map['max_lines']) {
      final int maxLines => maxLines,
      _ => null,
    };

    return MaxLinesForFileOptions(maxLines: maxLines);
  }

  factory MaxLinesForFileOptions.fromRuleContext(RuleContext context) {
    final map = readPluginRuleOptions(context, MaxLinesForFileRule.code.lowerCaseName);
    return MaxLinesForFileOptions.fromMap(map);
  }
}

class MaxLinesForFileRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'max_lines_for_file',
    'There are too many lines in this file.',
    correctionMessage: 'Consider reducing the number of lines to {0} or less.',
    severity: DiagnosticSeverity.INFO,
  );

  MaxLinesForFileRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final options = MaxLinesForFileOptions.fromRuleContext(context);
    final visitor = _Visitor(this, context, options);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  final MaxLinesForFileOptions options;

  const _Visitor(this.rule, this.context, this.options);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final lineCount = node.lineInfo.lineCount;
    if (lineCount <= options.maxLines) return;

    rule.reportAtNode(node, arguments: ['${options.maxLines}']);
  }
}
