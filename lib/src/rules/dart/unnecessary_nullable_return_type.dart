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

import '../../utils/extensions/dart_type.dart';

class UnnecessaryNullableReturnTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'unnecessary_nullable_return_type',
    'The nullable return type is unnecessary.',
    correctionMessage: 'Consider using non-nullable return type.',
    severity: DiagnosticSeverity.WARNING,
  );

  UnnecessaryNullableReturnTypeRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node.functionExpression.body, node.returnType);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _check(node.body, node.returnType);
  }

  void _check(FunctionBody body, TypeAnnotation? returnType) {
    if (returnType == null || returnType.question == null) return;

    if (body is BlockFunctionBody) {
      _checkBlockFunctionBody(body, returnType);
    } else if (body is ExpressionFunctionBody) {
      _checkExpressionFunctionBody(body, returnType);
    }
  }

  void _checkBlockFunctionBody(BlockFunctionBody body, TypeAnnotation returnType) {
    final returnStatements = _collectReturnStatements(body);
    if (returnStatements.any((statement) => statement.hasNullableReturnType)) return;

    rule.reportAtNode(returnType);
  }

  void _checkExpressionFunctionBody(ExpressionFunctionBody body, TypeAnnotation returnType) {
    final type = body.expression.staticType;
    if (type == null || type.isNullable) return;

    rule.reportAtNode(returnType);
  }

  Set<ReturnStatement> _collectReturnStatements(BlockFunctionBody body) {
    final collector = _ReturnStatementCollector();
    body.accept(collector);
    return collector.returnStatements;
  }
}

class ReplaceWithNonNullableType extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithNonNullableType',
    DartFixKindPriority.standard,
    'Replace with non-nullable type',
  );

  ReplaceWithNonNullableType({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final returnType = node;
    if (returnType is! TypeAnnotation) return;

    final questionToken = returnType.question;
    if (questionToken == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(range.token(questionToken));
    });
  }
}

class _ReturnStatementCollector extends RecursiveAstVisitor<void> {
  final Set<ReturnStatement> returnStatements = {};

  _ReturnStatementCollector();

  @override
  void visitReturnStatement(ReturnStatement node) {
    returnStatements.add(node);
    super.visitReturnStatement(node);
  }
}

extension on ReturnStatement {
  bool get hasNullableReturnType {
    return expression?.staticType?.isNullable == true;
  }
}
