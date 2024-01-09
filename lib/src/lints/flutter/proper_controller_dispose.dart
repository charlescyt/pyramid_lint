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
    problemMessage: 'Controller should be disposed in the dispose method.',
    correctionMessage: 'Try adding {0}.dispose() in the dispose method.',
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
      final controllerDeclarations =
          _getControllerDeclarations(fieldDeclarations);

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

  @override
  List<Fix> getFixes() => [_ProperControllerDisposeFix()];
}

Iterable<VariableDeclaration> _getControllerDeclarations(
  Iterable<FieldDeclaration> fieldDeclarations,
) {
  return fieldDeclarations
      .where((e) {
        final type = e.fields.type?.type;
        if (type != null) {
          if (disposableControllerChecker.isExactlyType(type) ||
              changeNotifierChecker.isSuperTypeOf(type)) {
            return true;
          }
        }

        if (type == null) {
          final variableDeclarations = e.fields.variables;
          if (variableDeclarations.length == 1) {
            final variableDeclaration = variableDeclarations.first;
            final initializer = variableDeclaration.initializer;

            if (initializer is InstanceCreationExpression) {
              final staticType = initializer.staticType;
              return switch (staticType) {
                null => false,
                final type => disposableControllerChecker.isExactlyType(type) ||
                    changeNotifierChecker.isSuperTypeOf(type),
              };
            }
          }
        }

        return false;
      })
      .map((e) => e.fields.variables)
      .expand((e) => e);
}

class _ProperControllerDisposeFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final type = node.extendsClause?.superclass.type;
      if (type == null || !widgetStateChecker.isAssignableFromType(type)) {
        return;
      }

      final fieldDeclarations = node.members.fieldDeclarations;
      final controllerDeclarations =
          _getControllerDeclarations(fieldDeclarations);
      final disposeBlock = node.members.findMethodDeclarationByName('dispose');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Dispose all the controllers',
        priority: 80,
      );

      if (disposeBlock == null) {
        int? offset;
        offset = node.members.findMethodDeclarationByName('initState')?.end;
        offset = offset != null ? offset + 2 : null;

        offset =
            offset ?? node.members.findMethodDeclarationByName('build')?.offset;
        offset = offset != null ? offset - 1 : null;

        offset = offset ?? node.end - 2;

        final disposeList = controllerDeclarations
            .map((e) => '${e.name.lexeme}.dispose();')
            .join('\n');

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleInsertion(offset!, '''

@override
void dispose() {
$disposeList
super.dispose();
} 
 ''');
        });
      } else {
        //Search for all the invocations in the block..
        final blockFunctionBody = disposeBlock.childEntities
            .whereType<BlockFunctionBody>()
            .firstOrNull;

        final statements = blockFunctionBody?.block.statements;

        if (statements == null) return;

        final disposedFields = <String>{};

        for (final st in statements) {
          switch (st) {
            case ExpressionStatement() when st.expression is MethodInvocation:
              final target = (st.expression as MethodInvocation).target;

              if (target is SimpleIdentifier) {
                disposedFields.add(target.name);
              }
          }
        }

        final disposablesFieldNames = controllerDeclarations
            .map((e) => e.name.lexeme)
            .toSet()
            .difference(disposedFields);

        final disposeList =
            disposablesFieldNames.map((e) => '$e.dispose();').join('\n');

        final offset = blockFunctionBody!.beginToken.offset;

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleInsertion(offset + 1, '\n$disposeList');
        });
      }
    });
  }
}
