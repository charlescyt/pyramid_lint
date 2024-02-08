import 'package:flutter/widgets.dart';

final column = Column(
  children: [
    // expect_lint: prefer_spacer
    const Expanded(
      child: SizedBox(),
    ),
    // expect_lint: prefer_spacer
    Expanded(
      flex: 2,
      child: Container(),
    ),
  ],
);
