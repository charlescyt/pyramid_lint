// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_iterable_last.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferIterableLastRuleTest);
  });
}

@reflectiveTest
class PreferIterableLastRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferIterableLastRule();
    super.setUp();
  }

  Future<void> test_subscript_operator_with_last_index() async {
    await assertDiagnostics(
      '''
void f(List<int> list) {
  list[list.length - 1];
}
''',
      [lint(27, 21)],
    );
  }

  Future<void> test_element_at_with_last_index() async {
    await assertDiagnostics(
      '''
void f(List<int> list) {
  list.elementAt(list.length - 1);
}
''',
      [lint(27, 31)],
    );
  }

  Future<void> test_subscript_operator_with_non_last_index() async {
    await assertNoDiagnostics(
      '''
void f(List<int> list) {
  list[list.length - 2];
}
''',
    );
  }

  Future<void> test_element_at_with_non_last_index() async {
    await assertNoDiagnostics(
      '''
void f(List<int> list) {
  list.elementAt(list.length - 2);
}
''',
    );
  }
}
