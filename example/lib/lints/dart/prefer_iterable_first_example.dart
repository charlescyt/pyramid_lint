// ignore_for_file: unused_local_variable

void example() {
  const numbers = [1, 2, 3];
  int firstNumber;

  // expect_lint: prefer_iterable_first
  firstNumber = numbers[0];

  // expect_lint: prefer_iterable_first
  firstNumber = numbers.elementAt(0);
}
