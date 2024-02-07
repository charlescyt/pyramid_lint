import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Pyramid'),
        Spacer(),
        Text('Lint'),
      ],
    );
  }
}
