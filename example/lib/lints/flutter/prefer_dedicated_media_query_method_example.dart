// ignore_for_file: unused_local_variable

import 'package:flutter/widgets.dart';

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    // expect_lint: prefer_dedicated_media_query_method
    final accessibleNavigation = MediaQuery.of(context).accessibleNavigation;
    // expect_lint: prefer_dedicated_media_query_method
    final alwaysUse24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    // expect_lint: prefer_dedicated_media_query_method
    final boldText = MediaQuery.of(context).boldText;
    // expect_lint: prefer_dedicated_media_query_method
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // expect_lint: prefer_dedicated_media_query_method
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    // expect_lint: prefer_dedicated_media_query_method
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    // expect_lint: prefer_dedicated_media_query_method
    final gestureSettings = MediaQuery.of(context).gestureSettings;
    // expect_lint: prefer_dedicated_media_query_method
    final highContrast = MediaQuery.of(context).highContrast;
    // expect_lint: prefer_dedicated_media_query_method
    final invertColors = MediaQuery.of(context).invertColors;
    // expect_lint: prefer_dedicated_media_query_method
    final navigationMode = MediaQuery.of(context).navigationMode;
    // expect_lint: prefer_dedicated_media_query_method
    final orientation = MediaQuery.of(context).orientation;
    // expect_lint: prefer_dedicated_media_query_method
    final padding = MediaQuery.of(context).padding;
    // expect_lint: prefer_dedicated_media_query_method
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    // expect_lint: prefer_dedicated_media_query_method
    final size = MediaQuery.of(context).size;
    // expect_lint: prefer_dedicated_media_query_method
    final systemGestureInsets = MediaQuery.of(context).systemGestureInsets;
    // expect_lint: prefer_dedicated_media_query_method
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // expect_lint: prefer_dedicated_media_query_method
    final viewInsets = MediaQuery.of(context).viewInsets;
    // expect_lint: prefer_dedicated_media_query_method
    final viewPadding = MediaQuery.of(context).viewPadding;

    return const Placeholder();
  }
}
