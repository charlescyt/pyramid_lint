// ignore_for_file: unused_local_variable

void example() {
  const numbers = [1, 2, 3];
  int lastNumber;

  // expect_lint: prefer_iterable_last
  lastNumber = numbers[numbers.length - 1];

  // expect_lint: prefer_iterable_last
  lastNumber = numbers.elementAt(numbers.length - 1);
}
