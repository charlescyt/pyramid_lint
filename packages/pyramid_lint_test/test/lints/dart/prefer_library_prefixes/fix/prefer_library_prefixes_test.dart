import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/prefer_library_prefixes.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_library_prefixes fix',
    'lints/dart/prefer_library_prefixes/fix/prefer_library_prefixes.diff',
    sourcePath:
        'test/lints/dart/prefer_library_prefixes/fix/prefer_library_prefixes.dart',
    (result) async {
      const params = PreferLibraryPrefixesOptions(
        includeDefaultLibraries: true,
        libraries: ['dart:io'],
      );
      const options = PyramidLintRuleOptions(params: params);
      final lint = PreferLibraryPrefixes(options: options);
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
