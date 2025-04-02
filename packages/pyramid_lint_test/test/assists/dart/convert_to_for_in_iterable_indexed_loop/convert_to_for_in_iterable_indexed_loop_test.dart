import 'package:analyzer/source/source_range.dart';
import 'package:pyramid_lint/src/assists/dart/convert_to_for_in_iterable_indexed_loop.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Convert to for-in iterable indexed loop',
    'assists/dart/convert_to_for_in_iterable_indexed_loop/convert_to_for_in_iterable_indexed_loop.diff',
    sourcePath:
        'test/assists/dart/convert_to_for_in_iterable_indexed_loop/convert_to_for_in_iterable_indexed_loop.dart',
    (result) async {
      final assist = ConvertToForInIterableIndexedLoop();

      final changes = [
        // for (final String number in numbers) {}
        //  ^^
        ...await assist.testRun(result, const SourceRange(126, 0)),

        // for (final number in numbers) {}
        //              ^^
        ...await assist.testRun(result, const SourceRange(178, 0)),

        // for (final String char in word.split('')) {}
        //                                  ^^
        ...await assist.testRun(result, const SourceRange(260, 0)),
      ];

      expect(changes, hasLength(3));

      return changes;
    },
  );
}
