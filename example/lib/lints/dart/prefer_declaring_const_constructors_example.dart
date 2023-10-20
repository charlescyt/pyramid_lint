// ignore_for_file: prefer_library_prefixes

import 'dart:math' show cos, sin;

class Point {
  final double x;
  final double y;

  // expect_lint: prefer_declaring_const_constructors
  Point(this.x, this.y);

  // expect_lint: prefer_declaring_const_constructors
  Point.origin()
      : x = 0.0,
        y = 0.0;

  Point.fromPolarCoordinates({
    required double radius,
    required double angle,
  })  : x = radius * cos(angle),
        y = radius * sin(angle);
}
