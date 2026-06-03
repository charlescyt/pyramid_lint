import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_new_line_before_return.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferNewLineBeforeReturnRuleTest);
  });
}

@reflectiveTest
class PreferNewLineBeforeReturnRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferNewLineBeforeReturnRule();
    super.setUp();
  }

  Future<void> test_single_return_statement_within_block() async {
    await assertNoDiagnostics(
      '''
void f(bool isTrue) {
  if (isTrue) {
    return;
  }
}
''',
    );
  }

  Future<void> test_return_without_blank_line_in_multi_statement_block() async {
    await assertDiagnostics(
      '''
void f(bool isTrue) {
  if (isTrue) {
    print('x');
    return;
  }
}
''',
      [lint(58, 7)],
    );
  }

  Future<void> test_return_with_blank_line_in_multi_statement_block() async {
    await assertNoDiagnostics(
      '''
void f(bool isTrue) {
  if (isTrue) {
    print('x');

    return;
  }
}
''',
    );
  }
}
