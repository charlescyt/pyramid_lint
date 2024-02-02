// ignore_for_file: avoid_empty_blocks, avoid_unused_parameters

import 'package:flutter/widgets.dart';

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (
        // expect_lint: prefer_underscore_for_unused_callback_parameters
        context,
        // Used parameter will not trigger the lint.
        index,
      ) {
        return Text('Item $index');
      },
    );
  }
}

// Function declarations will not trigger the lint.
void log(String message) {}
