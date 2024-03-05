import 'package:flutter/widgets.dart';

typedef ItemBuilder = Widget? Function(
  // expect_lint: always_specify_parameter_names
  BuildContext,
  // expect_lint: always_specify_parameter_names
  int,
);
