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
import 'package:collection/collection.dart';

import '../../utils/extensions/ast.dart';
import '../../utils/type_checker.dart';

class ProperSuperDisposeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'proper_super_dispose',
    'super.dispose() should be called at the end of the dispose method.',
    correctionMessage: 'Try placing super.dispose() at the end of the dispose method.',
    severity: DiagnosticSeverity.ERROR,
  );

  ProperSuperDisposeRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return;

    final type = extendsClause.superclass.type;
    if (type == null || !stateChecker.isAssignableFromType(type)) return;

    final classBody = node.body;
    if (classBody is! BlockClassBody) return;

    final body = classBody.members.getMethodDeclarationByName('dispose')?.body;
    if (body == null || body is! BlockFunctionBody) return;

    final statements = body.block.statements;
    if (statements.isEmpty) return;

    if (statements.last.toSource() == 'super.dispose();') return;

    final superDisposeStatement = statements.lastWhereOrNull(
      (statement) => statement.toSource() == 'super.dispose();',
    );
    if (superDisposeStatement == null) return;

    rule.reportAtNode(superDisposeStatement);
  }
}

class PlaceSuperDisposeAtTheEnd extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.placeSuperDisposeAtTheEnd',
    DartFixKindPriority.standard,
    'Place super.dispose() at the end of the dispose method',
  );

  PlaceSuperDisposeAtTheEnd({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    final classBody = classDeclaration.body;
    if (classBody is! BlockClassBody) return;

    final body = classBody.members.getMethodDeclarationByName('dispose')?.body;
    if (body == null || body is! BlockFunctionBody) return;

    final statements = body.block.statements;
    if (statements.isEmpty) return;

    final superDisposeStatement = statements.lastWhereOrNull(
      (statement) => statement.toSource() == 'super.dispose();',
    );
    if (superDisposeStatement == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final superDisposeStatementIndex = statements.indexOf(superDisposeStatement);
      final lastStatement = statements.last;

      for (var i = superDisposeStatementIndex; i < statements.length - 1; i++) {
        builder.addSimpleReplacement(statements[i].sourceRange, statements[i + 1].toSource());
      }

      builder.addSimpleReplacement(lastStatement.sourceRange, superDisposeStatement.toSource());
    });
  }
}
