import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/rule_options.dart';
import '../../utils/utils.dart';

@immutable
class MaxLinesForFunctionOptions {
  static const defaultMaxLines = 100;

  final int maxLines;

  const MaxLinesForFunctionOptions({int? maxLines}) : maxLines = maxLines ?? defaultMaxLines;

  factory MaxLinesForFunctionOptions.fromMap(Map<String, Object?> map) {
    final maxLines = switch (map['max_lines']) {
      final int maxLines => maxLines,
      _ => null,
    };

    return MaxLinesForFunctionOptions(maxLines: maxLines);
  }

  factory MaxLinesForFunctionOptions.fromRuleContext(RuleContext context) {
    final map = readPluginRuleOptions(context, MaxLinesForFunctionRule.code.lowerCaseName);
    return MaxLinesForFunctionOptions.fromMap(map);
  }
}

class MaxLinesForFunctionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'max_lines_for_function',
    'There are too many lines in this {0}.',
    correctionMessage: 'Consider reducing the number of lines to {1} or less.',
    severity: DiagnosticSeverity.INFO,
  );

  MaxLinesForFunctionRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final options = MaxLinesForFunctionOptions.fromRuleContext(context);
    final visitor = _Visitor(this, context, options);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  final MaxLinesForFunctionOptions options;

  const _Visitor(this.rule, this.context, this.options);

  LineInfo get _lineInfo => context.definingUnit.unit.lineInfo;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _reportIfTooLong(node, node.functionExpression.body, 'function');
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _reportIfTooLong(node, node.body, 'method');
  }

  void _reportIfTooLong(AstNode node, FunctionBody body, String kind) {
    final lineCount = getLineCountForNode(body, _lineInfo);
    if (lineCount <= options.maxLines) return;

    rule.reportAtNode(node, arguments: [kind, '${options.maxLines}']);
  }
}
