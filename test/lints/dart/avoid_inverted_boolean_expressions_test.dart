// ignore_for_file: avoid_empty_blocks, unused_local_variable

void example(int number) {
  // expect_lint: avoid_inverted_boolean_expressions
  if (!(number == 0)) {}

  // expect_lint: avoid_inverted_boolean_expressions
  if (!(number > 0)) {}

  // expect_lint: avoid_inverted_boolean_expressions
  final anotherNumber = !(number == 0) ? 1 : 2;
}
