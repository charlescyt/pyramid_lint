class Point {
  final double x;
  final double y;

  // expect_lint: prefer_declaring_const_constructors
  Point(this.x, this.y);

  // expect_lint: prefer_declaring_const_constructors
  Point.origin()
      : x = 0.0,
        y = 0.0;
}

class A {
  // expect_lint: prefer_declaring_const_constructors
  A();
}
