import 'package:flutter/widgets.dart';

typedef ItemBuilder = Widget? Function(
  // expect_lint: prefer_declaring_parameter_name
  BuildContext,
  // expect_lint: prefer_declaring_parameter_name
  int,
);
