import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class AvoidReturningWidgets extends DartLintRule {
  const AvoidReturningWidgets() : super(code: _code);

  static const name = 'avoid_returning_widgets';

  static const _code = LintCode(
    name: name,
    problemMessage:
        'Returning widgets is not recommended for performance reasons.',
    correctionMessage: 'Consider creating a separate widget instead.',
    url: '$flutterLintDocUrl/${AvoidReturningWidgets.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addMethodDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null) return;

      if (!widgetChecker.isAssignableFromType(returnType)) return;

      if (node.name.lexeme == 'build' || node.name.lexeme == 'createState') {
        return;
      }

      // if (isWidgetBuildMethod(node)) return;
      // if (isStatefulWidgetCreateStateMethod(node)) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null) return;

      if (!widgetChecker.isAssignableFromType(returnType)) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  // bool isWidgetBuildMethod(MethodDeclaration node) {
  //   final methodName = node.name.lexeme;
  //   if (methodName != 'build') return false;

  //   final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
  //   if (classDeclaration == null) return false;

  //   final extendsClause = classDeclaration.extendsClause;
  //   if (extendsClause == null) return false;

  //   final type = extendsClause.superclass.type;
  //   if (type == null) return false;

  //   if (!statelessWidgetChecker.isAssignableFromType(type) &&
  //       !widgetStateChecker.isAssignableFromType(type)) return false;

  //   return true;
  // }

  // bool isStatefulWidgetCreateStateMethod(MethodDeclaration node) {
  //   final methodName = node.name.lexeme;
  //   if (methodName != 'createState') return false;

  //   final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
  //   if (classDeclaration == null) return false;

  //   final extendsClause = classDeclaration.extendsClause;
  //   if (extendsClause == null) return false;

  //   final type = extendsClause.superclass.type;
  //   if (type == null) return false;

  //   if (!statefulWidgetChecker.isAssignableFromType(type)) return false;

  //   return true;
  // }
}
