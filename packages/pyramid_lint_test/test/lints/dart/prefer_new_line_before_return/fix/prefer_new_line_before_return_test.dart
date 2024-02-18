import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/prefer_new_line_before_return.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_new_line_before_return fix',
    'lints/dart/prefer_new_line_before_return/fix/prefer_new_line_before_return.diff',
    sourcePath:
        'test/lints/dart/prefer_new_line_before_return/fix/prefer_new_line_before_return.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = PreferNewLineBeforeReturn(options: options);
      final fix = lint.getFixes().single as DartFix;

      final errors = await lint.testRun(result);
      expect(errors, hasLength(1));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
