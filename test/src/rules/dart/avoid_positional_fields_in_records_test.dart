import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/avoid_positional_fields_in_records.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidPositionalFieldsInRecordsRuleTest);
  });
}

@reflectiveTest
class AvoidPositionalFieldsInRecordsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidPositionalFieldsInRecordsRule();
    super.setUp();
  }

  Future<void> test_positional_field_getter() async {
    await assertDiagnostics(
      r'''
void fn((String, String) record) {
  record.$1;
  record.$2;
}
''',
      [lint(44, 2), lint(57, 2)],
    );
  }

  Future<void> test_named_field_getter() async {
    await assertNoDiagnostics(
      '''
void fn(({String first, String second}) record) {
  final first = record.first;
  final second = record.second;
}
''',
    );
  }
}
