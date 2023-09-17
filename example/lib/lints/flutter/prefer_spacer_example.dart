import 'package:flutter/widgets.dart';

class PreferSpacerExample extends StatelessWidget {
  const PreferSpacerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // expect_lint: prefer_spacer
        const Expanded(
          child: SizedBox(),
        ),
        // expect_lint: prefer_spacer
        Expanded(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }
}
