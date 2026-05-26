import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/proper_super_init_state.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperSuperInitStateRuleTest);
  });
}

@reflectiveTest
class ProperSuperInitStateRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = ProperSuperInitStateRule();
    super.setUp();
  }

  Future<void> test_super_init_state_not_first() async {
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
  void initState() {
    _f();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _f() {}
}
''',
      [lint(232, 18)],
    );
  }

  Future<void> test_super_init_state_first() async {
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
  void initState() {
    super.initState();
    _f();
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
  void initState() {
    _f();
  }

  void _f() {}
}
''',
    );
  }
}
