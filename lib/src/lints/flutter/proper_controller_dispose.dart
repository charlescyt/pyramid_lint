import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/class_members_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/lint_code_extensions.dart';
import '../../utils/pubspec_extensions.dart';
import '../../utils/statements_extensions.dart';
import '../../utils/type_checker.dart';

class ProperControllerDispose extends DartLintRule {
  const ProperControllerDispose() : super(code: _code);

  static const name = 'proper_controller_dispose';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Controller should be disposed in dispose method',
    correctionMessage: 'Add {0}.dispose() in dispose method}',
    url: '$docUrl#${ProperControllerDispose.name}',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addClassDeclaration((node) {
      final type = node.extendsClause?.superclass.type;
      if (type == null || !widgetStateChecker.isAssignableFromType(type)) {
        return;
      }

      final fieldDeclarations = node.members.fieldDeclarations;
      final controllerDeclarations = fieldDeclarations
          .where((e) {
            final type = e.fields.type?.type;
            if (type != null &&
                disposableControllerChecker.isExactlyType(type)) {
              return true;
            }

            if (type == null) {
              final variableDeclarations = e.fields.variables;
              if (variableDeclarations.length == 1) {
                final variableDeclaration = variableDeclarations.first;
                final initializer = variableDeclaration.initializer;
                if (initializer is InstanceCreationExpression &&
                    disposableControllerChecker
                        .isExactlyType(initializer.staticType!)) {
                  return true;
                }
              }
            }

            return false;
          })
          .map((e) => e.fields.variables)
          .expand((e) => e);

      if (controllerDeclarations.isEmpty) return;

      final disposeMethodDeclaration =
          node.members.findMethodDeclarationByName('dispose');
      if (disposeMethodDeclaration == null) {
        reporter.reportErrorForToken(
          code.copyWith(
            problemMessage:
                'There is no dispose method to dispose controllers.',
            correctionMessage: 'Add dispose method.',
          ),
          node.name,
        );
        return;
      }

      final body = disposeMethodDeclaration.body;
      if (body is! BlockFunctionBody) {
        reporter.reportErrorForNode(code, body);
        return;
      }

      final statements = body.block.statements;
      final disposeStatementTargetNames = statements.expressionStatements
          .map((e) {
            final expression = e.expression;
            if (expression is MethodInvocation) {
              final target = expression.target;
              if (target is SimpleIdentifier) {
                return target.name;
              }
            }
            return null;
          })
          .whereType<String>()
          .toList();

      for (final controllerDeclaration in controllerDeclarations) {
        if (!disposeStatementTargetNames
            .contains(controllerDeclaration.name.lexeme)) {
          reporter.reportErrorForElement(
            code,
            controllerDeclaration.declaredElement!,
            [controllerDeclaration.name.lexeme],
          );
        }
      }
    });
  }
}
