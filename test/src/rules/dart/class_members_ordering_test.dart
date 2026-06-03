import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/dart/class_members_ordering.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassMembersOrderingRuleTest);
  });
}

@reflectiveTest
class ClassMembersOrderingRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = ClassMembersOrderingRule();
    super.setUp();
  }

  Future<void> test_incorrect_class_member_order() async {
    await assertDiagnostics(
      '''
class A {
  void method() {}

  final int field;

  A({required this.field});
}
''',
      [
        lint(12, 16, messageContainsAll: ['public methods']),
        lint(32, 16, messageContainsAll: ['public fields']),
      ],
    );
  }

  Future<void> test_correct_class_member_order() async {
    await assertNoDiagnostics(
      '''
class A {
  final int field;

  A({required this.field});

  void method() {}
}
''',
    );
  }

  Future<void> test_incorrect_widget_member_order() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  final String field;

  const A({
    super.key,
    required this.field,
  });
}
''',
      [
        lint(76, 84, messageContainsAll: ['public methods']),
        lint(164, 19, messageContainsAll: ['public fields']),
        lint(187, 55, messageContainsAll: ['public constructors']),
      ],
    );
  }

  Future<void> test_correct_widget_member_order() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class AWidget extends StatelessWidget {
  const AWidget({
    super.key,
    required this.field,
  });

  final String field;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    );
  }
}
