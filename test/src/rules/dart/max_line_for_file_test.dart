import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/max_line_for_file.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MaxLinesForFileRuleTest);
  });
}

@reflectiveTest
class MaxLinesForFileRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MaxLinesForFileRule();
    super.setUp();
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''
linter:
  rules:
    max_lines_for_file: true

plugins:
  pyramid_lint:
    options:
      max_lines_for_file:
        max_lines: 3
''',
    );
  }

  Future<void> test_within_limit() async {
    await assertNoDiagnostics(
      '''
void main() {}
''',
    );
  }

  Future<void> test_exceeds_limit() async {
    await assertDiagnostics(
      '''
void main() {
  print('one');
  print('two');
}
''',
      [lint(0, 48, correctionContains: '3')],
    );
  }
}
