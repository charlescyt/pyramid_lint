import 'package:flutter/widgets.dart';

// expect_lint: prefer_text_rich
final text = RichText(
  text: const TextSpan(
    text: 'Pyramid',
    children: [
      TextSpan(text: 'Lint'),
    ],
  ),
);
