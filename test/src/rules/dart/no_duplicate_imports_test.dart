import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/no_duplicate_imports.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoDuplicateImportsRuleTest);
  });
}

@reflectiveTest
class NoDuplicateImportsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoDuplicateImportsRule();
    super.setUp();
  }

  Future<void> test_duplicate_imports() async {
    await assertDiagnostics(
      '''
import 'dart:math' as math show max;
import 'dart:math';

final a = math.max(1, 10);
final b = min(1, 10);
''',
      [lint(7, 11), lint(44, 11)],
    );
  }
}
