import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class AvoidWidgetStatePublicMembers extends DartLintRule {
  const AvoidWidgetStatePublicMembers()
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'Avoid public members in widget state classes.',
            correctionMessage: 'Consider using private members.',
            url: '$flutterLintDocUrl/${AvoidWidgetStatePublicMembers.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'avoid_widget_state_public_members';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassMember((classMember) {
      final parent = classMember.parent;
      if (parent is! ClassDeclaration) return;

      final classDeclaration = parent;
      final superClass = classDeclaration.extendsClause?.superclass;
      if (superClass == null) return;

      final type = superClass.type;
      if (type == null || !widgetStateChecker.isAssignableFromType(type)) {
        return;
      }

      final hasOverrideAnnotation =
          classMember.metadata.any((e) => e.name.name == 'override');
      if (hasOverrideAnnotation) return;

      switch (classMember) {
        case final ConstructorDeclaration _:
          return;
        case final MethodDeclaration methodDeclaration:
          _checkMethodDeclaration(methodDeclaration, reporter);
        case final FieldDeclaration fieldDeclaration:
          _checkFieldDeclaration(fieldDeclaration, reporter);
      }
    });
  }

  void _checkMethodDeclaration(
    MethodDeclaration methodDeclaration,
    ErrorReporter reporter,
  ) {
    if (methodDeclaration.isStatic ||
        methodDeclaration.name.lexeme.startsWith('_')) return;

    reporter.reportErrorForToken(code, methodDeclaration.name);
  }

  void _checkFieldDeclaration(
    FieldDeclaration fieldDeclaration,
    ErrorReporter reporter,
  ) {
    if (fieldDeclaration.isStatic) return;

    for (final variable in fieldDeclaration.fields.variables) {
      if (!variable.name.lexeme.startsWith('_')) {
        reporter.reportErrorForToken(code, variable.name);
      }
    }
  }
}
