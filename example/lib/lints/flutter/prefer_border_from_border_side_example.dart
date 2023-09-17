import 'package:flutter/widgets.dart';

class PreferBorderFromBorderSideExample extends StatelessWidget {
  const PreferBorderFromBorderSideExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // expect_lint: prefer_border_from_border_side
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}
