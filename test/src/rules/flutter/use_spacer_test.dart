// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/use_spacer.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseSpacerRuleTest);
  });
}

@reflectiveTest
class UseSpacerRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = UseSpacerRule();
    super.setUp();
  }

  Future<void> test_expanded_empty_sized_box_and_container() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Column(
    children: [
      const Expanded(
        child: SizedBox(),
      ),
      Expanded(
        flex: 2,
        child: Container(),
      ),
    ],
  );
}
''',
      [
        lint(83, 50, messageContainsAll: ['SizedBox']),
        lint(141, 62, messageContainsAll: ['Container']),
      ],
    );
  }

  Future<void> test_expanded_non_empty_sized_box_no_lint() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Column(
    children: [
      const Expanded(
        child: SizedBox(
          child: Placeholder(),
        ),
      ),
    ],
  );
}
''',
    );
  }
}
