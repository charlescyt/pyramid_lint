// expect_lint: boolean_prefix
const debugMode = true;

// "at" is a valid prefix since we specified it in the analysis_options.yaml
const atOrigin = true;

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  // expect_lint: boolean_prefix
  bool get origin => x == 0 && y == 0;

  // expect_lint: boolean_prefix
  bool samePoint(covariant Point other) => x == other.x && y == other.y;
}

class Point3D extends Point {
  final double z;

  const Point3D(super.x, super.y, this.z);

  @override
  bool samePoint(Point3D other) => super.samePoint(other) && z == other.z;
}

// expect_lint: boolean_prefix
bool samePoint(Point a, Point b) => a.x == b.x && a.y == b.y;

extension PointExtension on Point {
  // expect_lint: boolean_prefix
  bool get onXAxis => y == 0;
}
