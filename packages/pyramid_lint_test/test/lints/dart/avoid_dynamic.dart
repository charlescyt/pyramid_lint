// ignore_for_file: avoid_print

// expect_lint: avoid_dynamic
dynamic thing = 'text';

// expect_lint: avoid_dynamic
void log(dynamic something) => print(something);

// expect_lint: avoid_dynamic
typedef MyFunction = void Function(dynamic a, dynamic b);

Map<String, dynamic> map = {};
// expect_lint: avoid_dynamic
List<dynamic> list = [1, 2, 3];
// expect_lint: avoid_dynamic
Set<dynamic> set = {'a', 'b', 'c'};

final mapLiteral = <String, dynamic>{};
// expect_lint: avoid_dynamic
final listLiteral = <dynamic>[1, 2, 3];
// expect_lint: avoid_dynamic
final setLiteral = <dynamic>{'a', 'b', 'c'};
