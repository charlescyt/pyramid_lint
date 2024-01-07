// ignore_for_file: unused_local_variable, deprecated_member_use, max_lines_for_function, max_lines_for_file

import 'package:flutter/material.dart';

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    // expect_lint: prefer_dedicated_media_query_method
    final mqaccessibleNavigation = mq.accessibleNavigation;
    // expect_lint: prefer_dedicated_media_query_method
    final mqalwaysUse24HourFormat = mq.alwaysUse24HourFormat;
    // expect_lint: prefer_dedicated_media_query_method
    final mqboldText = mq.boldText;
    // expect_lint: prefer_dedicated_media_query_method
    final mqdevicePixelRatio = mq.devicePixelRatio;
    // expect_lint: prefer_dedicated_media_query_method
    final mqdisableAnimations = mq.disableAnimations;
    // expect_lint: prefer_dedicated_media_query_method
    final mqdisplayFeatures = mq.displayFeatures;
    // expect_lint: prefer_dedicated_media_query_method
    final mqgestureSettings = mq.gestureSettings;
    // expect_lint: prefer_dedicated_media_query_method
    final mqhighContrast = mq.highContrast;
    // expect_lint: prefer_dedicated_media_query_method
    final mqinvertColors = mq.invertColors;
    // expect_lint: prefer_dedicated_media_query_method
    final mqnavigationMode = mq.navigationMode;
    // expect_lint: prefer_dedicated_media_query_method
    final mqonOffSwitchLabels = mq.onOffSwitchLabels;
    // expect_lint: prefer_dedicated_media_query_method
    final mqorientation = mq.orientation;
    // expect_lint: prefer_dedicated_media_query_method
    final mqpadding = mq.padding;
    // expect_lint: prefer_dedicated_media_query_method
    final mqplatformBrightness = mq.platformBrightness;
    // expect_lint: prefer_dedicated_media_query_method
    final mqsize = mq.size;
    // expect_lint: prefer_dedicated_media_query_method
    final mqsystemGestureInsets = mq.systemGestureInsets;
    // expect_lint: prefer_dedicated_media_query_method
    final mqtextScaleFactor = mq.textScaleFactor;
    // expect_lint: prefer_dedicated_media_query_method
    final mqtextScaler = mq.textScaler;
    // expect_lint: prefer_dedicated_media_query_method
    final mqviewInsets = mq.viewInsets;
    // expect_lint: prefer_dedicated_media_query_method
    final mqviewPadding = mq.viewPadding.bottom;

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
    final onOffSwitchLabels = MediaQuery.of(context).onOffSwitchLabels;
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
    final textScaler = MediaQuery.of(context).textScaler;
    // expect_lint: prefer_dedicated_media_query_method
    final viewInsets = MediaQuery.of(context).viewInsets;
    // expect_lint: prefer_dedicated_media_query_method
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      body: Container(
        // expect_lint: prefer_dedicated_media_query_method
        height: mq.size.height,
      ),
    );
  }

  void fn(MediaQueryData mq) {
    final size = mq.size;
  }
}
