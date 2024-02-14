// ignore_for_file: unnecessary_lambdas

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
}

bool isMultipleOfThree(int number) => number % 3 == 0;
