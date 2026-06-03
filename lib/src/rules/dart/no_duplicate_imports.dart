import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/extensions/iterable.dart';

class NoDuplicateImportsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_duplicate_imports',
    'Duplicate imports can lead to confusion.',
    correctionMessage: 'Consider combining or removing the duplicate imports.',
    severity: DiagnosticSeverity.INFO,
  );

  NoDuplicateImportsRule()
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

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final importDirectives = node.directives.whereType<ImportDirective>();
    final duplicateUrls = importDirectives.map((e) => e.uri.stringValue).nonNulls.duplicates;

    for (final importDirective in importDirectives) {
      final url = importDirective.uri.stringValue;
      if (duplicateUrls.contains(url)) {
        rule.reportAtNode(importDirective.uri);
      }
    }
  }
}
