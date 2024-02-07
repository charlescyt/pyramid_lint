import 'dart:math' as math show cos, sin;

class Point {
  final double x;
  final double y;

  // expect_lint: prefer_declaring_const_constructors
  Point(this.x, this.y);

  // The lint will not be triggered because the super constructor is not const.
  Point.origin() : this(0, 0);

  // expect_lint: prefer_declaring_const_constructors
  Point.origin2()
      : x = 0.0,
        y = 0.0;

  Point.fromPolarCoordinates({
    required double radius,
    required double angle,
  })  : x = radius * math.cos(angle),
        y = radius * math.sin(angle);
}

class Point3D extends Point {
  final double z;

  Point3D(super.x, super.y, this.z);

  // The lint will not be triggered because the super constructor is not const.
  Point3D.origin()
      : z = 0,
        super.origin();
}

class A {
  // expect_lint: prefer_declaring_const_constructors
  A();
}
