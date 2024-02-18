import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/prefer_iterable_first.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_iterable_first fix',
    'lints/dart/prefer_iterable_first/fix/prefer_iterable_first.diff',
    sourcePath:
        'test/lints/dart/prefer_iterable_first/fix/prefer_iterable_first.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = PreferIterableFirst(options: options);
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
