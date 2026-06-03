import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_iterable_every.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferIterableEveryRuleTest);
  });
}

@reflectiveTest
class PreferIterableEveryRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferIterableEveryRule();
    super.setUp();
  }

  Future<void> test_iterable_where_is_empty() async {
    await assertDiagnostics(
      '''
void f() {
  [1, 2, 3].where((n) => n > 0).isEmpty;
}
''',
      [lint(13, 37)],
    );
  }
}
