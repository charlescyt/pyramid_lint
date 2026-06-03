import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/unnecessary_nullable_return_type.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnnecessaryNullableReturnTypeRuleTest);
  });
}

@reflectiveTest
class UnnecessaryNullableReturnTypeRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UnnecessaryNullableReturnTypeRule();
    super.setUp();
  }

  Future<void> test_block_function_with_non_nullable_returns() async {
    await assertDiagnostics(
      '''
int? sum(int a, int b) {
  return a + b;
}
''',
      [lint(0, 4)],
    );
  }

  Future<void> test_block_function_with_nullable_returns() async {
    await assertNoDiagnostics(
      '''
String? f(bool condition) {
  if (condition) {
    return null;
  } else {
    return 'not null';
  }
}
''',
    );
  }

  Future<void> test_expression_method_with_non_nullable_return() async {
    await assertDiagnostics(
      '''
class A {
  int? sum(int a, int b) => a + b;
}
''',
      [lint(12, 4)],
    );
  }

  Future<void> test_expression_method_with_nullable_returns() async {
    await assertNoDiagnostics(
      '''
class A {
  String? method(bool condition) {
    if (condition) {
      return null;
    } else {
      return 'not null';
    }
  }
}
''',
    );
  }
}
