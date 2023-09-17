# Pyramid Lint

[pyramid_lint] introduces a set of additional lints and fixes to enforce a consistent coding style, prevent common mistakes and enhance code readability using [custom_lint].

## Table of contents

- [Table of contents](#table-of-contents)
- [Installation](#installation)
- [Configuration](#configuration)
- [Dart lints](#dart-lints)
  - [avoid_empty_block](#avoid_empty_block)
  - [prefer_declaring_const_constructor](#prefer_declaring_const_constructor)
  - [prefer_declaring_parameter_name](#prefer_declaring_parameter_name)
  - [prefer_immediate_return](#prefer_immediate_return)
  - [prefer_iterable_first](#prefer_iterable_first)
  - [prefer_iterable_last](#prefer_iterable_last)
- [Flutter lints](#flutter-lints)
  - [avoid_single_child_in_flex](#avoid_single_child_in_flex)
  - [correct_order_for_super_dispose](#correct_order_for_super_dispose)
  - [correct_order_for_super_init_state](#correct_order_for_super_init_state)
  - [prefer_border_from_border_side](#prefer_border_from_border_side)
  - [prefer_border_radius_all](#prefer_border_radius_all)
  - [prefer_spacer](#prefer_spacer)
  - [prefer_text_rich](#prefer_text_rich)
  - [proper_usage_of_expanded_and_flexible](#proper_usage_of_expanded_and_flexible)
- [Assists](#assists)
  - [use_edge_insets_zero](#use_edge_insets_zero)
  - [wrap_with_expanded](#wrap_with_expanded)
  - [wrap_with_stack](#wrap_with_stack)

## Installation

Run the following command to add `custom_lint` and `pyramid_lint` to your project's dev dependencies:

```sh
dart pub add --dev custom_lint pyramid_lint
```

Enable `custom_lint` in your `analysis_options.yaml` file:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## Configuration

By default, all lints are enabled.
To disable a specific lint, add the following to your `analysis_options.yaml` file:

```yaml
custom_lint:
  rules:
    - specific_lint_rule: false # disable specific_lint_rule
```

To disable all lints and only enable the one you want, edit your `analysis_options.yaml` file as below:

```yaml
custom_lint:
  enable_all_lint_rules: false # disable all lints
  rules:
    - specific_lint_rule # enable specific_lint_rule
```

Some lints have additional configuration options. To configure a lint, follow the example below:

```yaml
custom_lint:
  rules:
    - configurable_lint_rule:
      option1: value1
      option2: value2
```

## Dart lints

### avoid_empty_block

Empty block usually indicates a missing implementation.

Bad

```dart
void doSomething() {

}
```

Good

```dart
void doSomething() {
  actuallyDoSomething();
}

void doSomething() {}
  // TODO: implement doSomething
}
```

### prefer_declaring_const_constructor

Constructors of classes with only final fields should be declared as const constructors when possible.

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

Fix

![prefer_declaring_const_constructor](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_declaring_const_constructor.gif)

### prefer_declaring_parameter_name

Not declaring parameter name decreases code readability and the IDEs code completion will not be able to suggest the parameter name.

Bad

```dart
typedef ItemBuilder = Widget Function(BuildContext, int);
```

Good

```dart
typedef ItemBuilder = Widget Function(BuildContext context, int index);
```

### prefer_immediate_return

Declaring a variable to return it on the next line is unnecessary.

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

Fix

![prefer_immediate_return](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_immediate_return.gif)

### prefer_iterable_first

Using iterable.first increases code readability.

Bad

```dart
const numbers = [1, 2, 3];
int firstNumber;

firstNumber = numbers[0];
firstNumber = numbers.elementAt(0);
```

Good

```dart
const numbers = [1, 2, 3];
int firstNumber;

firstNumber = numbers.first;
```

Fix

![prefer_iterable_first](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_iterable_first.gif)

### prefer_iterable_last

Using iterable.last increases code readability.

Bad

```dart
const numbers = [1, 2, 3];
int lastNumber;

lastNumber = numbers[numbers.length - 1];
lastNumber = numbers.elementAt(numbers.length - 1);
```

Fix

![prefer_iterable_last](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_iterable_last.gif)

Good

```dart
const numbers = [1, 2, 3];
int lastNumber;

lastNumber = numbers.last;
```

## Flutter lints

### avoid_single_child_in_flex

Using Column or Row with only one child is inefficient.

Bad

```dart
Row(
  children: [
    Container(),
  ],
)
```

Good

```dart
Align(
  child: Container(),
)

// or

Center(
  child: Container(),
)
```

Fix

![avoid_single_child_in_flex](https://github.com/charlescyt/pyramid_lint/blob/main/resources/avoid_single_child_in_flex.gif)

### correct_order_for_super_dispose

super.dispose() should be called at the end of the dispose method.

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

Fix

![correct_order_for_dispose](https://github.com/charlescyt/pyramid_lint/blob/main/resources/correct_order_for_super_dispose.gif)

### correct_order_for_super_init_state

super.initState() should be called at the start of the initState method.

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

Fix

![correct_order_for_init_state](https://github.com/charlescyt/pyramid_lint/blob/main/resources/correct_order_for_super_init_state.gif)

### prefer_border_from_border_side

Border.all is not a const constructor and it uses const constructor Border.fromBorderSide internally.

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

Fix

![prefer_border_from_border_side](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_border_from_border_side.gif)

### prefer_border_radius_all

BorderRadius.all is not a const constructor and it uses const constructor BorderRadius.circular internally.

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

Fix

![prefer_border_radius_all](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_border_radius_all.gif)

### prefer_spacer

Using Expanded with an empty Container or SizedBox is inefficient.

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

Fix

![prefer_spacer](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_spacer.gif)

### prefer_text_rich

RichText does not inherit TextStyle from DefaultTextStyle.

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

Fix

![prefer_text_rich](https://github.com/charlescyt/pyramid_lint/blob/main/resources/prefer_text_rich.gif)

### proper_usage_of_expanded_and_flexible

Expanded and Flexible should be placed inside a Row, Column, or Flex.

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

## Assists

### use_edge_insets_zero

Replace

- EdgeInsets.all(0)
- EdgeInsets.fromLTRB(0, 0, 0, 0)
- EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0)
- EdgeInsets.symmetric(horizontal: 0, vertical: 0)

with EdgeInsets.zero.

![use_edge_insets_zero](https://github.com/charlescyt/pyramid_lint/blob/main/resources/use_edge_insets_zero.gif)

### wrap_with_expanded

Wrap the selected widget with an Expanded.

![wrap_with_expanded](https://github.com/charlescyt/pyramid_lint/blob/main/resources/wrap_with_expanded.gif)

### wrap_with_stack

Wrap the selected widget with a Stack.

![wrap_with_stack](https://github.com/charlescyt/pyramid_lint/blob/main/resources/wrap_with_stack.gif)

[pyramid_lint]: https://pub.dev/packages/pyramid_lint
[custom_lint]: https://pub.dev/packages/custom_lint
