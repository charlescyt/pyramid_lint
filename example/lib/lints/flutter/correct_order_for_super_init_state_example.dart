// ignore_for_file: avoid_empty_block

import 'package:flutter/widgets.dart';

class CorrectOrderForSuperInitStateExample extends StatefulWidget {
  const CorrectOrderForSuperInitStateExample({super.key});

  @override
  State<CorrectOrderForSuperInitStateExample> createState() =>
      _CorrectOrderForSuperInitStateExampleState();
}

class _CorrectOrderForSuperInitStateExampleState
    extends State<CorrectOrderForSuperInitStateExample> {
  @override
  void initState() {
    _init();
    _init2();
    _init3();
    // expect_lint: correct_order_for_super_init_state
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void _init() {}
  void _init2() {}
  void _init3() {}
}
