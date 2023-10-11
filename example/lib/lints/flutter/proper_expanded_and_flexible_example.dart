import 'package:flutter/widgets.dart';

const stack = Stack(
  children: [
    // expect_lint: proper_expanded_and_flexible
    Expanded(
      child: Text('Pyramid'),
    ),
    // expect_lint: proper_expanded_and_flexible
    Flexible(
      child: Text('Lint'),
    ),
  ],
);
