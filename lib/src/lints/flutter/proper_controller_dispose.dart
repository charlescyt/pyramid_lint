import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/class_members_extensions.dart';
import '../../utils/constants.dart';
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

    context.registry.addFieldDeclaration((node) {
      final parent = node.parent;

      if (parent is! ClassDeclaration) {
        return;
      }

      final superClassType = parent.extendsClause?.superclass.type;
      if (superClassType == null ||
          !widgetStateChecker.isAssignableFromType(superClassType)) return;

      final disposeFunctionBody =
          parent.members.findMethodDeclarationByName('dispose')?.body;

      final controllerDeclarations = node.fields.variables.where(
        (e) {
          final variableType = e.declaredElement?.type;
          if (variableType == null) return false;
          return disposableControllerChecker.isAssignableFromType(variableType);
        },
      );

      if (disposeFunctionBody == null ||
          disposeFunctionBody is! BlockFunctionBody) {
        for (final controller in controllerDeclarations) {
          final controllerName = controller.name.lexeme;
          reporter.reportErrorForToken(
            code,
            controller.name,
            [controllerName],
          );
        }
        return;
      }

      final statements = disposeFunctionBody.block.statements;
      final disposeStatementTargetNames =
          _getDisposeStatementTargetNames(statements);

      for (final controllerDeclaration in controllerDeclarations) {
        final controllerName = controllerDeclaration.name.lexeme;
        if (!disposeStatementTargetNames.contains(controllerName)) {
          reporter.reportErrorForToken(
            code,
            controllerDeclaration.name,
            [controllerName],
          );
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_ProperControllerDisposeFix()];
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
    context.registry.addFieldDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final parent = node.parent! as ClassDeclaration;

      final disposeFunctionBody =
          parent.members.findMethodDeclarationByName('dispose')?.body;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Dispose controller',
        priority: 80,
      );

      final controllerDeclarations = node.fields.variables.where(
        (e) {
          final variableType = e.declaredElement?.type;
          if (variableType == null) return false;
          return disposableControllerChecker.isAssignableFromType(variableType);
        },
      );

      final controllerToBeDisposed = controllerDeclarations.firstWhereOrNull(
        (e) => e.name.sourceRange == analysisError.sourceRange,
      );

      if (controllerToBeDisposed == null) return;

      final toBeDisposedControllerName = controllerToBeDisposed.name.lexeme;

      if (disposeFunctionBody == null) {
        final initStateMethod = parent.members.findMethodDeclarationByName(
          'initState',
        );

        final buildMethod = parent.members.findMethodDeclarationByName('build');

        final (int offset, bool addNewLineAtTheStart, bool addNewLineAtTheEnd) =
            switch ((initStateMethod, buildMethod)) {
          (null, null) => (node.end, true, false),
          (null, final buildMethod?) => (buildMethod.offset, true, true),
          (final initStateMethod?, null) => (initStateMethod.end, true, false),
          (final _?, final buildMethod?) => (buildMethod.offset, false, true),
        };

        changeBuilder.addDartFileEdit((builder) {
          builder.addInsertion(offset, (builder) {
            if (addNewLineAtTheStart) builder.write('\n');
            builder.write('  @override\n');
            builder.write('  void dispose() {\n');
            builder.write('    $toBeDisposedControllerName.dispose();\n');
            builder.write('    super.dispose();\n');
            builder.write('  }\n');
            if (addNewLineAtTheEnd) builder.write('\n');
          });
        });

        return;
      }

      if (disposeFunctionBody is BlockFunctionBody) {
        final statements = disposeFunctionBody.block.statements;
        final disposeStatementTargetNames =
            _getDisposeStatementTargetNames(statements);

        if (!disposeStatementTargetNames.contains(toBeDisposedControllerName)) {
          changeBuilder.addDartFileEdit((builder) {
            builder.addInsertion(disposeFunctionBody.beginToken.end, (builder) {
              builder.write('\n    $toBeDisposedControllerName.dispose();');
            });
          });
        }

        return;
      }

      if (disposeFunctionBody is ExpressionFunctionBody) {
        changeBuilder.addDartFileEdit((builder) {
          builder.addReplacement(disposeFunctionBody.sourceRange, (builder) {
            builder.write('{\n');
            builder.write('    $toBeDisposedControllerName.dispose();\n');
            builder.write('    super.dispose();\n');
            builder.write('  }\n');
          });
        });
      }
    });
  }
}

Iterable<String> _getDisposeStatementTargetNames(
  NodeList<Statement> statements,
) {
  return statements.expressionStatements
      .map((e) => e.expression)
      .whereType<MethodInvocation>()
      .map(_getTargetNameOfDisposeMethodInvocation)
      .whereNotNull();
}

String? _getTargetNameOfDisposeMethodInvocation(
  MethodInvocation invocation,
) {
  final target = invocation.target;
  if (target is! SimpleIdentifier) return null;

  final methodName = invocation.methodName.name;
  if (methodName != 'dispose') return null;

  return target.name;
}
