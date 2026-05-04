// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/always_specify_parameter_names.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AlwaysSpecifyParameterNamesRuleTest);
  });
}

@reflectiveTest
class AlwaysSpecifyParameterNamesRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AlwaysSpecifyParameterNamesRule();
    super.setUp();
  }

  Future<void> test_function_type_unnamed_parameter() async {
    await assertDiagnostics(
      '''
typedef F = void Function(int);
''',
      [lint(26, 3)],
    );
  }

  Future<void> test_function_type_named_parameter() async {
    await assertNoDiagnostics(
      '''
typedef F = void Function(int x);
''',
    );
  }

  Future<void> test_function_type_multiple_unnamed_parameters() async {
    await assertDiagnostics(
      '''
typedef F = void Function(int, String);
''',
      [lint(26, 3), lint(31, 6)],
    );
  }
}
