// expect_lint: unnecessary_nullable_return_type
int? sum(int a, int b) {
  return a + b;
}

class A {
  // expect_lint: unnecessary_nullable_return_type
  int? sum(int a, int b) => a + b;

  String? method(bool isNull) {
    if (isNull) {
      return null;
    } else {
      return 'not null';
    }
  }
}
