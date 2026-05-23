import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/avoid_empty_blocks.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidEmptyBlocksRuleTest);
  });
}

@reflectiveTest
class AvoidEmptyBlocksRuleTest extends AnalysisRuleTest {
  @override
  List<DiagnosticCode> get ignoredDiagnosticCodes => [
    ...super.ignoredDiagnosticCodes,
    diag.todo,
  ];

  @override
  void setUp() {
    rule = AvoidEmptyBlocksRule();
    super.setUp();
  }

  Future<void> test_empty_function() async {
    await assertDiagnostics(
      '''
void emptyFunction() {}
''',
      [lint(21, 2)],
    );
  }

  Future<void> test_empty_if_block() async {
    await assertDiagnostics(
      '''
void emptyIfBlock(bool condition) {
  if (condition) {}
}
''',
      [lint(53, 2)],
    );
  }

  Future<void> test_empty_block_with_todo() async {
    await assertNoDiagnostics(
      '''
void emptyBlockWithTodo() {
  // TODO: Implement this function.
}
''',
    );
  }

  Future<void> test_non_empty_block() async {
    await assertNoDiagnostics(
      '''
void nonEmpty() {
  print('implemented');
}
''',
    );
  }
}
