import 'package:flutter/widgets.dart';

class WrapAllChildrenWithExpandedExample extends StatelessWidget {
  const WrapAllChildrenWithExpandedExample({super.key});

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
