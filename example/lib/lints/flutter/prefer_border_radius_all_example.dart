import 'package:flutter/widgets.dart';

class PreferBoarderRadiusAllExample extends StatelessWidget {
  const PreferBoarderRadiusAllExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // expect_lint: prefer_border_radius_all
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
