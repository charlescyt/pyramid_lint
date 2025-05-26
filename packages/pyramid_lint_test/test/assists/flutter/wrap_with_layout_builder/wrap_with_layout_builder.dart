import 'package:flutter/widgets.dart';

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, _) {
        return const Center(
          child: Placeholder(),
        );
      },
    );
  }
}
