// ignore_for_file: avoid_empty_block, unused_local_variable

void example(int number) {
  // expect_lint: avoid_inverted_boolean_expression
  if (!(number == 0)) {}

  // expect_lint: avoid_inverted_boolean_expression
  if (!(number > 0)) {}

  // expect_lint: avoid_inverted_boolean_expression
  final anotherNumber = !(number == 0) ? 1 : 2;
}
