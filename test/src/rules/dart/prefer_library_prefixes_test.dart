import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/prefer_library_prefixes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferLibraryPrefixesRuleTest);
  });
}

@reflectiveTest
class PreferLibraryPrefixesRuleTest extends AnalysisRuleTest {
  @override
  List<DiagnosticCode> get ignoredDiagnosticCodes => [
    ...super.ignoredDiagnosticCodes,
    diag.unusedImport,
  ];

  @override
  void setUp() {
    rule = PreferLibraryPrefixesRule();
    super.setUp();
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''
linter:
  rules:
    prefer_library_prefixes: true

plugins:
  pyramid_lint:
    options:
      prefer_library_prefixes:
        libraries:
          - dart:math
''',
    );
  }

  Future<void> test_dart_math_without_prefix() async {
    await assertDiagnostics(
      '''
import 'dart:math';
''',
      [lint(0, 19)],
    );
  }

  Future<void> test_dart_math_with_prefix() async {
    await assertNoDiagnostics(
      '''
import 'dart:math' as math;
''',
    );
  }

  Future<void> test_unlisted_library_without_prefix() async {
    await assertNoDiagnostics(
      '''
import 'dart:io';
''',
    );
  }
}
