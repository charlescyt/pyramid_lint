// ignore_for_file: unused_local_variable

import 'package:flutter/widgets.dart';

void example() {
  const a = 8.0;
  late EdgeInsets padding;

  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.fromLTRB(a, a, a, a);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.fromLTRB(a, 0, a, 0);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.fromLTRB(a, 4, a, 4);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.fromLTRB(a, 0, 2, 4);

  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.only(left: a, top: a, right: a, bottom: a);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.only(left: a, top: 0, right: a, bottom: 0);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.only(left: a, top: 4, right: a, bottom: 4);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.only(left: 2, top: 4, right: 6, bottom: a);

  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.symmetric(horizontal: a, vertical: a);
  // expect_lint: proper_edge_insets_constructors
  padding = const EdgeInsets.symmetric(horizontal: a, vertical: 0);
}
