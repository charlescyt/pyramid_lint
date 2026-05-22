// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/proper_from_environment.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperFromEnvironmentRuleTest);
  });
}

@reflectiveTest
class ProperFromEnvironmentRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProperFromEnvironmentRule();
    super.setUp();
  }

  Future<void> test_bool_from_environment() async {
    await assertDiagnostics(
      '''
final boolean = bool.fromEnvironment('bool');
''',
      [
        lint(16, 28, messageContainsAll: ['bool']),
      ],
    );
  }

  Future<void> test_int_from_environment() async {
    await assertDiagnostics(
      '''
final integer = int.fromEnvironment('int');
''',
      [
        lint(16, 26, messageContainsAll: ['int']),
      ],
    );
  }

  Future<void> test_string_from_environment() async {
    await assertDiagnostics(
      '''
final string = String.fromEnvironment('String');
''',
      [
        lint(15, 32, messageContainsAll: ['String']),
      ],
    );
  }

  Future<void> test_new_from_environment() async {
    await assertDiagnostics(
      '''
final boolean = new bool.fromEnvironment('bool');
''',
      [
        lint(16, 32, messageContainsAll: ['bool']),
      ],
    );
  }

  Future<void> test_const_from_environment() async {
    await assertNoDiagnostics(
      '''
const boolean = bool.fromEnvironment('bool');
const integer = int.fromEnvironment('int');
const string = String.fromEnvironment('String');
''',
    );
  }
}
