import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/always_put_doc_comments_before_annotations.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AlwaysPutDocCommentsBeforeAnnotationsRuleTest);
  });
}

@reflectiveTest
class AlwaysPutDocCommentsBeforeAnnotationsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AlwaysPutDocCommentsBeforeAnnotationsRule();
    super.setUp();
  }

  Future<void> test_doc_comment_after_annotation() async {
    await assertDiagnostics(
      '''
@Deprecated('Use B instead')
/// Some documentation.
class A {}
''',
      [lint(29, 23)],
    );
  }

  Future<void> test_doc_comment_between_annotations() async {
    await assertDiagnostics(
      '''
@Deprecated('Use A instead')
/// Some documentation.
///
/// More documentation.
@pragma('vm:prefer-inline')
class B {}
''',
      [lint(29, 51)],
    );
  }

  Future<void> test_doc_comment_before_annotations() async {
    await assertNoDiagnostics(
      '''
/// Some documentation.
///
/// More documentation.
@Deprecated('Use A instead')
class C {}
''',
    );
  }
}
