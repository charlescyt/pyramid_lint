import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_underscore_for_unused_callback_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferUnderscoreForUnusedCallbackParametersRuleTest);
  });
}

@reflectiveTest
class PreferUnderscoreForUnusedCallbackParametersRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferUnderscoreForUnusedCallbackParametersRule();
    super.setUp();
  }

  Future<void> test_unused_callback_parameter() async {
    await assertDiagnostics(
      '''
void invoke(void Function(int a, int b) callback) => callback(1, 2);

void callbackWithUnusedParameter() {
  invoke((a, b) => print(b));
}
''',
      [lint(117, 1)],
    );
  }

  Future<void> test_used_callback_parameters() async {
    await assertNoDiagnostics(
      '''
void invoke(void Function(int a, int b) callback) => callback(1, 2);

void callbackWithUsedParameters() {
  invoke((a, b) => print(a + b));
}
''',
    );
  }

  Future<void> test_underscore_callback_parameter() async {
    await assertNoDiagnostics(
      '''
void invoke(void Function(int a, int b) callback) => callback(1, 2);

void callbackWithUnderscoreParameter() {
  invoke((_, b) => print(b));
}
''',
    );
  }

  Future<void> test_function_declaration() async {
    await assertNoDiagnostics(
      '''
void log(String message) {}
''',
    );
  }
}
