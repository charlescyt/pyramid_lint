// ignore_for_file: unnecessary_parenthesis

void example(int number) {
  // expect_lint: no_self_comparisons
  if (number == number) {
    return;
  }

  // expect_lint: no_self_comparisons
  if (number > (number)) {
    return;
  }

  // expect_lint: no_self_comparisons
  if ((number.sign) == number.sign) {
    return;
  }
}
