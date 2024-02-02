import 'package:flutter/widgets.dart';

// expect_lint: avoid_single_child_in_flex
const singleChild = Column(
  children: [
    Placeholder(),
  ],
);

// Spread elements will not trigger the lint.
final spread = Row(
  children: [
    ...[1, 2, 3].map((e) => Text('$e')),
  ],
);

// Collection for will not trigger the lint.
final collectionFor = Flex(
  direction: Axis.vertical,
  children: [
    for (final e in [1, 2, 3]) Text('$e'),
  ],
);
