import 'dart:math' as math show cos, sin;

class Point {
  final double x;
  final double y;

  // expect_lint: prefer_const_constructor_declarations
  Point(this.x, this.y);

  // The lint will not be triggered because the redirecting constructor is not const.
  Point.origin() : this(0, 0);

  // expect_lint: prefer_const_constructor_declarations
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

  // The lint will not be triggered because the super constructor is not const.
  Point3D(super.x, super.y, this.z);

  // The lint will not be triggered because the super constructor is not const.
  Point3D.origin()
      : z = 0,
        super.origin();
}

class Coordinate {
  final double x;
  final double y;

  const Coordinate(this.x, this.y);

  const Coordinate.origin() : this(0, 0);
}

class Coordinate3D extends Coordinate {
  final double z;

  // expect_lint: prefer_const_constructor_declarations
  Coordinate3D(super.x, super.y, this.z);

  // expect_lint: prefer_const_constructor_declarations
  Coordinate3D.origin()
      : z = 0,
        super.origin();
}

class A {
  // expect_lint: prefer_const_constructor_declarations
  A();
}
