// ignore_for_file: unused_field, avoid_multiple_declarations_per_line

import 'package:flutter/widgets.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

// expect_lint: proper_controller_dispose
class _ExampleState extends State<Example> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Example2 extends StatefulWidget {
  const Example2({
    super.key,
    required this.duration,
  });

  final Duration duration;

  @override
  State<Example2> createState() => _Example2State();
}

class _Example2State extends State<Example2>
    with SingleTickerProviderStateMixin {
  // The lint is triggered here because _controller2 is not disposed.
  // expect_lint: proper_controller_dispose
  late AnimationController _controller1, _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(Example2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller1.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
