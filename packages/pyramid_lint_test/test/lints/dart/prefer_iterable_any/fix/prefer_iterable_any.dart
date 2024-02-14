// ignore_for_file: unnecessary_lambdas

void fn(Iterable<int> numbers) {
  // expect_lint: prefer_iterable_any
  numbers.where((n) => n.isEven).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) => n == 0).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) => n > 0).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) => n % 3 == 0).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) => isMultipleOfThree(n)).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where(isMultipleOfThree).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((item) {
    return item.isEven;
  }).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) {
    return n == 0;
  }).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) {
    return n > 0;
  }).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) {
    return n % 3 == 0;
  }).isNotEmpty;

  // expect_lint: prefer_iterable_any
  numbers.where((n) {
    return isMultipleOfThree(n);
  }).isNotEmpty;
}

bool isMultipleOfThree(int number) => number % 3 == 0;
