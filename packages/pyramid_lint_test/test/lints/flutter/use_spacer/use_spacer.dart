import 'package:flutter/widgets.dart';

final column = Column(
  children: [
    // expect_lint: use_spacer
    const Expanded(
      child: SizedBox(),
    ),
    // expect_lint: use_spacer
    Expanded(
      flex: 2,
      child: Container(),
    ),
    // Using Expanded with a non-empty Container or SizedBox is fine.
    const Expanded(
      child: SizedBox(
        child: Placeholder(),
      ),
    ),
  ],
);
