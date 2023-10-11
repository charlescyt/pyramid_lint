import 'package:flutter/widgets.dart';

// expect_lint: avoid_single_child_in_flex
const singleChild = Column(
  children: [
    Placeholder(),
  ],
);

// No Lint for spread elements
final spread = Row(
  children: [
    ...[1, 2, 3].map((e) => Text('$e')),
  ],
);

// No Lint for collection for elements
final collectionFor = Flex(
  direction: Axis.vertical,
  children: [
    for (final e in [1, 2, 3]) Text('$e'),
  ],
);
