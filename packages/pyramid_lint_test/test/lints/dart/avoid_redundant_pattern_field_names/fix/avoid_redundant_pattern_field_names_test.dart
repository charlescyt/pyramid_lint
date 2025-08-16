import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/avoid_redundant_pattern_field_names.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for avoid_redundant_pattern_field_names fix',
    'lints/dart/avoid_redundant_pattern_field_names/fix/avoid_redundant_pattern_field_names.diff',
    sourcePath: 'test/lints/dart/avoid_redundant_pattern_field_names/fix/avoid_redundant_pattern_field_names.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = AvoidRedundantPatternFieldNames(options: options);
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
