// ignore_for_file: unused_field

import 'package:flutter/widgets.dart';

class _Example extends StatefulWidget {
  const _Example();

  @override
  State<_Example> createState() => _ExampleState();
}

// expect_lint: proper_controller_dispose
class _ExampleState extends State<_Example> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _Example2 extends StatefulWidget {
  const _Example2({required this.duration});

  final Duration duration;

  @override
  State<_Example2> createState() => _Example2State();
}

class _Example2State extends State<_Example2>
    with SingleTickerProviderStateMixin {
  // expect_lint: proper_controller_dispose
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(_Example2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
