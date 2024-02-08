// ignore_for_file: unused_local_variable, deprecated_member_use, max_lines_for_file

import 'package:flutter/material.dart';

void mediaQueryOf(BuildContext context) {
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
}

void mediaQueryMaybeOf(BuildContext context) {
  final accessibleNavigation =
      // expect_lint: prefer_dedicated_media_query_method
      MediaQuery.maybeOf(context)?.accessibleNavigation;
  final alwaysUse24HourFormat =
      // expect_lint: prefer_dedicated_media_query_method
      MediaQuery.maybeOf(context)?.alwaysUse24HourFormat;
  // expect_lint: prefer_dedicated_media_query_method
  final boldText = MediaQuery.maybeOf(context)?.boldText;
  // expect_lint: prefer_dedicated_media_query_method
  final devicePixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio;
  // expect_lint: prefer_dedicated_media_query_method
  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
  // expect_lint: prefer_dedicated_media_query_method
  final displayFeatures = MediaQuery.maybeOf(context)?.displayFeatures;
  // expect_lint: prefer_dedicated_media_query_method
  final gestureSettings = MediaQuery.maybeOf(context)?.gestureSettings;
  // expect_lint: prefer_dedicated_media_query_method
  final highContrast = MediaQuery.maybeOf(context)?.highContrast;
  // expect_lint: prefer_dedicated_media_query_method
  final invertColors = MediaQuery.maybeOf(context)?.invertColors;
  // expect_lint: prefer_dedicated_media_query_method
  final navigationMode = MediaQuery.maybeOf(context)?.navigationMode;
  // expect_lint: prefer_dedicated_media_query_method
  final onOffSwitchLabels = MediaQuery.maybeOf(context)?.onOffSwitchLabels;
  // expect_lint: prefer_dedicated_media_query_method
  final orientation = MediaQuery.maybeOf(context)?.orientation;
  // expect_lint: prefer_dedicated_media_query_method
  final padding = MediaQuery.maybeOf(context)?.padding;
  // expect_lint: prefer_dedicated_media_query_method
  final platformBrightness = MediaQuery.maybeOf(context)?.platformBrightness;
  // expect_lint: prefer_dedicated_media_query_method
  final size = MediaQuery.maybeOf(context)?.size;
  // expect_lint: prefer_dedicated_media_query_method
  final systemGestureInsets = MediaQuery.maybeOf(context)?.systemGestureInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaleFactor = MediaQuery.maybeOf(context)?.textScaleFactor;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaler = MediaQuery.maybeOf(context)?.textScaler;
  // expect_lint: prefer_dedicated_media_query_method
  final viewInsets = MediaQuery.maybeOf(context)?.viewInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final viewPadding = MediaQuery.maybeOf(context)?.viewPadding;
}

void indirectMediaQueryOf(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);

  // expect_lint: prefer_dedicated_media_query_method
  final accessibleNavigation = mediaQuery.accessibleNavigation;
  // expect_lint: prefer_dedicated_media_query_method
  final alwaysUse24HourFormat = mediaQuery.alwaysUse24HourFormat;
  // expect_lint: prefer_dedicated_media_query_method
  final boldText = mediaQuery.boldText;
  // expect_lint: prefer_dedicated_media_query_method
  final devicePixelRatio = mediaQuery.devicePixelRatio;
  // expect_lint: prefer_dedicated_media_query_method
  final disableAnimations = mediaQuery.disableAnimations;
  // expect_lint: prefer_dedicated_media_query_method
  final displayFeatures = mediaQuery.displayFeatures;
  // expect_lint: prefer_dedicated_media_query_method
  final gestureSettings = mediaQuery.gestureSettings;
  // expect_lint: prefer_dedicated_media_query_method
  final highContrast = mediaQuery.highContrast;
  // expect_lint: prefer_dedicated_media_query_method
  final invertColors = mediaQuery.invertColors;
  // expect_lint: prefer_dedicated_media_query_method
  final navigationMode = mediaQuery.navigationMode;
  // expect_lint: prefer_dedicated_media_query_method
  final onOffSwitchLabels = mediaQuery.onOffSwitchLabels;
  // expect_lint: prefer_dedicated_media_query_method
  final orientation = mediaQuery.orientation;
  // expect_lint: prefer_dedicated_media_query_method
  final padding = mediaQuery.padding;
  // expect_lint: prefer_dedicated_media_query_method
  final platformBrightness = mediaQuery.platformBrightness;
  // expect_lint: prefer_dedicated_media_query_method
  final size = mediaQuery.size;
  // expect_lint: prefer_dedicated_media_query_method
  final systemGestureInsets = mediaQuery.systemGestureInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaleFactor = mediaQuery.textScaleFactor;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaler = mediaQuery.textScaler;
  // expect_lint: prefer_dedicated_media_query_method
  final viewInsets = mediaQuery.viewInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final viewPadding = mediaQuery.viewPadding;
}

void indirectMediaQueryMaybeOf(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);

  // expect_lint: prefer_dedicated_media_query_method
  final accessibleNavigation = mediaQuery?.accessibleNavigation;
  // expect_lint: prefer_dedicated_media_query_method
  final alwaysUse24HourFormat = mediaQuery?.alwaysUse24HourFormat;
  // expect_lint: prefer_dedicated_media_query_method
  final boldText = mediaQuery?.boldText;
  // expect_lint: prefer_dedicated_media_query_method
  final devicePixelRatio = mediaQuery?.devicePixelRatio;
  // expect_lint: prefer_dedicated_media_query_method
  final disableAnimations = mediaQuery?.disableAnimations;
  // expect_lint: prefer_dedicated_media_query_method
  final displayFeatures = mediaQuery?.displayFeatures;
  // expect_lint: prefer_dedicated_media_query_method
  final gestureSettings = mediaQuery?.gestureSettings;
  // expect_lint: prefer_dedicated_media_query_method
  final highContrast = mediaQuery?.highContrast;
  // expect_lint: prefer_dedicated_media_query_method
  final invertColors = mediaQuery?.invertColors;
  // expect_lint: prefer_dedicated_media_query_method
  final navigationMode = mediaQuery?.navigationMode;
  // expect_lint: prefer_dedicated_media_query_method
  final onOffSwitchLabels = mediaQuery?.onOffSwitchLabels;
  // expect_lint: prefer_dedicated_media_query_method
  final orientation = mediaQuery?.orientation;
  // expect_lint: prefer_dedicated_media_query_method
  final padding = mediaQuery?.padding;
  // expect_lint: prefer_dedicated_media_query_method
  final platformBrightness = mediaQuery?.platformBrightness;
  // expect_lint: prefer_dedicated_media_query_method
  final size = mediaQuery?.size;
  // expect_lint: prefer_dedicated_media_query_method
  final systemGestureInsets = mediaQuery?.systemGestureInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaleFactor = mediaQuery?.textScaleFactor;
  // expect_lint: prefer_dedicated_media_query_method
  final textScaler = mediaQuery?.textScaler;
  // expect_lint: prefer_dedicated_media_query_method
  final viewInsets = mediaQuery?.viewInsets;
  // expect_lint: prefer_dedicated_media_query_method
  final viewPadding = mediaQuery?.viewPadding;
}
