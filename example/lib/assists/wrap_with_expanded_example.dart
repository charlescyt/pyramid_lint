import 'package:flutter/widgets.dart';

class WrapWithExpandedExample extends StatelessWidget {
  const WrapWithExpandedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Pyramid'),
        Text('Lint'),
      ],
    );
  }
}
