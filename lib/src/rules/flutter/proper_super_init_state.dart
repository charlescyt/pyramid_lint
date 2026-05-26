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

class ProperSuperInitStateRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'proper_super_init_state',
    'super.initState() should be called at the start of the initState method.',
    correctionMessage: 'Try placing super.initState() at the start of the initState method.',
    severity: DiagnosticSeverity.ERROR,
  );

  ProperSuperInitStateRule()
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

    final body = classBody.members.getMethodDeclarationByName('initState')?.body;
    if (body == null || body is! BlockFunctionBody) return;

    final statements = body.block.statements;
    if (statements.isEmpty) return;

    if (statements.first.toSource() == 'super.initState();') return;

    final superInitStateStatement = statements.firstWhereOrNull(
      (statement) => statement.toSource() == 'super.initState();',
    );
    if (superInitStateStatement == null) return;

    rule.reportAtNode(superInitStateStatement);
  }
}

class PlaceSuperInitStateAtTheStart extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.placeSuperInitStateAtTheStart',
    DartFixKindPriority.standard,
    'Put super.initState() at the start of the initState method',
  );

  PlaceSuperInitStateAtTheStart({required super.context});

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

    final body = classBody.members.getMethodDeclarationByName('initState')?.body;
    if (body == null || body is! BlockFunctionBody) return;

    final statements = body.block.statements;
    if (statements.isEmpty) return;

    final superInitStateStatement = statements.firstWhereOrNull(
      (statement) => statement.toSource() == 'super.initState();',
    );
    if (superInitStateStatement == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final superInitStateStatementIndex = statements.indexOf(superInitStateStatement);
      final firstStatement = statements.first;

      for (var i = superInitStateStatementIndex; i > 0; i--) {
        builder.addSimpleReplacement(statements[i].sourceRange, statements[i - 1].toSource());
      }

      builder.addSimpleReplacement(firstStatement.sourceRange, superInitStateStatement.toSource());
    });
  }
}
