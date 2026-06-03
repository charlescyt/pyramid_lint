import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/avoid_public_members_in_states.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidPublicMembersInStatesRuleTest);
  });
}

@reflectiveTest
class AvoidPublicMembersInStatesRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  bool get addMetaPackageDep => true;

  @override
  void setUp() {
    rule = AvoidPublicMembersInStatesRule();
    super.setUp();
  }

  Future<void> test_public_field() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  int a = 0;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      [lint(191, 1)],
    );
  }

  Future<void> test_public_method() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void f() {}
}
''',
      [lint(280, 1)],
    );
  }

  Future<void> test_private_field() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  int _a = 0;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    );
  }

  Future<void> test_private_method() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _a() {}
}
''',
    );
  }

  Future<void> test_public_and_private_field_on_same_line() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  int _a = 0, b = 1;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      [lint(199, 1)],
    );
  }

  Future<void> test_field_with_visible_for_testing_annotation() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  @visibleForTesting
  int a = 1;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    );
  }

  Future<void> test_method_with_visible_for_testing_annotation() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @visibleForTesting
  void f() {}
}
''',
    );
  }

  Future<void> test_non_state_class() async {
    await assertNoDiagnostics(
      '''
class A {
  int a = 1;

  void f() {}
}
''',
    );
  }
}
