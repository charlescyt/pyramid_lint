import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/dispose_controllers.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DisposeControllersRuleTest);
  });
}

@reflectiveTest
class DisposeControllersRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = DisposeControllersRule();
    super.setUp();

    newFile(
      join(packagesRootPath, 'flutter', 'lib', 'src', 'foundation', 'change_notifier.dart'),
      '''
abstract class Listenable {}

abstract class ValueListenable<T> extends Listenable {}

class ChangeNotifier implements Listenable {
  void dispose() {}
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}
''',
    );
    newFile(
      join(packagesRootPath, 'flutter', 'lib', 'src', 'animation', 'animation_controller.dart'),
      '''
class AnimationController extends Animation<double>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  AnimationController();
  void dispose() {}
}
''',
    );
  }

  Future<void> test_undisposed_change_notifier() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class _Controller extends ChangeNotifier {}

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  final _controller = _Controller();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      [lint(238, 11)],
    );
  }

  Future<void> test_disposed_change_notifier() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class _Controller extends ChangeNotifier {}

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  late final _Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = _Controller();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    );
  }

  Future<void> test_undisposed_animation_controller() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      [lint(218, 11)],
    );
  }

  Future<void> test_disposed_animation_controller() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
    );
  }

  Future<void> test_cascade_dispose() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

class _Controller extends ChangeNotifier {}

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  late final _Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = _Controller();
    _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _handleChange() {}
}
''',
    );
  }
}
