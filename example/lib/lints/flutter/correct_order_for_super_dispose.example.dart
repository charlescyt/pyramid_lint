// ignore_for_file: avoid_empty_block

import 'package:flutter/widgets.dart';

class CorrectOrderForSuperDisposeExample extends StatefulWidget {
  const CorrectOrderForSuperDisposeExample({super.key});

  @override
  State<CorrectOrderForSuperDisposeExample> createState() =>
      _CorrectOrderForSuperDisposeExampleState();
}

class _CorrectOrderForSuperDisposeExampleState
    extends State<CorrectOrderForSuperDisposeExample> {
  @override
  void dispose() {
    // expect_lint: correct_order_for_super_dispose
    super.dispose();
    _dispose();
    _dispose2();
    _dispose3();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void _dispose() {}
  void _dispose2() {}
  void _dispose3() {}
}
