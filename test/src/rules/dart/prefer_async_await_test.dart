// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_async_await.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferAsyncAwaitRuleTest);
  });
}

@reflectiveTest
class PreferAsyncAwaitRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferAsyncAwaitRule();
    super.setUp();
  }

  Future<void> test_future_then() async {
    await assertDiagnostics(
      '''
void f() {
  Future.value(1).then((value) => value);
}
''',
      [lint(13, 38)],
    );
  }
}
