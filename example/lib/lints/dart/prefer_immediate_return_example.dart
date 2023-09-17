int sum(int a, int b) {
  final sum = a + b;
  // expect_lint: prefer_immediate_return
  return sum;
}
