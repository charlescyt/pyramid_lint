import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/avoid_unused_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnusedParametersRuleTest);
  });
}

@reflectiveTest
class AvoidUnusedParametersRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnusedParametersRule();
    super.setUp();
  }

  Future<void> test_unused_function_parameter() async {
    await assertDiagnostics(
      '''
void f(String s) {}
''',
      [lint(7, 8)],
    );
  }

  Future<void> test_used_function_parameter() async {
    await assertNoDiagnostics(
      '''
void f(String s) {
  print(s);
}
''',
    );
  }

  Future<void> test_unused_method_parameter() async {
    await assertDiagnostics(
      '''
class A {
  void m(String s) {}
}
''',
      [lint(19, 8)],
    );
  }

  Future<void> test_used_method_parameter() async {
    await assertNoDiagnostics(
      '''
class A {
  void m(String s) {
    print(s);
  }
}
''',
    );
  }

  Future<void> test_override_method() async {
    await assertNoDiagnostics(
      '''
class A {
  void m(String s) {
    print(s);
  }
}

class B extends A {
  @override
  void m(String s) {}
}
''',
    );
  }

  Future<void> test_abstract_class_method() async {
    await assertNoDiagnostics(
      '''
abstract class C {
  void m(String s);
}
''',
    );
  }

  Future<void> test_ignored_parameter() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''
linter:
  rules:
    avoid_unused_parameters: true

plugins:
  pyramid_lint:
    options:
      avoid_unused_parameters:
        ignored_parameters:
          - ref
''',
    );

    await assertNoDiagnostics(
      '''
void f(Object ref) {}
''',
    );
  }
}
