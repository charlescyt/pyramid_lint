import 'package:flutter/material.dart';

class WrapWithListenableBuilderExample extends StatefulWidget {
  const WrapWithListenableBuilderExample({super.key});

  @override
  State<WrapWithListenableBuilderExample> createState() => _WrapWithListenableBuilderExampleState();
}

class _WrapWithListenableBuilderExampleState extends State<WrapWithListenableBuilderExample> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_focusNode.hasFocus ? 'Focused' : 'Unfocused'),
        TextFormField(focusNode: _focusNode),
      ],
    );
  }
}
