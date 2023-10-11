// ignore_for_file: avoid_empty_block

import 'package:flutter/widgets.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  void initState() {
    _init();
    _init2();
    _init3();
    // expect_lint: proper_super_init_state
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _init() {}
  void _init2() {}
  void _init3() {}
}
