import 'package:custom_lint_builder/custom_lint_builder.dart';

const widgetChecker = TypeChecker.fromName(
  'Widget',
  packageName: 'flutter',
);

const statelessWidgetChecker = TypeChecker.fromName(
  'StatelessWidget',
  packageName: 'flutter',
);

const statefulWidgetChecker = TypeChecker.fromName(
  'StatefulWidget',
  packageName: 'flutter',
);

const widgetStateChecker = TypeChecker.fromName(
  'State',
  packageName: 'flutter',
);

const containerChecker = TypeChecker.fromName(
  'Container',
  packageName: 'flutter',
);

const sizedBoxChecker = TypeChecker.fromName(
  'SizedBox',
  packageName: 'flutter',
);

const paddingChecker = TypeChecker.fromName(
  'Padding',
  packageName: 'flutter',
);

const edgeInsetsChecker = TypeChecker.fromName(
  'EdgeInsets',
  packageName: 'flutter',
);

const borderChecker = TypeChecker.fromName(
  'Border',
  packageName: 'flutter',
);

const borderRadiusChecker = TypeChecker.fromName(
  'BorderRadius',
  packageName: 'flutter',
);

const flexChecker = TypeChecker.fromName(
  'Flex',
  packageName: 'flutter',
);

const expandedChecker = TypeChecker.fromName(
  'Expanded',
  packageName: 'flutter',
);

const flexibleChecker = TypeChecker.fromName(
  'Flexible',
  packageName: 'flutter',
);

const expandedOrFlexibleChecker = TypeChecker.any(
  [
    expandedChecker,
    flexibleChecker,
  ],
);

const richTextChecker = TypeChecker.fromName(
  'RichText',
  packageName: 'flutter',
);

const listChecker = TypeChecker.fromUrl('dart:core#List');

const mediaQueryChecker = TypeChecker.fromName(
  'MediaQuery',
  packageName: 'flutter',
);

const mediaQueryDataChecker = TypeChecker.fromName(
  'MediaQueryData',
  packageName: 'flutter',
);

const animationControllerChecker = TypeChecker.fromName(
  'AnimationController',
  packageName: 'flutter',
);

const pageControllerChecker = TypeChecker.fromName(
  'PageController',
  packageName: 'flutter',
);

const scrollControllerChecker = TypeChecker.fromName(
  'ScrollController',
  packageName: 'flutter',
);

const searchControllerChecker = TypeChecker.fromName(
  'SearchController',
  packageName: 'flutter',
);

const tabControllerChecker = TypeChecker.fromName(
  'TabController',
  packageName: 'flutter',
);

const textEditingControllerChecker = TypeChecker.fromName(
  'TextEditingController',
  packageName: 'flutter',
);

const undoHistoryControllerChecker = TypeChecker.fromName(
  'UndoHistoryController',
  packageName: 'flutter',
);

const changeNotifierChecker = TypeChecker.fromName(
  'ChangeNotifier',
  packageName: 'flutter',
);

// Controllers that do not extend ChangeNotifier class
const disposableControllerChecker = TypeChecker.any(
  [
    animationControllerChecker,
  ],
);
