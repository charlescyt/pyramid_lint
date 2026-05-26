import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/proper_super_dispose.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperSuperDisposeRuleTest);
  });
}

@reflectiveTest
class ProperSuperDisposeRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = ProperSuperDisposeRule();
    super.setUp();
  }

  Future<void> test_super_dispose_not_last() async {
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
  void dispose() {
    super.dispose();
    _f();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _f() {}
}
''',
      [lint(220, 16)],
    );
  }

  Future<void> test_super_dispose_last() async {
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
  void dispose() {
    _f();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _f() {}
}
''',
    );
  }

  Future<void> test_non_state_class() async {
    await assertNoDiagnostics(
      '''
class A {
  void dispose() {
    _f();
  }

  void _f() {}
}
''',
    );
  }
}
