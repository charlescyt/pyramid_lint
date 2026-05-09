// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_iterable_any.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferIterableAnyRuleTest);
  });
}

@reflectiveTest
class PreferIterableAnyRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferIterableAnyRule();
    super.setUp();
  }

  Future<void> test_iterable_where_is_not_empty() async {
    await assertDiagnostics(
      '''
void f() {
  [1, 2, 3].where((n) => n > 0).isNotEmpty;
}
''',
      [lint(13, 40)],
    );
  }
}
