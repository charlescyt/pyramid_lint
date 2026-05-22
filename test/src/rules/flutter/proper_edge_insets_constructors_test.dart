import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/proper_edge_insets_constructors.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperEdgeInsetsConstructorsRuleTest);
  });
}

@reflectiveTest
class ProperEdgeInsetsConstructorsRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = ProperEdgeInsetsConstructorsRule();
    super.setUp();
  }

  Future<void> test_from_ltrb_all_equal() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.fromLTRB(a, a, a, a);
}
''',
      [lint(87, 31, correctionContains: 'EdgeInsets.all(a)')],
    );
  }

  Future<void> test_from_ltrb_symmetric_pattern() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.fromLTRB(a, 0.0, a, 0.0);
}
''',
      [lint(87, 35, correctionContains: 'EdgeInsets.symmetric(horizontal: a)')],
    );
  }

  Future<void> test_from_ltrb_only_pattern() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.fromLTRB(a, 0.0, 2.0, 4.0);
}
''',
      [lint(87, 37, correctionContains: 'EdgeInsets.only(left: a, right: 2.0, bottom: 4.0)')],
    );
  }

  Future<void> test_only_all_equal() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.only(left: a, top: a, right: a, bottom: a);
}
''',
      [lint(87, 53, correctionContains: 'EdgeInsets.all(a)')],
    );
  }

  Future<void> test_only_symmetric_pattern() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.only(left: a, top: 0.0, right: a, bottom: 0.0);
}
''',
      [lint(87, 57, correctionContains: 'EdgeInsets.symmetric(horizontal: a)')],
    );
  }

  Future<void> test_only_to_from_ltrb() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const padding = EdgeInsets.only(left: 2.0, top: 4.0, right: 6.0, bottom: 8.0);
}
''',
      [lint(70, 61, correctionContains: 'EdgeInsets.fromLTRB(2.0, 4.0, 6.0, 8.0)')],
    );
  }

  Future<void> test_symmetric_equal() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.symmetric(horizontal: a, vertical: a);
}
''',
      [lint(87, 48, correctionContains: 'EdgeInsets.all(a)')],
    );
  }

  Future<void> test_symmetric_with_zero() async {
    await assertDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const a = 8.0;
  const padding = EdgeInsets.symmetric(horizontal: a, vertical: 0.0);
}
''',
      [lint(87, 50, correctionContains: 'EdgeInsets.symmetric(horizontal: a)')],
    );
  }

  Future<void> test_edge_insets_all() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const padding = EdgeInsets.all(8.0);
}
''',
    );
  }

  Future<void> test_from_ltrb_zero() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/painting.dart';

void f() {
  const padding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
}
''',
    );
  }
}
