import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/avoid_mutable_global_variables.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidMutableGlobalVariablesRuleTest);
  });
}

@reflectiveTest
class AvoidMutableGlobalVariablesRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidMutableGlobalVariablesRule();
    super.setUp();
  }

  Future<void> test_mutable_global_variable() async {
    await assertDiagnostics(
      '''
double pi = 3.14;
''',
      [lint(7, 2)],
    );
  }

  Future<void> test_mutable_global_variable_with_const() async {
    await assertNoDiagnostics(
      '''
const double pi = 3.14;
''',
    );
  }

  Future<void> test_mutable_global_variable_with_final() async {
    await assertNoDiagnostics(
      '''
final double pi = 3.14;
''',
    );
  }

  Future<void> test_late_mutable_global_variable() async {
    await assertDiagnostics(
      '''
late double pi;
''',
      [lint(12, 2)],
    );
  }

  Future<void> test_late_final_global_variable() async {
    await assertNoDiagnostics(
      '''
late final double pi;
''',
    );
  }

  Future<void> test_multiple_mutable_global_variables() async {
    await assertDiagnostics(
      '''
var a = 1, b = 2;
''',
      [lint(4, 1), lint(11, 1)],
    );
  }
}
