// ignore_for_file: avoid_empty_blocks

import 'package:flutter/material.dart';

// expect_lint: specify_icon_button_tooltip
final Widget a = IconButton(icon: const Icon(Icons.add), onPressed: () {});

// expect_lint: specify_icon_button_tooltip
final Widget b = IconButton.filled(
  icon: const Icon(Icons.add),
  onPressed: () {},
);

final Widget c = IconButton(
  tooltip: '',
  icon: const Icon(Icons.add),
  onPressed: () {},
);
