// ignore_for_file: unused_field, avoid_multiple_declarations_per_line

import 'package:flutter/material.dart';

class _CustomController extends ChangeNotifier {}

class _CustomCounterController extends ValueNotifier<int> {
  _CustomCounterController() : super(0);
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
// expect_lint: proper_controller_dispose
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
  late final AnimationController _controller1, _controller2;
  // expect_lint: proper_controller_dispose
  late final ScrollController _scrollController;
  // expect_lint: proper_controller_dispose
  late final PageController _pageController;
  // expect_lint: proper_controller_dispose
  late final TabController _tabController;
  // expect_lint: proper_controller_dispose
  late final SearchController _searchController;
  // expect_lint: proper_controller_dispose
  late final UndoHistoryController _undoHistoryController;

  // It also works for custom controllers
  // expect_lint: proper_controller_dispose
  late final _CustomController _customController;
  // expect_lint: proper_controller_dispose
  late final _CustomCounterController _customCounterController;

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
