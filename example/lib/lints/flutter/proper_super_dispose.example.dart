// ignore_for_file: avoid_empty_block

import 'package:flutter/widgets.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  void dispose() {
    // expect_lint: proper_super_dispose
    super.dispose();
    _dispose();
    _dispose2();
    _dispose3();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _dispose() {}
  void _dispose2() {}
  void _dispose3() {}
}
