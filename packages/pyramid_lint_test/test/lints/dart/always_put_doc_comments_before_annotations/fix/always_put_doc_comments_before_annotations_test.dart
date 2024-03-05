import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:pyramid_lint/src/lints/dart/always_put_doc_comments_before_annotations.dart';
import 'package:pyramid_lint/src/pyramid_lint_rule.dart';
import 'package:test/test.dart';

import '../../../../golden.dart';

void main() {
  testGolden(
    'Test for always_put_doc_comments_before_annotations fix',
    'lints/dart/always_put_doc_comments_before_annotations/fix/always_put_doc_comments_before_annotations.diff',
    sourcePath:
        'test/lints/dart/always_put_doc_comments_before_annotations/fix/always_put_doc_comments_before_annotations.dart',
    (result) async {
      const options = PyramidLintRuleOptions(params: null);
      final lint = AlwaysPutDocCommentsBeforeAnnotations(options: options);
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
