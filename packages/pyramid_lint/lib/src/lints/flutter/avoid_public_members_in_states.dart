import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class AvoidPublicMembersInStates extends PyramidLintRule {
  AvoidPublicMembersInStates({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Avoid public members in widget state classes.',
        correctionMessage: 'Consider using private members.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'avoid_public_members_in_states';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory AvoidPublicMembersInStates.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidPublicMembersInStates(options: options);
  }

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
      if (type == null || !stateChecker.isAssignableFromType(type)) return;

      final hasOverrideAnnotation = classMember.metadata.any(
        (e) => e.name.name == 'override',
      );
      if (hasOverrideAnnotation) return;

      final hasVisibleForTestingAnnotation = classMember.metadata.any(
        (e) => e.name.name == 'visibleForTesting',
      );
      if (hasVisibleForTestingAnnotation) return;

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
        methodDeclaration.name.lexeme.startsWith('_')) {
      return;
    }

    reporter.atToken(methodDeclaration.name, code);
  }

  void _checkFieldDeclaration(
    FieldDeclaration fieldDeclaration,
    ErrorReporter reporter,
  ) {
    if (fieldDeclaration.isStatic) return;

    for (final variable in fieldDeclaration.fields.variables) {
      if (!variable.name.lexeme.startsWith('_')) {
        reporter.atToken(variable.name, code);
      }
    }
  }
}
