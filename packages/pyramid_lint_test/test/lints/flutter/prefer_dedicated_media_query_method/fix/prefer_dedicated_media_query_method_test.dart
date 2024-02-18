import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/lints/flutter/prefer_dedicated_media_query_method.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for prefer_dedicated_media_query_method fix',
    'lints/flutter/prefer_dedicated_media_query_method/fix/prefer_dedicated_media_query_method.diff',
    sourcePath:
        'test/lints/flutter/prefer_dedicated_media_query_method/fix/prefer_dedicated_media_query_method.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = PreferDedicatedMediaQueryMethod(options: options);
      final fix = lint.getFixes().single as DartFix;
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final errors = await lint.testRun(result, pubspec: pubspec);
      expect(errors, hasLength(80));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
