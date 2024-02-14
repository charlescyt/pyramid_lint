// ignore_for_file: unnecessary_lambdas, max_lines_for_function

void fn(Iterable<int> numbers) {
  // expect_lint: prefer_iterable_every
  numbers.where((n) => n.isEven).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) => n == 0).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) => n > 0).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) => n % 3 == 0).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) => isMultipleOfThree(n)).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where(isMultipleOfThree).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return n.isEven;
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return n == 0;
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return n > 0;
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return n % 3 == 0;
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return isMultipleOfThree(n);
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return !isMultipleOfThree(n);
  }).isEmpty;

  // expect_lint: prefer_iterable_every
  numbers.where((n) {
    return n % 3 == 0 && n % 7 == 0;
  }).isEmpty;
}

bool isMultipleOfThree(int number) => number % 3 == 0;
