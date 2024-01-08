<p align="center">
  <img src="https://github.com/charlescyt/pyramid_lint/raw/main/screenshots/proper_super_init_state_demo.gif" width="800" />
</p>

<p align="center">
<strong>Linting tool for Dart and Flutter projects.</strong>
</p>

# Pyramid Lint

Pyramid Lint is a linting tool built with [custom_lint]. It offers a set of additional lints and quick fixes to help developers enforce a consistent coding style, prevent common mistakes and enhance code readability.

## Table of contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Dart lints](#dart-lints)
  - [always_declare_parameter_names](#always_declare_parameter_names)
  - [avoid_abbreviations_in_doc_comments](#avoid_abbreviations_in_doc_comments)
  - [avoid_duplicate_import](#avoid_duplicate_import)
  - [avoid_dynamic](#avoid_dynamic)
  - [avoid_empty_blocks](#avoid_empty_blocks)
  - [avoid_inverted_boolean_expressions](#avoid_inverted_boolean_expressions)
  - [avoid_unused_parameters](#avoid_unused_parameters)
  - [boolean_prefix](#boolean_prefix)
  - [doc_comments_before_annotations](#doc_comments_before_annotations)
  - [max_lines_for_file](#max_lines_for_file)
  - [max_lines_for_function](#max_lines_for_function)
  - [no_self_comparisons](#no_self_comparisons)
  - [prefer_async_await](#prefer_async_await)
  - [prefer_declaring_const_constructors](#prefer_declaring_const_constructors)
  - [prefer_immediate_return](#prefer_immediate_return)
  - [prefer_iterable_first](#prefer_iterable_first)
  - [prefer_iterable_last](#prefer_iterable_last)
  - [prefer_library_prefixes](#prefer_library_prefixes)
  - [prefer_new_line_before_return](#prefer_new_line_before_return)
  - [prefer_underscore_for_unused_callback_parameters](#prefer_underscore_for_unused_callback_parameters)
  - [unnecessary_nullable_return_type](#unnecessary_nullable_return_type)
- [Flutter lints](#flutter-lints)
  - [avoid_returning_widgets](#avoid_returning_widgets)
  - [avoid_single_child_in_flex](#avoid_single_child_in_flex)
  - [avoid_widget_state_public_members](#avoid_widget_state_public_members)
  - [prefer_async_callback](#prefer_async_callback)
  - [prefer_border_from_border_side](#prefer_border_from_border_side)
  - [prefer_border_radius_all](#prefer_border_radius_all)
  - [prefer_dedicated_media_query_method](#prefer_dedicated_media_query_method)
  - [prefer_spacer](#prefer_spacer)
  - [prefer_text_rich](#prefer_text_rich)
  - [proper_controller_dispose](#proper_controller_dispose)
  - [proper_edge_insets_constructor](#proper_edge_insets_constructor)
  - [proper_expanded_and_flexible](#proper_expanded_and_flexible)
  - [proper_from_environment](#proper_from_environment)
  - [proper_super_dispose](#proper_super_dispose)
  - [proper_super_init_state](#proper_super_init_state)
- [Dart assists](#dart-assists)
  - [invert_boolean_expression](#invert_boolean_expression)
  - [swap_then_else_expression](#swap_then_else_expression)
- [Flutter assists](#flutter-assists)
  - [use_edge_insets_zero](#use_edge_insets_zero)
  - [wrap_with_expanded](#wrap_with_expanded)
  - [wrap_with_layout_builder](#wrap_with_layout_builder)
  - [wrap_with_stack](#wrap_with_stack)
- [Contributing](#contributing)
- [License](#license)

## Installation

Run the following command to add `custom_lint` and `pyramid_lint` to your project's dev dependencies:

```sh
dart pub add --dev custom_lint pyramid_lint
```

Then enable `custom_lint` in your `analysis_options.yaml` file. You can also exclude generated files from analysis.

```yaml
analyzer:
  plugins:
    - custom_lint

  exclude:
    - "**.freezed.dart"
    - "**.g.dart"
    - "**.gr.dart"
```

## Configuration

By default, all lints are enabled. To disable a specific lint, add the following to your `analysis_options.yaml` file:

```yaml
custom_lint:
  rules:
    - specific_lint_rule: false # disable specific_lint_rule
```

If you prefer to disable all lints and only enable specific ones, you can edit your analysis_options.yaml file as below:

```yaml
custom_lint:
  enable_all_lint_rules: false # disable all lints
  rules:
    - specific_lint_rule # enable specific_lint_rule
```

Some lints are configurable. To configure a lint, follow the example below:

```yaml
custom_lint:
  rules:
    - configurable_lint_rule:
      option1: value1
      option2: value2
```

## Dart lints

### always_declare_parameter_names

Parameter names should always be declared to enhance code readability and enable IDEs to provide code completion suggestions.

- Severity: info

Bad

```dart
typedef ItemBuilder = Widget? Function(BuildContext, int);

// IDE's code completion with default parameter names p0, p1, ...
itemBuilder: (p0, p1) {},
```

Good

```dart
typedef ItemBuilder = Widget? Function(BuildContext context, int index);

// IDE's code completion with descriptive parameter names
itemBuilder: (context, index) {},
```

### avoid_abbreviations_in_doc_comments

Avoid using abbreviations in doc comments as they can hinder readability and cause confusion for readers.

- Severity: warning
- Options:
  - abbreviations: `List<String>`

```yaml
custom_lint:
  rules:
    - avoid_abbreviations_in_doc_comments:
      abbreviations: ['approx.']
```

see: [effective-dart](https://dart.dev/effective-dart/documentation#avoid-abbreviations-and-acronyms-unless-they-are-obvious)

Included abbreviations:

- e.g.
- i.e.
- etc.
- et al.

Bad

```dart
/// This is documentation.
///
/// e.g. ...
int function(){}
```

Good

```dart
/// This is documentation.
///
/// For example ...
int function(){}
```

### avoid_duplicate_import

Duplicate imports can lead to confusion.

- Severity: warning

Bad

```dart
import 'dart:math' as math show max;
import 'dart:math';

final a = math.max(1, 10);
final b = min(1, 10);
```

Good

```dart
import 'dart:math' as math show max, min;

final a = math.max(1, 10);
final b = math.min(1, 10);
```

### avoid_dynamic

While the `dynamic` type can be useful in certain scenarios, it sacrifices the benefits of static typing and decreases code readability. Using `dynamic` with `Map` will not trigger this lint.

- Severity: info

Bad

```dart
dynamic thing = 'text';
void log(dynamic something) => print(something);
List<dynamic> list = [1, 2, 3];
final setLiteral = <dynamic>{'a', 'b', 'c'};
```

Good

```dart
String thing = 'text';
void log(String something) => print(something);
List<int> list = [1, 2, 3];
final setLiteral = <String>{'a', 'b', 'c'};
```

### avoid_empty_blocks

Empty block usually indicates a missing implementation.

- Severity: warning

Bad

```dart
void doSomething() {}
```

Good

```dart
void doSomething() {
  actuallyDoSomething();
}

void doSomething() {
  // TODO: implement doSomething
}
```

### avoid_inverted_boolean_expressions

Unnecessary inverted boolean expression should be avoided since it decreases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
if (!(number > 0)) {}
final text = !(number == 0) ? 'Not zero' : 'Zero';
```

Good

```dart
if (number <= 0) {}
final text = number != 0 ? 'Not zero' : 'Zero';
```

### avoid_unused_parameters

Unused parameters should be removed to avoid confusion.

- Severity: warning
- Options:
  - excluded_parameters: `List<String>`

```yaml
custom_lint:
  rules:
    - avoid_unused_parameters:
      excluded_parameters: ['ref']
```

Bad

```dart
void log(String a, String b) {
  print(a);
}
```

Good

```dart
void log(String a) {
  print(a);
}
```

### boolean_prefix

Boolean variables, functions and getters that return a boolean value should be prefixed with specific verbs.

- Severity: info
- Options:
  - valid_prefixes: `List<String>`

```yaml
custom_lint:
  rules:
    - boolean_prefix:
      valid_prefixes: ['...']
```

Default valid prefixes:

- is
- are
- was
- were
- has
- have
- had
- can
- should
- will
- do
- does
- did

see: [effective-dart](https://dart.dev/effective-dart/design#prefer-a-non-imperative-verb-phrase-for-a-boolean-property-or-variable)

Bad

```dart
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  bool get origin => x == 0 && y == 0;

  bool samePoint(Point other) => x == other.x && y == other.y;
}
```

Good

```dart
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  bool get isOrigin => x == 0 && y == 0;

  bool isSamePoint(Point other) => x == other.x && y == other.y;
}
```

### doc_comments_before_annotations

Doc comments should be placed before annotations.

- Severity: info
- Quick fix: ✓

see: [effective-dart](https://dart.dev/effective-dart/documentation#do-put-doc-comments-before-metadata-annotations)

Bad

```dart
@immutable
/// Some documentation.
class A {}
```

Good

```dart
/// Some documentation.
@immutable
class A {}
```

### max_lines_for_file

A file should not exceed a certain number of lines.

- Severity: info
- Options:
  - max_lines: `int` (default: 200)

```yaml
custom_lint:
  rules:
    - max_lines_for_file:
      max_lines: 500
```

### max_lines_for_function

A function should not exceed a certain number of lines.

- Severity: info
- Options:
  - max_lines: `int` (default: 100)

```yaml
custom_lint:
  rules:
    - max_lines_for_function:
      max_lines: 200
```

### no_self_comparisons

Self comparison is usually a mistake.

- Severity: warning

Bad

```dart
if (foo == foo) {}
if (foo.property == foo.property) {}
```

Good

```dart
if (foo == bar) {}
if (foo.property == bar.property) {}
```

### prefer_async_await

Using async/await improves code readability.

see: [effective-dart](https://dart.dev/effective-dart/usage#prefer-asyncawait-over-using-raw-futures)

- Severity: info

Bad

```dart
void fetchData() {
  performAsyncOperation().then((result) {
    print(result);
  }).catchError((Object? error) {
    print('Error: $error');
  }).whenComplete(() {
    print('Done');
  });
}
```

Good

```dart
Future<void> fetchData() async {
  try {
    final result = await performAsyncOperation();
    print(result);
  } catch (error) {
    print('Error: $error');
  } finally {
    print('Done');
  }
}
```

### prefer_declaring_const_constructors

Constructors of classes with only final fields should be declared as const constructors when possible.

- Severity: info
- Quick fix: ✓

Bad

```dart
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point.origin()
      : x = 0,
        y = 0;
}
```

Good

```dart
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  const Point.origin()
      : x = 0,
        y = 0;
}
```

### prefer_immediate_return

By directly returning the expression instead of assigning it to a variable and then returning the variable, you can simplify the code and improve readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
int add(int a, int b) {
  final result = a + b;
  return result;
}
```

Good

```dart
int add(int a, int b) {
  return a + b;
}
```

### prefer_iterable_first

Using `iterable.first` increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
const numbers = [1, 2, 3];

final firstNumber = numbers[0];
// or
final firstNumber = numbers.elementAt(0);
```

Good

```dart
const numbers = [1, 2, 3];
final firstNumber = numbers.first;
```

### prefer_iterable_last

Using `iterable.last` increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
const numbers = [1, 2, 3];

final lastNumber = numbers[numbers.length - 1];
// or
final lastNumber = numbers.elementAt(numbers.length - 1);
```

Good

```dart
const numbers = [1, 2, 3];
final lastNumber = numbers.last;
```

### prefer_library_prefixes

Use library prefixes to avoid name conflicts and increase code readability.

- Severity: info
- Quick fix: ✓
- Options:
  - include_default_libraries: `bool` (default: true)
  - libraries: `List<String>`

```yaml
custom_lint:
  rules:
    - prefer_library_prefixes:
      include_default_libraries: false
      libraries: ['package:http/http.dart']
```

Default libraries:

- 'dart:developer'
- 'dart:math'

Bad

```dart
import 'dart:developer';
import 'dart:math';

print(log(e));
log('message');
```

```dart
import 'package:http/http.dart';

final response = await post(...);
```

Good

```dart
import 'dart:developer' as developer;
import 'dart:math' as math;

print(math.log(math.e));
developer.log('message');

```

```dart
import 'package:http/http.dart' as http;

final response = await http.post(...);
```

### prefer_new_line_before_return

Adding a new line before the return statement increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
if (...) {
  ...
  return ...;
}
return ...;
```

Good

```dart
if (...) {
  ...

  return ...;
}

return ...;
```

### prefer_underscore_for_unused_callback_parameters

Using `_` for unused callback parameters clearly convey that the parameter is intentionally ignored within the code block. If the function has multiple unused parameters, use additional underscores such as `__`, `___`.

see: [effective-dart](https://dart.dev/effective-dart/style#prefer-using-_-__-etc-for-unused-callback-parameters)

- Severity: info

Bad

```dart
itemBuilder: (context, index) {
  return Text('Item $index');
}
```

Good

```dart
itemBuilder: (_, index) {
  return Text('Item $index');
}
```

### unnecessary_nullable_return_type

Declaring functions or methods with a nullable return type is unnecessary when the return value is never null.

- Severity: warning
- Quick fix: ✓

Bad

```dart
int? sum(int a, int b) {
  return a + b;
}
```

Good

```dart
int sum(int a, int b) {
  return a + b;
}
```

## Flutter lints

### avoid_returning_widgets

Returning widgets is not recommended for performance reasons.

- Severity: info

Bad

```dart
class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWidget(),
        _buildWidget(),
      ],
    );
  }

  Widget _buildWidget() {
    return ...;
  }
}
```

Good

```dart
class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        B(),
        B(),
      ],
    );
  }
}

class B extends StatelessWidget {
  const B({super.key});

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
```

### avoid_single_child_in_flex

Using Column or Row with only one child is inefficient.

- Severity: info
- Quick fix: ✓

Bad

```dart
Row(
  children: [
    Placeholder(),
  ],
)
```

Good

```dart
Align(
  child: Placeholder(),
)

// or

Center(
  child: Placeholder(),
)
```

### avoid_widget_state_public_members

Avoid declaring public members in widget state classes.

- Severity: info

Bad

```dart
class _MyWidgetState extends State<MyWidget> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: increment,
      child: Text('$counter'),
    );
  }
}
```

Good

```dart
class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _increment,
      child: Text('$_counter'),
    );
  }
}
```

### prefer_async_callback

Using the built-in typedef `AsyncCallback` increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
final Future<void> Function() cb;
```

Good

```dart
final AsyncCallback cb;
```

### prefer_border_from_border_side

`Border.all` is not a const constructor and it uses const constructor `Border.fromBorderSide` internally.

- Severity: info
- Quick fix: ✓

Bad

```dart
DecoratedBox(
  decoration: BoxDecoration(
    border: Border.all(
      width: 1,
      style: BorderStyle.solid,
    ),
  ),
)
```

Good

```dart
const DecoratedBox(
  decoration: BoxDecoration(
    border: Border.fromBorderSide(
      BorderSide(
        width: 1,
        style: BorderStyle.solid,
      ),
    ),
  ),
)
```

### prefer_border_radius_all

`BorderRadius.all` is not a const constructor and it uses const constructor `BorderRadius.circular` internally.

- Severity: info
- Quick fix: ✓

Bad

```dart
DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
  ),
)
```

Good

```dart
const DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
)
```

### prefer_dedicated_media_query_method

Using MediaQuery.of(context) to access below properties will cause unnecessary rebuilds.

- Severity: info
- Quick fix: ✓

Properties:

- accessibleNavigation
- alwaysUse24HourFormat
- boldText
- devicePixelRatio
- disableAnimations
- displayFeatures
- gestureSettings
- highContrast
- invertColors
- navigationMode
- onOffSwitchLabels
- orientation
- padding
- platformBrightness
- size
- systemGestureInsets
- textScaleFactor (deprecated after v3.12.0-2.0.pre)
- textScaler
- viewInsets
- viewPadding

Bad

```dart
final size = MediaQuery.of(context).size;
final orientation = MediaQuery.maybeOf(context)?.orientation;
```

Good

```dart
final size = MediaQuery.sizeOf(context);
final orientation = MediaQuery.maybeOrientationOf(context);
```

### prefer_spacer

Using Expanded with an empty Container or SizedBox is inefficient.

- Severity: info
- Quick fix: ✓

Bad

```dart
Column(
  children: [
    Expanded(
      flex: 2,
      child: SizedBox(),
    ),
  ],
)
```

Good

```dart
Column(
  children: [
    Spacer(flex: 2),
  ],
)
```

### prefer_text_rich

`RichText` does not inherit TextStyle from DefaultTextStyle.

- Severity: info
- Quick fix: ✓

Bad

```dart
RichText(
  text: const TextSpan(
    text: 'Pyramid',
    children: [
      TextSpan(text: 'Lint'),
    ],
  ),
)
```

Good

```dart
const Text.rich(
  TextSpan(
    text: 'Pyramid',
    children: [
      TextSpan(text: 'Lint'),
    ],
  ),
)
```

### prefer_value_changed

Using the built-in typedef `ValueChanged` increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
final void Function(int) cb;
```

Good

```dart
final ValueChanged<int> cb;
```

### prefer_void_callback

Using the built-in typedef `VoidCallback` increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
final void Function() cb;
```

Good

```dart
final VoidCallback cb;
```

### proper_controller_dispose

Controllers should be disposed in `Widget`'s `dispose` method to avoid memory leaks. This lint checks for `AnimationController` and all `ChangeNotifier` subclasses such as `TextEditingController`, `ScrollController` and `TabController`.

- Severity: error
- Quick fix: ✓

Bad

```dart
class _MyWidgetState extends State<MyWidget> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

Good

```dart
class _MyWidgetState extends State<MyWidget> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
```

### proper_edge_insets_constructor

Using correct EdgeInsets constructor increases code readability.

- Severity: info
- Quick fix: ✓

Bad

```dart
padding = const EdgeInsets.fromLTRB(8, 8, 8, 8);
padding = const EdgeInsets.fromLTRB(8, 0, 8, 0);
padding = const EdgeInsets.fromLTRB(8, 4, 8, 4);
padding = const EdgeInsets.fromLTRB(8, 4, 8, 0);

padding = const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8);
padding = const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 0);
padding = const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4);
padding = const EdgeInsets.only(left: 2, top: 4, right: 6, bottom: 8);

padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0);
padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 0);
```

Good

```dart
padding = const EdgeInsets.all(8);
padding = const EdgeInsets.symmetric(horizontal: 8);
padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
padding = const EdgeInsets.only(left: 8, top: 4, right: 8);

padding = const EdgeInsets.all(8);
padding = const EdgeInsets.symmetric(horizontal: 8);
padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
padding = const EdgeInsets.fromLTRB(2, 4, 6, 8);

padding = const EdgeInsets.all(8);
padding = const EdgeInsets.symmetric(horizontal: 8);
```

### proper_expanded_and_flexible

Expanded and Flexible should be placed inside a Row, Column, or Flex.

- Severity: error

Bad

```dart
Center(
  child: Expanded(
    child: Container(),
  ),
)
```

Good

```dart
Row(
  children: [
    Expanded(
      child: Container(),
    ),
  ],
)
```

### proper_from_environment

The constructors `bool.fromEnvironment`, `int.fromEnvironment` and `String.fromEnvironment` are only guaranteed to work when invoked as a `const` constructor.

see: [dart-lang-issue](https://github.com/dart-lang/sdk/issues/42177)

- Severity: error
- Quick fix: ✓

Bad

```dart
final boolean = bool.fromEnvironment('bool');
int integer = int.fromEnvironment('int');
var string = String.fromEnvironment('String');
```

Good

```dart
const boolean = bool.fromEnvironment('bool');
const integer = int.fromEnvironment('int');
const string = String.fromEnvironment('String');
```

### proper_super_dispose

`super.dispose()` should be called at the end of the dispose method.

- Severity: error
- Quick fix: ✓

Bad

```dart
@override
void dispose() {
  super.dispose();
  _dispose();
}
```

Good

```dart
@override
void dispose() {
  _dispose();
  super.dispose();
}
```

### proper_super_init_state

`super.initState()` should be called at the start of the initState method.

- Severity: error
- Quick fix: ✓

Bad

```dart
@override
void initState() {
  _init();
  super.initState();
}
```

Good

```dart
@override
void initState() {
  super.initState();
  _init();
}
```

## Dart assists

### invert_boolean_expression

Invert a boolean expression.

![invert_boolean_expression](https://github.com/charlescyt/pyramid_lint/raw/main/resources/invert_boolean_expression.gif)

### swap_then_else_expression

Swap the then and else expression of a if-else expression or conditional expression.

![swap_then_else_expression](https://github.com/charlescyt/pyramid_lint/raw/main/resources/swap_then_else_expression.gif)

## Flutter assists

### use_edge_insets_zero

Replace

- EdgeInsets.all(0)
- EdgeInsets.fromLTRB(0, 0, 0, 0)
- EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0)
- EdgeInsets.symmetric(horizontal: 0, vertical: 0)

with EdgeInsets.zero.

![use_edge_insets_zero](https://github.com/charlescyt/pyramid_lint/raw/main/resources/use_edge_insets_zero.gif)

### wrap_with_expanded

Wrap the selected widget with an Expanded.

![wrap_with_expanded](https://github.com/charlescyt/pyramid_lint/raw/main/resources/wrap_with_expanded.gif)

### wrap_with_layout_builder

Wrap the selected widget with a LayoutBuilder.

![wrap_with_layout_builder](https://github.com/charlescyt/pyramid_lint/raw/main/resources/wrap_with_layout_builder.gif)

### wrap_with_stack

Wrap the selected widget with a Stack.

![wrap_with_stack](https://github.com/charlescyt/pyramid_lint/raw/main/resources/wrap_with_stack.gif)

## Contributing

Contributions are appreciated! You can contribute by:

- Creating an issue to report a bug or suggest a new feature.
- Submitting a pull request to fix a bug or implement a new feature.
- Improving the documentation.

To get started contributing to Pyramid Lint, please refer to the [Contributing guide][contributing_link].

## License

Pyramid Lint is licensed under the [MIT License][license_link].

<!-- Links -->

[custom_lint]: https://pub.dev/packages/custom_lint
[contributing_link]: https://github.com/charlescyt/pyramid_lint/blob/main/CONTRIBUTING.md
[license_link]: https://github.com/charlescyt/pyramid_lint/blob/main/LICENSE
