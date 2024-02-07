import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Text('Pyramid'),
            ),
            Spacer(),
            Text('Lint'),
          ],
        ),
        Row(
          children: [
            Text('Is'),
            Spacer(),
            Text('Great'),
          ],
        ),
      ],
    );
  }
}
