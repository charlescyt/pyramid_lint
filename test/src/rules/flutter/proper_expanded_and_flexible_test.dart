// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/proper_expanded_and_flexible.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperExpandedAndFlexibleRuleTest);
  });
}

@reflectiveTest
class ProperExpandedAndFlexibleRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = ProperExpandedAndFlexibleRule();
    super.setUp();
  }

  Future<void> test_expanded_and_flexible_in_stack() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Stack(
    children: [
      Expanded(
        child: Text('a'),
      ),
      Flexible(
        child: Text('b'),
      ),
    ],
  );
}
''',
      [
        lint(82, 8, messageContainsAll: ['Expanded']),
        lint(133, 8, messageContainsAll: ['Flexible']),
      ],
    );
  }

  Future<void> test_expanded_in_column() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Column(
    children: [
      Expanded(
        child: Text('a'),
      ),
    ],
  );
}
''',
    );
  }

  Future<void> test_flexible_in_row() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Row(
    children: [
      Flexible(
        child: Text('a'),
      ),
    ],
  );
}
''',
    );
  }

  Future<void> test_expanded_in_flex() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f() {
  Flex(
    direction: Axis.horizontal,
    children: [
      Expanded(
        child: Text('a'),
      ),
    ],
  );
}
''',
    );
  }
}
