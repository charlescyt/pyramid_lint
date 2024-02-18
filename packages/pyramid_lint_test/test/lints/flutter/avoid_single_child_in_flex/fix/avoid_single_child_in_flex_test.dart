import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/lints/flutter/avoid_single_child_in_flex.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for avoid_single_child_in_flex fix 1',
    'lints/flutter/avoid_single_child_in_flex/fix/avoid_single_child_in_flex_1.diff',
    sourcePath:
        'test/lints/flutter/avoid_single_child_in_flex/fix/avoid_single_child_in_flex.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = AvoidSingleChildInFlex(options: options);
      final fix = lint.getFixes().first as DartFix;
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final errors = await lint.testRun(result, pubspec: pubspec);
      expect(errors, hasLength(1));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );

  testGolden(
    'Test for avoid_single_child_in_flex fix 2',
    'lints/flutter/avoid_single_child_in_flex/fix/avoid_single_child_in_flex_2.diff',
    sourcePath:
        'test/lints/flutter/avoid_single_child_in_flex/fix/avoid_single_child_in_flex.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = AvoidSingleChildInFlex(options: options);
      final fix = lint.getFixes().last as DartFix;
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final errors = await lint.testRun(result, pubspec: pubspec);
      expect(errors, hasLength(1));

      final changes = await Future.wait([
        for (final error in errors) fix.testRun(result, error, errors),
      ]);

      return changes.flattened;
    },
  );
}
