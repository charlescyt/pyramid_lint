import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/no_self_comparisons.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoSelfComparisonsRuleTest);
  });
}

@reflectiveTest
class NoSelfComparisonsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoSelfComparisonsRule();
    super.setUp();
  }

  Future<void> test_self_comparison() async {
    await assertDiagnostics(
      '''
void f(int number) {
  if (number == number) {}
}
''',
      [lint(27, 16)],
    );
  }

  Future<void> test_self_comparison_with_parenthesis() async {
    await assertDiagnostics(
      '''
void f(int number) {
  if (number > (number)) {}
}
''',
      [lint(27, 17)],
    );
  }

  Future<void> test_self_comparison_with_property() async {
    await assertDiagnostics(
      '''
void f(int number) {
  if (number.sign == number.sign) {}
}
''',
      [lint(27, 26)],
    );
  }
}
