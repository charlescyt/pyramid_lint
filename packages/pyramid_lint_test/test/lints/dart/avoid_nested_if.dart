// ignore_for_file: literal_only_boolean_expressions, avoid_empty_blocks

void fn() {
  // expect_lint: avoid_nested_if
  if (true) {
    if (true) {
      if (true) {}
    }
  }
}

void fn2(int a) {
  if (a == 1) {
  } else if (a == 2) {
    // expect_lint: avoid_nested_if
  } else if (a == 3) {
    if (true) {
      if (true) {}
    }
  } else if (a == 4) {}
}
