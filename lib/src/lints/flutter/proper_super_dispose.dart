import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class ProperSuperDispose extends DartLintRule {
  const ProperSuperDispose()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'super.dispose() should be called at the end of the dispose method.',
            correctionMessage:
                'Try placing super.dispose() at the end of the dispose method.',
            url: '$flutterLintDocUrl/${ProperSuperDispose.name}',
            errorSeverity: ErrorSeverity.ERROR,
          ),
        );

  static const name = 'proper_super_dispose';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addClassDeclaration((node) {
      final extendsClause = node.extendsClause;
      if (extendsClause == null) return;

      final type = extendsClause.superclass.type;
      if (type == null || !widgetStateChecker.isAssignableFromType(type)) {
        return;
      }

      final body = node.members.findMethodDeclarationByName('dispose')?.body;
      if (body == null || body is! BlockFunctionBody) return;

      final statements = body.block.statements;
      if (statements.isEmpty) return;

      if (statements.last.toSource() == 'super.dispose();') return;

      final superDisposeStatement = statements.lastWhereOrNull(
        (statement) => statement.toSource() == 'super.dispose();',
      );
      if (superDisposeStatement == null) return;

      reporter.reportErrorForNode(code, superDisposeStatement);
    });
  }

  @override
  List<Fix> getFixes() => [_PlaceSuperDisposeAtTheEnd()];
}

class _PlaceSuperDisposeAtTheEnd extends DartFix {
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

      final body = node.members.findMethodDeclarationByName('dispose')?.body;
      if (body == null || body is! BlockFunctionBody) return;

      final statements = body.block.statements;
      if (statements.isEmpty) return;

      final superDisposeStatement = statements.lastWhereOrNull(
        (statement) => statement.toSource() == 'super.dispose();',
      );
      if (superDisposeStatement == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Place super.dispose() at the end of the dispose method',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final superDisposeStatementIndex = statements.indexOf(
          superDisposeStatement,
        );
        final lastStatement = statements.last;

        for (var i = superDisposeStatementIndex;
            i < statements.length - 1;
            i++) {
          builder.addSimpleReplacement(
            statements[i].sourceRange,
            statements[i + 1].toSource(),
          );
        }

        builder.addSimpleReplacement(
          lastStatement.sourceRange,
          superDisposeStatement.toSource(),
        );
      });
    });
  }
}
