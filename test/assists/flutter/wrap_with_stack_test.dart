import 'package:flutter/widgets.dart';

class WrapWithStackExample extends StatelessWidget {
  const WrapWithStackExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Pyramid',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('Lint'),
      ],
    );
  }
}
