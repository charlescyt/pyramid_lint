import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/argument_list_extensions.dart';
import '../utils/type_checker.dart';

class UseEdgeInsetsZero extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      if (!target.intersects(node.sourceRange)) return;

      final type = node.staticType;
      if (type == null || !edgeInsetsChecker.isExactlyType(type)) return;

      final constructorName = node.constructorName.name?.name;
      if (constructorName != 'all' &&
          constructorName != 'fromLTRB' &&
          constructorName != 'only' &&
          constructorName != 'symmetric') return;

      if (constructorName == 'all') {
        final arguments = node.argumentList.positionalArguments;
        if (arguments.length != 1 ||
            arguments.first is! IntegerLiteral ||
            (arguments.first as IntegerLiteral).value != 0) return;
      }

      if (constructorName == 'fromLTRB') {
        final arguments = node.argumentList.positionalArguments;
        if (arguments.length != 4 ||
            arguments.any((e) => e is! IntegerLiteral) ||
            arguments.any((e) => (e as IntegerLiteral).value != 0)) return;
      }

      if (constructorName == 'only') {
        final arguments = node.argumentList.namedArguments;
        if (arguments.any((e) => e.expression is! IntegerLiteral) ||
            arguments.any((e) => (e.expression as IntegerLiteral).value != 0)) {
          return;
        }
      }

      if (constructorName == 'symmetric') {
        final arguments = node.argumentList.namedArguments;
        if (arguments.any((e) => e.expression is! IntegerLiteral) ||
            arguments.any((e) => (e.expression as IntegerLiteral).value != 0)) {
          return;
        }
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with EdgeInsets.zero',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          node.sourceRange,
          'EdgeInsets.zero',
        );
      });
    });
  }
}
