import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/prefer_iterable_any.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_iterable_any fix',
    'lints/dart/prefer_iterable_any/fix/prefer_iterable_any.diff',
    sourcePath:
        'test/lints/dart/prefer_iterable_any/fix/prefer_iterable_any.dart',
    (result) async {
      const lint = PreferIterableAny();
      final fix = lint.getFixes().single as DartFix;

      final errors = await lint.testRun(result);
      expect(errors, hasLength(11));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
