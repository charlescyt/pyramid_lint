// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_iterable_first.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferIterableFirstRuleTest);
  });
}

@reflectiveTest
class PreferIterableFirstRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferIterableFirstRule();
    super.setUp();
  }

  Future<void> test_subscript_operator_with_zero_index() async {
    await assertDiagnostics(
      '''
void f() {
  [1, 2, 3][0];
}
''',
      [lint(13, 12)],
    );
  }

  Future<void> test_element_at_with_zero_index() async {
    await assertDiagnostics(
      '''
void f() {
  [1, 2, 3].elementAt(0);
}
''',
      [lint(13, 22)],
    );
  }

  Future<void> test_subscript_operator_with_non_zero_index() async {
    await assertNoDiagnostics(
      '''
void f() {
  [1, 2, 3][1];
}
''',
    );
  }

  Future<void> test_element_at_with_non_zero_index() async {
    await assertNoDiagnostics(
      '''
void f() {
  [1, 2, 3].elementAt(2);
}
''',
    );
  }
}
