// ignore_for_file: unused_element, unused_field, avoid_multiple_declarations_per_line, avoid_empty_blocks, prefer_final_fields

import 'package:flutter/material.dart';

class Bar extends StatefulWidget {
  const Bar({super.key});

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  // expect_lint: avoid_public_members_in_states
  int publicField = 1;

  int _privateField = 0;

  // expect_lint: avoid_public_members_in_states
  String _privateField2 = '', publicField2 = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  // expect_lint: avoid_public_members_in_states
  void publicMethod() {}

  void _privateMethod() {}
}
