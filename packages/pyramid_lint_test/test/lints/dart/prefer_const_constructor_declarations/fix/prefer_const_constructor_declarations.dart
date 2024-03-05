class Point {
  final double x;
  final double y;

  // expect_lint: prefer_const_constructor_declarations
  Point(this.x, this.y);

  // expect_lint: prefer_const_constructor_declarations
  Point.origin()
      : x = 0.0,
        y = 0.0;
}

class A {
  // expect_lint: prefer_const_constructor_declarations
  A();
}
