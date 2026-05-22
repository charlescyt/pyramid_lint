import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class PreferNewLineBeforeReturnRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_new_line_before_return',
    'There should be a new line before the return statement.',
    correctionMessage: 'Consider adding a new line before the return statement.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferNewLineBeforeReturnRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addReturnStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitReturnStatement(ReturnStatement node) {
    final parent = node.parent;
    if (parent is! Block) return;
    if (parent.statements.length == 1) return;

    final returnToken = node.returnKeyword;
    final previousToken = returnToken.previous;
    if (previousToken == null) return;

    if (_hasNoBlankLineBetween(previousToken, returnToken)) {
      rule.reportAtNode(node);
    }
  }

  LineInfo get _lineInfo => context.definingUnit.unit.lineInfo;

  int _lineNumber(int offset) => _lineInfo.getLocation(offset).lineNumber;

  bool _hasNoBlankLineBetween(Token previousToken, Token nextToken) {
    final previousTokenLine = _lineNumber(previousToken.offset);
    final nextTokenLine = _lineNumber(nextToken.offset);
    return nextTokenLine - previousTokenLine == 1;
  }
}

class AddNewLineBeforeReturn extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.addNewLineBeforeReturn',
    DartFixKindPriority.standard,
    'Add a new line before the return statement',
  );

  AddNewLineBeforeReturn({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final returnStatement = node;
    if (returnStatement is! ReturnStatement) return;

    final returnToken = returnStatement.returnKeyword;
    final previousToken = returnToken.previous;
    if (previousToken == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(previousToken.end, (builder) {
        builder.writeln();
      });
    });
  }
}
