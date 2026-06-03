import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_async_callback.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferAsyncCallbackRuleTest);
  });
}

@reflectiveTest
class PreferAsyncCallbackRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferAsyncCallbackRule();
    super.setUp();
  }

  Future<void> test_future_void_function() async {
    await assertDiagnostics(
      '''
typedef A = Future<void> Function();
''',
      [lint(12, 23)],
    );
  }

  Future<void> test_nullable_future_void_function() async {
    await assertDiagnostics(
      '''
typedef A = Future<void> Function()?;
''',
      [lint(12, 24)],
    );
  }

  Future<void> test_future_int_function() async {
    await assertNoDiagnostics(
      '''
typedef A = Future<int> Function();
''',
    );
  }

  Future<void> test_raw_future_function() async {
    await assertNoDiagnostics(
      '''
typedef A = Future Function();
''',
    );
  }

  Future<void> test_future_void_with_positional_params() async {
    await assertNoDiagnostics(
      '''
typedef A = Future<void> Function(int index);
''',
    );
  }

  Future<void> test_future_void_with_named_params() async {
    await assertNoDiagnostics(
      '''
typedef A = Future<void> Function({required int index});
''',
    );
  }
}
