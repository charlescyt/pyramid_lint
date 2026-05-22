import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_border_from_border_side.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferBorderFromBorderSideRuleTest);
  });
}

@reflectiveTest
class PreferBorderFromBorderSideRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferBorderFromBorderSideRule();
    super.setUp();
  }

  Future<void> test_border_all() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

final border = Border.all(width: 1.0);
''',
      [lint(56, 10)],
    );
  }

  Future<void> test_border_from_border_side() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

final border = Border.fromBorderSide(const BorderSide(width: 1.0));
''',
    );
  }
}
