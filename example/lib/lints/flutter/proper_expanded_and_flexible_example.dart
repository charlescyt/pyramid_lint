import 'package:flutter/widgets.dart';

class ProperUsageOfExpandedOrFlexibleExample extends StatelessWidget {
  const ProperUsageOfExpandedOrFlexibleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
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
  }
}
