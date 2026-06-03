import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class ConvertToForInIterableIndexedLoop extends ResolvedCorrectionProducer {
  static const _assistKind = AssistKind(
    'dart.assist.convertToForInIterableIndexedLoop',
    30,
    'Convert to for-in iterable.indexed loop',
  );

  ConvertToForInIterableIndexedLoop({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => _assistKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final forStatement = node;
    if (forStatement is! ForStatement) return;

    final forLoopParts = forStatement.forLoopParts;
    if (forLoopParts is! ForEachPartsWithDeclaration) return;

    final loopVariable = forLoopParts.loopVariable;
    final iterable = forLoopParts.iterable;

    final loopVariableType = loopVariable.type;
    final loopVariableKeyword = loopVariable.keyword;
    final keyword = loopVariableKeyword == null ? 'var' : loopVariableKeyword.lexeme;

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(forLoopParts), (builder) {
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
        builder.write('${loopVariable.name}) in ${iterable.toSource()}.indexed');
      });
    });
  }
}
