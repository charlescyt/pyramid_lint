import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_border_radius_all.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferBorderRadiusAllRuleTest);
  });
}

@reflectiveTest
class PreferBorderRadiusAllRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferBorderRadiusAllRule();
    super.setUp();
  }

  Future<void> test_border_radius_circular() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

final borderRadius = BorderRadius.circular(8.0);
''',
      [lint(62, 21)],
    );
  }

  Future<void> test_border_radius_all() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

final borderRadius = BorderRadius.all(Radius.circular(8.0));
''',
    );
  }

  Future<void> test_border_radius_vertical() async {
    await assertNoDiagnostics('''
import 'package:flutter/painting.dart';

final borderRadius = BorderRadius.vertical(top: Radius.circular(8.0));
''');
  }

  Future<void> test_border_radius_horizontal() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

final borderRadius = BorderRadius.horizontal(left: Radius.circular(8.0));
''',
    );
  }

  Future<void> test_border_radius_only() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

final borderRadius = BorderRadius.only(topLeft: Radius.circular(8.0));
''',
    );
  }
}
