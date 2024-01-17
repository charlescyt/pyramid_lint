// ignore_for_file: literal_only_boolean_expressions, avoid_empty_blocks, dead_code

void example() {
  // expect_lint: avoid_nested_if
  if (true) {
    if (true) {
      if (true) {
      } else {}
    } else {}
  } else {}
}
