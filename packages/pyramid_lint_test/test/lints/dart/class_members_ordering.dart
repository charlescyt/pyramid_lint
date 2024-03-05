// ignore_for_file: unused_field, unused_element, avoid_empty_blocks, avoid_widget_state_public_members, boolean_prefixes

import 'package:flutter/widgets.dart';

class A {
  // expect_lint: class_members_ordering
  int get c => _c + 1;

  // expect_lint: class_members_ordering
  A(
    this.publicInstanceField,
    this._privateInstanceField,
  );

  // expect_lint: class_members_ordering
  set c(int value) => _c = value;

  // expect_lint: class_members_ordering
  A.named()
      : publicInstanceField = 0,
        _privateInstanceField = 0;

  factory A.factory(int a) {
    return A(a, a + 1);
  }

  // expect_lint: class_members_ordering
  A._()
      : publicInstanceField = 0,
        _privateInstanceField = 0;

  // expect_lint: class_members_ordering
  final int publicInstanceField;

  // expect_lint: class_members_ordering
  final int _privateInstanceField;

  // expect_lint: class_members_ordering
  static const int e = 1;

  // expect_lint: class_members_ordering
  void _privateMethod() {}

  // expect_lint: class_members_ordering
  static void publicStaticMethod() {}

  // expect_lint: class_members_ordering
  void publicMethod() {}

  // expect_lint: class_members_ordering
  int _c = 1;
}

class B {
  static const int e = 1;

  final int publicInstanceField;

  final int _privateInstanceField;

  int _c = 1;

  B(
    this.publicInstanceField,
    this._privateInstanceField,
  );

  B.named()
      : publicInstanceField = 0,
        _privateInstanceField = 0;

  factory B.factory(int a) {
    return B(a, a + 1);
  }

  B._()
      : publicInstanceField = 0,
        _privateInstanceField = 0;

  int get c => _c + 1;
  set c(int value) => _c = value;

  static void publicStaticMethod() {}
  void publicMethod() {}
  void _privateMethod() {}
}

class Stateless extends StatelessWidget {
  static const int e = 1;

  // expect_lint: class_members_ordering
  final int publicInstanceField;

  // expect_lint: class_members_ordering
  const Stateless({
    super.key,
    required this.publicInstanceField,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Stateful extends StatefulWidget {
  // expect_lint: class_members_ordering
  @override
  State<Stateful> createState() => _StatefulState();

  // expect_lint: class_members_ordering
  const Stateful({super.key});
}

class _StatefulState extends State<Stateful> {
  // expect_lint: class_members_ordering
  void _privateMethod() => setState(() => _flag = !_flag);

  // expect_lint: class_members_ordering
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // expect_lint: class_members_ordering
  void publicMethod() {}

  // expect_lint: class_members_ordering
  bool _flag = false;
}
