// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_text_rich.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferTextRichRuleTest);
  });
}

@reflectiveTest
class PreferTextRichRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferTextRichRule();

    // Temporary workaround since analyzer_testing doesn't stub TextSpan yet.
    newFile(
      join(packagesRootPath, 'flutter', 'lib', 'src', 'painting', 'text_span.dart'),
      '''
    class TextSpan {
      final String? text;
      const TextSpan({this.text});
    }
    ''',
    );
    super.setUp();
  }

  Future<void> test_rich_text() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

final t = RichText(
  text: const TextSpan(text: 'a'),
);
''',
      [
        lint(50, 8),
      ],
    );
  }
}
