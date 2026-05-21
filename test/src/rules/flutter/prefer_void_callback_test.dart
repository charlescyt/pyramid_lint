// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_void_callback.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferVoidCallbackRuleTest);
  });
}

@reflectiveTest
class PreferVoidCallbackRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferVoidCallbackRule();
    super.setUp();
  }

  Future<void> test_void_function() async {
    await assertDiagnostics(
      '''
typedef B = void Function();
''',
      [lint(12, 15)],
    );
  }

  Future<void> test_nullable_void_function() async {
    await assertDiagnostics(
      '''
typedef A = void Function()?;
''',
      [lint(12, 16)],
    );
  }

  Future<void> test_void_function_with_positional_params() async {
    await assertNoDiagnostics(
      '''
typedef A = void Function(int index);
''',
    );
  }

  Future<void> test_void_function_with_named_params() async {
    await assertNoDiagnostics(
      '''
typedef A = void Function({required int index});
''',
    );
  }
}
