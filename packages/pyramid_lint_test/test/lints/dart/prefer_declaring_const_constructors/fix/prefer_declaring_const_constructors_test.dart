import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/prefer_declaring_const_constructors.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_declaring_const_constructors fix',
    'lints/dart/prefer_declaring_const_constructors/fix/prefer_declaring_const_constructors.diff',
    sourcePath:
        'test/lints/dart/prefer_declaring_const_constructors/fix/prefer_declaring_const_constructors.dart',
    (result) async {
      const lint = PreferDeclaringConstConstructors();
      final fix = lint.getFixes().single as DartFix;

      final errors = await lint.testRun(result);
      expect(errors, hasLength(3));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
