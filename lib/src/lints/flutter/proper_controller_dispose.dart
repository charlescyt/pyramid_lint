import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
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

      if (parent is! ClassDeclaration || parent.extendsClause == null) {
        return;
      }

      final extendClase = parent.extendsClause!;
      final superClassElem = extendClase.superclass.element;

      switch (superClassElem) {
        case null:
          return;
        case ClassElement()
            when !(stateChecker.isExactlyType(superClassElem.thisType) ||
                stateChecker.isSuperTypeOf(superClassElem.thisType)):
          return;
      }

      final disposeFunctionBody =
          parent.members.findMethodDeclarationByName('dispose')?.body;

      final controllerVariables =
          node.fields.variables.map((e) => e.declaredElement!).where(
                (e) =>
                    changeNotifierChecker.isSuperTypeOf(e.type) ||
                    disposableControllerChecker.isExactlyType(e.type),
              );

      if (disposeFunctionBody == null ||
          disposeFunctionBody is! BlockFunctionBody) {
        for (final variable in controllerVariables) {
          final varName = variable.name;
          reporter.reportErrorForElement(
            code,
            variable,
            [varName],
          );
        }
        return;
      }

      final statements = disposeFunctionBody.block.statements;
      final disposeStatementTargetNames = statements.expressionStatements
          .map((e) {
            return switch (e.expression) {
              final MethodInvocation exp when exp.target is SimpleIdentifier =>
                (exp.target! as SimpleIdentifier).name,
              _ => null
            };
          })
          .whereNotNull()
          .toList();

      for (final variable in controllerVariables) {
        if (!disposeStatementTargetNames.contains(variable.name)) {
          for (final variable in controllerVariables) {
            final variableName = variable.name;
            reporter.reportErrorForElement(
              code,
              variable,
              [variableName],
            );
          }
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

      final controllerVariables =
          node.fields.variables.map((e) => e.declaredElement!).where(
                (e) =>
                    changeNotifierChecker.isSuperTypeOf(e.type) ||
                    disposableControllerChecker.isExactlyType(e.type),
              );

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

        /// Always pick the first variable.
        final variableName = controllerVariables.first.name;

        changeBuilder.addDartFileEdit((builder) {
          builder.addInsertion(offset, (builder) {
            if (addNewLineAtTheStart) builder.write('\n');
            builder.write('  @override\n');
            builder.write('  void dispose() {\n');
            builder.write('    $variableName.dispose();\n');
            builder.write('    super.dispose();\n');
            builder.write('  }\n');
            if (addNewLineAtTheEnd) builder.write('\n');
          });
        });

        return;
      } else if (disposeFunctionBody is BlockFunctionBody) {
        final statements = disposeFunctionBody.block.statements;
        final disposeStatementTargetNames = statements.expressionStatements
            .map((e) {
              return switch (e.expression) {
                final MethodInvocation exp
                    when exp.target is SimpleIdentifier =>
                  (exp.target! as SimpleIdentifier).name,
                _ => null
              };
            })
            .whereNotNull()
            .toList();

        for (final variable in controllerVariables) {
          final variableName = variable.name;

          if (!disposeStatementTargetNames.contains(variableName)) {
            changeBuilder.addDartFileEdit((builder) {
              builder.addInsertion(disposeFunctionBody.offset + 1, (builder) {
                builder.write('\n    $variableName.dispose();');
              });
            });

            // Intensional return to dispose only the first variable.
            return;
          }
        }
      }
    });
  }
}
