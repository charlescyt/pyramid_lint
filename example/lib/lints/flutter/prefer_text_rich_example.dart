import 'package:flutter/widgets.dart';

class PreferTextRichExample extends StatelessWidget {
  const PreferTextRichExample({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: prefer_text_rich
    return RichText(
      text: const TextSpan(
        text: 'Pyramid',
        children: [
          TextSpan(text: 'Lint'),
        ],
      ),
    );
  }
}
