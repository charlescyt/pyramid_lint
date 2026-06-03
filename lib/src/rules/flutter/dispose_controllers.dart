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
import 'package:collection/collection.dart';

import '../../utils/extensions/ast.dart';
import '../../utils/type_checker.dart';

class DisposeControllersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'dispose_controllers',
    'Controller should be disposed in the dispose method.',
    correctionMessage: 'Try adding {0}.dispose() in the dispose method.',
    severity: DiagnosticSeverity.ERROR,
  );

  DisposeControllersRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    final superClassType = classDeclaration.extendsClause?.superclass.type;
    if (superClassType == null || !stateChecker.isAssignableFromType(superClassType)) {
      return;
    }

    final classBody = classDeclaration.body;
    if (classBody is! BlockClassBody) return;

    final controllerDeclarations = node.fields.variables.where((variable) {
      final variableType = variable.declaredFragment?.element.type;
      if (variableType == null) return false;
      return disposableControllerChecker.isAssignableFromType(variableType);
    });

    final disposeFunctionBody = classBody.members.getMethodDeclarationByName('dispose')?.body;

    if (disposeFunctionBody == null || disposeFunctionBody is! BlockFunctionBody) {
      for (final controller in controllerDeclarations) {
        final controllerName = controller.name.lexeme;
        rule.reportAtToken(controller.name, arguments: [controllerName]);
      }
      return;
    }

    final disposeStatementTargetNames = _getDisposeStatementTargetNames(
      disposeFunctionBody.block.statements,
    );

    for (final controllerDeclaration in controllerDeclarations) {
      final controllerName = controllerDeclaration.name.lexeme;
      if (!disposeStatementTargetNames.contains(controllerName)) {
        rule.reportAtToken(controllerDeclaration.name, arguments: [controllerName]);
      }
    }
  }
}

class AddControllerDispose extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.addControllerDispose',
    DartFixKindPriority.standard,
    'Dispose controller',
  );

  AddControllerDispose({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final fieldDeclaration = node.thisOrAncestorOfType<FieldDeclaration>();
    if (fieldDeclaration == null) return;

    final parent = node.thisOrAncestorOfType<ClassDeclaration>();
    if (parent == null) return;

    final classBody = parent.body;
    if (classBody is! BlockClassBody) return;

    final controllerToBeDisposed = fieldDeclaration.fields.variables.firstWhereOrNull(
      (variable) => variable.name.sourceRange.intersects(node.sourceRange),
    );
    if (controllerToBeDisposed == null) return;

    final toBeDisposedControllerName = controllerToBeDisposed.name.lexeme;
    final disposeMethod = classBody.members.getMethodDeclarationByName('dispose');

    await builder.addDartFileEdit(file, (fileEdit) {
      switch (disposeMethod?.body) {
        case null:
          final initStateMethod = classBody.members.getMethodDeclarationByName('initState');
          final buildMethod = classBody.members.getMethodDeclarationByName('build');

          final (
            int offset,
            bool addNewLineAtTheStart,
            bool addNewLineAtTheEnd,
          ) = switch ((initStateMethod, buildMethod)) {
            (null, null) => (fieldDeclaration.end, true, false),
            (null, final buildMethod?) => (buildMethod.offset, false, true),
            (final initStateMethod?, null) => (initStateMethod.end, true, false),
            (final _?, final buildMethod?) => (buildMethod.offset, false, true),
          };

          fileEdit.addInsertion(offset, (edit) {
            if (addNewLineAtTheStart) edit.writeln();
            edit.writeln('@override');
            edit.writeln('  void dispose() {');
            edit.writeln('    $toBeDisposedControllerName.dispose();');
            edit.writeln('    super.dispose();');
            edit.writeln('  }');
            if (addNewLineAtTheEnd) edit.writeln();
            edit.write('  ');
          });
        case final BlockFunctionBody body:
          final disposeStatementTargetNames = _getDisposeStatementTargetNames(body.block.statements);

          if (!disposeStatementTargetNames.contains(toBeDisposedControllerName)) {
            fileEdit.addInsertion(body.beginToken.end, (edit) {
              edit.write('\n    $toBeDisposedControllerName.dispose();');
            });
          }
        case final ExpressionFunctionBody body:
          fileEdit.addReplacement(range.node(body), (edit) {
            edit.writeln('{');
            edit.writeln('    $toBeDisposedControllerName.dispose();');
            edit.writeln('    ${body.expression.toSource()};');
            edit.write('  }');
          });
        case EmptyFunctionBody() || NativeFunctionBody():
      }
    });
  }
}

Iterable<String> _getDisposeStatementTargetNames(NodeList<Statement> statements) {
  return statements.whereType<ExpressionStatement>().map(_getTargetNameOfDisposeMethodInvocation).nonNulls;
}

String? _getTargetNameOfDisposeMethodInvocation(ExpressionStatement expressionStatement) {
  if (expressionStatement.expression case final CascadeExpression cascadeExpression) {
    for (final section in cascadeExpression.cascadeSections) {
      if (section is MethodInvocation && section.methodName.name == 'dispose') {
        if (cascadeExpression.target case final SimpleIdentifier simpleIdentifier) {
          return simpleIdentifier.name;
        }
      }
    }
  } else if (expressionStatement.expression case final MethodInvocation methodInvocation) {
    final target = methodInvocation.target;
    if (target is! SimpleIdentifier) return null;

    final methodName = methodInvocation.methodName.name;
    if (methodName != 'dispose') return null;

    return target.name;
  }

  return null;
}
