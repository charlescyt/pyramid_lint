import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/avoid_inverted_boolean_expressions.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for avoid_inverted_boolean_expressions fix',
    'lints/dart/avoid_inverted_boolean_expressions/fix/avoid_inverted_boolean_expressions.diff',
    sourcePath:
        'test/lints/dart/avoid_inverted_boolean_expressions/fix/avoid_inverted_boolean_expressions.dart',
    (result) async {
      const lint = AvoidInvertedBooleanExpressions();
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
