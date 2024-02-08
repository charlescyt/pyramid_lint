import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/unnecessary_nullable_return_type.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for unnecessary_nullable_return_type fix',
    'lints/dart/unnecessary_nullable_return_type/fix/unnecessary_nullable_return_type.diff',
    sourcePath:
        'test/lints/dart/unnecessary_nullable_return_type/fix/unnecessary_nullable_return_type.dart',
    (result) async {
      const lint = UnnecessaryNullableReturnType();
      final fix = lint.getFixes().single as DartFix;

      final errors = await lint.testRun(result);
      expect(errors, hasLength(2));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
