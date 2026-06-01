import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/max_lines_for_function.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MaxLinesForFunctionRuleTest);
  });
}

@reflectiveTest
class MaxLinesForFunctionRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MaxLinesForFunctionRule();
    super.setUp();
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''
linter:
  rules:
    max_lines_for_function: true

plugins:
  pyramid_lint:
    options:
      max_lines_for_function:
        max_lines: 3
''',
    );
  }

  Future<void> test_short_function() async {
    await assertNoDiagnostics(
      '''
void main() {}
''',
    );
  }

  Future<void> test_long_function() async {
    await assertDiagnostics(
      '''
void longFunction() {
  print('one');
  print('two');
}
''',
      [
        lint(0, 55, messageContainsAll: ['function'], correctionContains: '3'),
      ],
    );
  }

  Future<void> test_short_method() async {
    await assertNoDiagnostics(
      '''
class A {
  void m() {}
}
''',
    );
  }

  Future<void> test_long_method() async {
    await assertDiagnostics(
      '''
class A {
  void longMethod() {
    print('one');
    print('two');
  }
}
''',
      [
        lint(12, 59, messageContainsAll: ['method'], correctionContains: '3'),
      ],
    );
  }
}
