import 'package:analyzer/source/source_range.dart';
import 'package:pyramid_lint/src/assists/dart/invert_boolean_expression.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Invert boolean expression',
    'assists/dart/invert_boolean_expression/invert_boolean_expression.diff',
    sourcePath: 'test/assists/dart/invert_boolean_expression/invert_boolean_expression.dart',
    (result) async {
      final assist = InvertBooleanExpression();

      final changes = [
        // if (number == 0)
        //            ^^
        ...await assist.testRun(result, const SourceRange(74, 0)),

        // if (number > 0)
        //            ^^
        ...await assist.testRun(result, const SourceRange(133, 0)),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
