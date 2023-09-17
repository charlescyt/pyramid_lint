import 'package:flutter/widgets.dart';

class AvoidSingleChildInFlexExample extends StatelessWidget {
  const AvoidSingleChildInFlexExample({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_single_child_in_flex
    return const Column(
      children: [
        Placeholder(),
      ],
    );
  }
}

// No Lint for spread elements
final a = Column(
  children: [
    ...[1, 2, 3].map((e) => Text('$e')),
  ],
);

// No Lint for collection for elements
final b = Column(
  children: [
    for (final e in [1, 2, 3]) Text('$e'),
  ],
);
