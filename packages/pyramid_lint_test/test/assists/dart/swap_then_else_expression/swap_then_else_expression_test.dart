import 'package:analyzer/source/source_range.dart';
import 'package:pyramid_lint/src/assists/dart/swap_then_else_expression.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Swap then else expression',
    'assists/dart/swap_then_else_expression/swap_then_else_expression.diff',
    sourcePath:
        'test/assists/dart/swap_then_else_expression/swap_then_else_expression.dart',
    (result) async {
      final assist = SwapThenElseExpression();

      final changes = [
        // if (condition)
        //         ^^
        ...await assist.testRun(result, const SourceRange(98, 0)),

        // print('then');
        //   ^^
        ...await assist.testRun(result, const SourceRange(113, 0)),

        // final text = condition ? 'then' : 'else';
        //                            ^^
        ...await assist.testRun(result, const SourceRange(190, 0)),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
