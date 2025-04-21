import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class DisposeControllers extends PyramidLintRule {
  DisposeControllers({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'Controller should be disposed in the dispose method.',
          correctionMessage: 'Try adding {0}.dispose() in the dispose method.',
          url: url,
          errorSeverity: ErrorSeverity.ERROR,
        );

  static const ruleName = 'dispose_controllers';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory DisposeControllers.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return DisposeControllers(options: options);
  }

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
          !stateChecker.isAssignableFromType(superClassType)) {
        return;
      }

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
          reporter.atToken(
            controller.name,
            code,
            arguments: [controllerName],
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
          reporter.atToken(
            controllerDeclaration.name,
            code,
            arguments: [controllerName],
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Dispose controller',
        priority: 80,
      );

      final controllerToBeDisposed = node.fields.variables.firstWhereOrNull(
        (e) => analysisError.sourceRange.intersects(e.sourceRange),
      );
      if (controllerToBeDisposed == null) return;

      final disposeMethod =
          parent.members.findMethodDeclarationByName('dispose');
      final toBeDisposedControllerName = controllerToBeDisposed.name.lexeme;

      switch (disposeMethod?.body) {
        case null:
          _handleNullFunctionBody(
            parent,
            node,
            toBeDisposedControllerName,
            changeBuilder,
          );
        case final BlockFunctionBody body:
          _handleBlockFunctionBody(
            body,
            toBeDisposedControllerName,
            changeBuilder,
          );
        case final ExpressionFunctionBody body:
          _handleExpressionFunctionBody(
            body,
            toBeDisposedControllerName,
            changeBuilder,
          );
        case EmptyFunctionBody() || NativeFunctionBody():
      }
    });
  }

  void _handleNullFunctionBody(
    ClassDeclaration parent,
    FieldDeclaration node,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
    final initStateMethod = parent.members.findMethodDeclarationByName(
      'initState',
    );

    final buildMethod = parent.members.findMethodDeclarationByName('build');

    final (int offset, bool addNewLineAtTheStart, bool addNewLineAtTheEnd) =
        switch ((initStateMethod, buildMethod)) {
      (null, null) => (node.end, true, false),
      (null, final buildMethod?) => (buildMethod.offset, false, true),
      (final initStateMethod?, null) => (initStateMethod.end, true, false),
      (final _?, final buildMethod?) => (buildMethod.offset, false, true),
    };

    // TODO(charlescyt): Improve the fix.
    changeBuilder.addDartFileEdit((builder) {
      builder.addInsertion(offset, (builder) {
        if (addNewLineAtTheStart) builder.writeln();
        builder.writeln('@override');
        builder.writeln('  void dispose() {');
        builder.writeln('    $toBeDisposedControllerName.dispose();');
        builder.writeln('    super.dispose();');
        builder.writeln('  }');
        if (addNewLineAtTheEnd) builder.writeln();
        builder.write('  ');
      });
    });
  }

  void _handleBlockFunctionBody(
    BlockFunctionBody disposeFunctionBody,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
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
  }

  void _handleExpressionFunctionBody(
    ExpressionFunctionBody disposeFunctionBody,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
    changeBuilder.addDartFileEdit((builder) {
      builder.addReplacement(disposeFunctionBody.sourceRange, (builder) {
        builder.writeln('{');
        builder.writeln('    $toBeDisposedControllerName.dispose();');
        builder.writeln('    ${disposeFunctionBody.expression.toSource()};');
        builder.write('  }');
      });
    });
  }
}

Iterable<String> _getDisposeStatementTargetNames(
  NodeList<Statement> statements,
) {
  return statements.expressionStatements
      .map(_getTargetNameOfDisposeMethodInvocation)
      .nonNulls;
}

String? _getTargetNameOfDisposeMethodInvocation(
  ExpressionStatement expressionStatement,
) {
  if (expressionStatement.expression
      case final CascadeExpression cascadeExpression) {
    for (final section in cascadeExpression.cascadeSections) {
      if (section is MethodInvocation && section.methodName.name == 'dispose') {
        if (cascadeExpression.target
            case final SimpleIdentifier simpleIdentifier) {
          return simpleIdentifier.name;
        }
      }
    }
  } else if (expressionStatement.expression
      case final MethodInvocation methodInvocation) {
    final target = methodInvocation.target;
    if (target is! SimpleIdentifier) return null;

    final methodName = methodInvocation.methodName.name;
    if (methodName != 'dispose') return null;

    return target.name;
  }

  return null;
}
