import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/avoid_dynamic.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDynamicRuleTest);
  });
}

@reflectiveTest
class AvoidDynamicRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidDynamicRule();
    super.setUp();
  }

  Future<void> test_dynamic_type() async {
    await assertDiagnostics(
      '''
dynamic thing = 'text';
''',
      [lint(0, 7)],
    );
  }

  Future<void> test_dynamic_type_in_map() async {
    await assertNoDiagnostics(
      '''
Map<String, dynamic> map = {};
''',
    );
  }

  Future<void> test_dynamic_type_in_list() async {
    await assertDiagnostics(
      '''
List<dynamic> list = [1, 2, 3];
''',
      [lint(5, 7)],
    );
  }

  Future<void> test_dynamic_type_in_set() async {
    await assertDiagnostics(
      '''
Set<dynamic> set = {'a', 'b', 'c'};
''',
      [lint(4, 7)],
    );
  }

  Future<void> test_dynamic_type_in_map_literal() async {
    await assertNoDiagnostics(
      '''
final mapLiteral = <String, dynamic>{};
''',
    );
  }

  Future<void> test_dynamic_type_in_list_literal() async {
    await assertDiagnostics(
      '''
final listLiteral = <dynamic>[1, 2, 3];
''',
      [lint(21, 7)],
    );
  }

  Future<void> test_dynamic_type_in_set_literal() async {
    await assertDiagnostics(
      '''
final setLiteral = <dynamic>{'a', 'b', 'c'};
''',
      [lint(20, 7)],
    );
  }
}
