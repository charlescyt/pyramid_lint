// ignore_for_file: unused_local_variable

import 'package:flutter/widgets.dart';

void example() {
  late EdgeInsets padding;

  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.fromLTRB(8, 8, 8, 8);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.fromLTRB(8, 0, 8, 0);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.fromLTRB(8, 4, 8, 4);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.fromLTRB(8, 4, 8, 0);

  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 0);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.only(left: 2, top: 4, right: 6, bottom: 8);

  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  // expect_lint: proper_edge_insets_constructor
  padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 0);
}
