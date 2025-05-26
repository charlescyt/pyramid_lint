// ignore_for_file: avoid_empty_blocks, avoid_print

void function1(String s) {
  print(s);
}

// expect_lint: avoid_unused_parameters
void function2(String s) {}

class A {
  void method1(String s) => print(s);

  // expect_lint: avoid_unused_parameters
  void method2(String s) {}
}

class B extends A {
  @override
  void method1(String s) {} // overridden method will not trigger the lint
}

abstract class C {
  void method(String s); // abstract class will not trigger the lint
}
