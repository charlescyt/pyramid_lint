# Changelog

## 1.3.0 - 2024-01-15

### Added

- Add new lint `no_self_comparisons` ([#9](https://github.com/charlescyt/pyramid_lint/pull/9))
- Add new lint `avoid_widget_state_public_members` ([#10](https://github.com/charlescyt/pyramid_lint/pull/10))
- Add new assist `wrap_with_value_listenable_builder` ([#16](https://github.com/charlescyt/pyramid_lint/pull/13) thanks to [imsamgarg])

### Changed

- `prefer_dedicated_media_query_method` now supports indirect calls to `MediaQuery.of(context)` and `MediaQuery.maybeOf(context)` ([#13](https://github.com/charlescyt/pyramid_lint/pull/13) thanks to [imsamgarg])
- `proper_controller_dispose` now supports `ChangeNotifier`'s subclasses ([#14](https://github.com/charlescyt/pyramid_lint/pull/14) thanks to [imsamgarg])
- Add quick fixes for `proper_controller_dispose` ([#15](https://github.com/charlescyt/pyramid_lint/pull/15) thanks to [imsamgarg])

### Fixed

- Fix `boolean_prefix` false positive on overridden methods ([#18](https://github.com/charlescyt/pyramid_lint/pull/18) thanks to [imsamgarg])
- Fix `prefer_async_callback` to handle cases where the type is not `void` ([#19](https://github.com/charlescyt/pyramid_lint/pull/19) thanks to [imsamgarg])

## 1.2.0 - 2023-11-24

### Added

- New lints
  - `avoid_abbreviations_in_doc_comments`
  - `doc_comments_before_annotations`
  - `prefer_library_prefixes`

### Changed

- Disable Flutter lints and assists for Dart projects.
- Improve lints' messages.
- Improve documentation.
- `prefer_dedicated_media_query_method` now supports `onOffSwitchLabels` and `textScaler`.

### Fixed

- Fix the quick fix for `prefer_void_callback`, `prefer_async_callback` and `prefer_value_changed` when the function is nullable.

## 1.1.0 - 2023-10-19

### Added

- New lints
  - `avoid_unused_parameters`
  - `prefer_async_await`
  - `prefer_new_line_before_return`
  - `unnecessary_nullable_return_type`

### Fixed

- Fix pubspec.yaml description and format ([#1](https://github.com/charlescyt/pyramid_lint/pull/1) thanks to [parlough])

## 1.0.0 - 2023-10-13

### Added

- New lints
  - `avoid_returning_widgets`
  - `boolean_prefix`

### Changed

- **BREAKING**: `avoid_empty_block` is renamed to `avoid_empty_blocks`.
- **BREAKING**: `avoid_inverted_boolean_expression` is renamed to `avoid_inverted_boolean_expressions`.
- **BREAKING**: `correct_order_for_super_dispose` is renamed to `proper_super_dispose`.
- **BREAKING**: `correct_order_for_super_init_state` is renamed to `proper_super_init_state`.
- **BREAKING**: `proper_usage_of_expanded_and_flexible` is renamed to `proper_expanded_and_flexible`.
- **BREAKING**: `proper_usage_of_from_environment` is renamed to `proper_from_environment`.
- **BREAKING**: `prefer_declaring_const_constructor` is renamed to `prefer_declaring_const_constructors`.
- **BREAKING**: `prefer_declaring_parameter_name` is renamed to `always_declare_parameter_names`.
- `proper_edge_insets_constructor` now works when arguments are variables.
- `proper_edge_insets_constructor` is no longer triggered if all the arguments are 0 in flavor of the built-in `use_named_constants`.

### Fixed

- Fix `prefer_underscore_for_unused_callback_parameters` false positive on unused parameters in function declarations.

## 0.6.0 - 2023-10-10

### Added

- New lints
  - `avoid_dynamic`
  - `prefer_async_callback`
  - `prefer_value_changed`
  - `prefer_void_callback`
  - `prefer_underscore_for_unused_callback_parameters`

## 0.5.0 - 2023-10-05

### Added

- New Assist
  - `wrap_with_layout_builder`

- New lint
  - `proper_usage_of_from_environment`

### Changed

- Assists triggered on InstanceCreationExpression are now available on `new` and `const` keywords.

### Fixed

- Fix a bug where the fix for `correct_order_for_super_dispose` is not working.

## 0.4.0 - 2023-09-26

### Added

- New lints
  - `avoid_duplicate_import`
  - `max_lines_for_file`
  - `max_lines_for_function`

## 0.3.0 - 2023-09-25

### Added

- New lints
  - `avoid_inverted_boolean_expression`

- New assists
  - `invert_boolean_expression`
  - `swap_then_else_expression`

## 0.2.0 - 2023-09-21

### Added

- New lints
  - `prefer_dedicated_media_query_method`
  - `proper_controller_dispose`
  - `proper_edge_insets_constructor`

## 0.1.1 - 2023-09-18

- Fix README.md image links.

## 0.1.0 - 2023-09-17

- Initial release.

[parlough]: https://github.com/parlough
[imsamgarg]: https://github.com/imsamgarg
