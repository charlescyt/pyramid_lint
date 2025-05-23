import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ConvertToForInIterableIndexedLoop extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addForStatement((node) {
      if (!node.sourceRange.covers(target)) return;

      final forLoopParts = node.forLoopParts;
      if (forLoopParts is! ForEachPartsWithDeclaration) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to for-in iterable.indexed loop',
        priority: 30,
      );

      changeBuilder.addDartFileEdit((builder) {
        final loopVariable = forLoopParts.loopVariable;
        final iterable = forLoopParts.iterable;

        final loopVariableType = loopVariable.type;
        final loopVariableKeyword = loopVariable.keyword;
        final keyword =
            loopVariableKeyword ==
                null //
            ? 'var'
            : loopVariableKeyword.lexeme;

        builder.addReplacement(forLoopParts.sourceRange, (builder) {
          builder.write('$keyword (');
          if (loopVariableType != null) {
            builder.write('int ');
          }
          builder.addSimpleLinkedEdit(
            'index',
            'index',
            kind: LinkedEditSuggestionKind.VARIABLE,
            suggestions: ['index', 'i'],
          );
          builder.write(', ');
          if (loopVariableType != null) {
            builder.write('${loopVariableType.toSource()} ');
          }
          builder.write(
            '${loopVariable.name}) in ${iterable.toSource()}.indexed',
          );
        });
      });
    });
  }
}
