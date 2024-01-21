import 'package:flutter/widgets.dart';

class ExpandAllChildrenExample extends StatelessWidget {
  const ExpandAllChildrenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Text('Pyramid'),
            ),
            Text('Lint'),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Text('Is'),
            ),
            Text('Great'),
          ],
        ),
      ],
    );
  }
}
