# Changelog

## [Unreleased]

### Added

- Assist: `convert_to_for_in_iterable_indexed_loop`.
- Lint: `specify_icon_button_tooltip`.

## [2.0.3] - 2024-03-15

### Changed

- Bump the minimum `analyzer_plugin` version to 0.13.0. ([#52](https://github.com/charlescyt/pyramid_lint/pull/52) thanks to [jogboms])

## [2.0.2] - 2024-02-05

### Changed

- Require Dart 3.6.0.
- Bump the minimum `analyzer` version to 7.0.0.
- Bump the minimum `custom_lint_builder` version to 0.7.0.
- Bump the minimum `pubspec_parse` version to 1.4.0.

## [2.0.1] - 2024-08-16

### Changed

- Bump the minimum `analyzer` version to 6.6.0.
- Bump the minimum `custom_lint_builder` version to 0.6.5.
- `avoid_public_members_in_states` now ignores public fields and methods with `@visibleForTesting` annotations.

### Fixed

- Fix false positive for `dispose_controllers` when dispose is already called via [cascade notation](https://dart.dev/language/operators#cascade-notation).

## [2.0.0] - 2024-03-06

### Added

- Add support for changing the lint severity. ([#38](https://github.com/charlescyt/pyramid_lint/pull/38))
- Lint: `avoid_mutable_global_variables` ([#37](https://github.com/charlescyt/pyramid_lint/pull/37))
- Lint: `avoid_redundant_pattern_field_names` ([#40](https://github.com/charlescyt/pyramid_lint/pull/40))
- Lint: `avoid_positional_fields_in_records` ([#41](https://github.com/charlescyt/pyramid_lint/pull/41))
- Lint: `class_members_ordering` ([#42](https://github.com/charlescyt/pyramid_lint/pull/42))
- Assist: `wrap_with_listenable_builder` ([#26](https://github.com/charlescyt/pyramid_lint/pull/26)) thanks to [imsamgarg])

### Changed

- **BREAKING**: All lints are now disabled by default. To enable a specific lint, add the lint in the `analysis_options.yaml` file. ([#39](https://github.com/charlescyt/pyramid_lint/pull/39))
- **BREAKING**: `avoid_duplicate_import` has been renamed to `no_duplicate_imports`.
- **BREAKING**: `prefer_declaring_const_constructors` has been renamed to `prefer_const_constructor_declarations`.
- **BREAKING**: `doc_comments_before_annotations` has been renamed to `always_put_doc_comments_before_annotations`.
- **BREAKING**: `boolean_prefix` has been renamed to `boolean_prefixes`.
- **BREAKING**: `always_declare_parameter_names` has been renamed to `always_specify_parameter_names`.
- **BREAKING**: `prefer_spacer` has been renamed to `use_spacer`.
- **BREAKING**: `proper_controller_dispose` has been renamed to `dispose_controllers`.
- **BREAKING**: `avoid_widget_state_public_members` has been renamed to `avoid_public_members_in_states`.
- **BREAKING**: `proper_edge_insets_constructor` has been renamed to `proper_edge_insets_constructors`.
- **BREAKING**: `prefer_dedicated_media_query_method` has been renamed to `prefer_dedicated_media_query_functions`.
- Bump the minimum `custom_lint_builder` version to 0.6.2.
- Fix false positive for `avoid_nested_if` when the if statement is a else if statement. ([#44](https://github.com/charlescyt/pyramid_lint/pull/44))

### Removed

- **BREAKING**: Remove `prefer_value_changed` lint. ([#45](https://github.com/charlescyt/pyramid_lint/pull/45))

## [1.5.0] - 2024-02-14

### Added

- Lint: `prefer_iterable_any` ([#36](https://github.com/charlescyt/pyramid_lint/pull/36))
- Lint: `prefer_iterable_every` ([#36](https://github.com/charlescyt/pyramid_lint/pull/36))

### Changed

- `wrap_with_layout_builder` will not be available if the selected widget is a `LayoutBuilder` or already wrapped with a `LayoutBuilder`. ([#35](https://github.com/charlescyt/pyramid_lint/pull/35))

## [1.4.0] - 2024-02-07

### Added

- Lint: `avoid_nested_if` ([#25](https://github.com/charlescyt/pyramid_lint/pull/25))
- Lint: `max_switch_cases` ([#30](https://github.com/charlescyt/pyramid_lint/pull/30))
- Assist: `wrap_all_children_with_expanded` ([#27](https://github.com/charlescyt/pyramid_lint/pull/27))

### Changed

- `avoid_returning_widgets` now ignores static, overridden and extension methods and supports `ignored_method_names` option. ([#24](https://github.com/charlescyt/pyramid_lint/pull/24) [#28](https://github.com/charlescyt/pyramid_lint/pull/28))
- Bump the minimum custom lint version to 0.6.0.

### Fixed

- Fix false positive for `prefer_declaring_const_constructors` when redirecting/super constructor is not a const constructor. ([#29](https://github.com/charlescyt/pyramid_lint/pull/29))
- Fix incorrect quick fix for `prefer_iterable_first` and `prefer_iterable_last` on 2D list. ([#33](https://github.com/charlescyt/pyramid_lint/pull/33))

## [1.3.0] - 2024-01-15

### Added

- Lint: `no_self_comparisons` ([#9](https://github.com/charlescyt/pyramid_lint/pull/9))
- Lint: `avoid_widget_state_public_members` ([#10](https://github.com/charlescyt/pyramid_lint/pull/10))
- Assist: `wrap_with_value_listenable_builder` ([#16](https://github.com/charlescyt/pyramid_lint/pull/13) thanks to [imsamgarg])

### Changed

- `prefer_dedicated_media_query_method` now supports indirect calls to `MediaQuery.of(context)` and `MediaQuery.maybeOf(context)` ([#13](https://github.com/charlescyt/pyramid_lint/pull/13) thanks to [imsamgarg])
- `proper_controller_dispose` now supports `ChangeNotifier`'s subclasses ([#14](https://github.com/charlescyt/pyramid_lint/pull/14) thanks to [imsamgarg])
- Add quick fixes for `proper_controller_dispose` ([#15](https://github.com/charlescyt/pyramid_lint/pull/15) thanks to [imsamgarg])

### Fixed

- Fix `boolean_prefix` false positive on overridden methods ([#18](https://github.com/charlescyt/pyramid_lint/pull/18) thanks to [imsamgarg])
- Fix `prefer_async_callback` to handle cases where the type is not `void` ([#19](https://github.com/charlescyt/pyramid_lint/pull/19) thanks to [imsamgarg])

## [1.2.0] - 2023-11-24

### Added

- Lint: `avoid_abbreviations_in_doc_comments`
- Lint: `doc_comments_before_annotations`
- Lint: `prefer_library_prefixes`

### Changed

- Disable Flutter lints and assists for Dart projects.
- Improve lints' messages.
- Improve documentation.
- `prefer_dedicated_media_query_method` now supports `onOffSwitchLabels` and `textScaler`.

### Fixed

- Fix the quick fix for `prefer_void_callback`, `prefer_async_callback` and `prefer_value_changed` when the function is nullable.

## [1.1.0] - 2023-10-19

### Added

- Lint: `avoid_unused_parameters`
- Lint: `prefer_async_await`
- Lint: `prefer_new_line_before_return`
- Lint: `unnecessary_nullable_return_type`

### Fixed

- Fix pubspec.yaml description and format ([#1](https://github.com/charlescyt/pyramid_lint/pull/1) thanks to [parlough])

## [1.0.0] - 2023-10-13

### Added

- Lint: `avoid_returning_widgets`
- Lint: `boolean_prefix`

### Changed

- **BREAKING**: `avoid_empty_block` has been renamed to `avoid_empty_blocks`.
- **BREAKING**: `avoid_inverted_boolean_expression` has been renamed to `avoid_inverted_boolean_expressions`.
- **BREAKING**: `correct_order_for_super_dispose` has been renamed to `proper_super_dispose`.
- **BREAKING**: `correct_order_for_super_init_state` has been renamed to `proper_super_init_state`.
- **BREAKING**: `proper_usage_of_expanded_and_flexible` has been renamed to `proper_expanded_and_flexible`.
- **BREAKING**: `proper_usage_of_from_environment` has been renamed to `proper_from_environment`.
- **BREAKING**: `prefer_declaring_const_constructor` has been renamed to `prefer_declaring_const_constructors`.
- **BREAKING**: `prefer_declaring_parameter_name` has been renamed to `always_declare_parameter_names`.
- `proper_edge_insets_constructor` now works when arguments are variables.
- `proper_edge_insets_constructor` is no longer triggered if all the arguments are 0 in flavor of the built-in `use_named_constants`.

### Fixed

- Fix `prefer_underscore_for_unused_callback_parameters` false positive on unused parameters in function declarations.

## [0.6.0] - 2023-10-10

### Added

- Lint: `avoid_dynamic`
- Lint: `prefer_async_callback`
- Lint: `prefer_value_changed`
- Lint: `prefer_void_callback`
- Lint: `prefer_underscore_for_unused_callback_parameters`

## [0.5.0] - 2023-10-05

### Added

- Lint: `proper_usage_of_from_environment`
- Assist: `wrap_with_layout_builder`

### Changed

- Assists triggered on InstanceCreationExpression are now available on `new` and `const` keywords.

### Fixed

- Fix a bug where the fix for `correct_order_for_super_dispose` is not working.

## [0.4.0] - 2023-09-26

### Added

- Lint: `avoid_duplicate_import`
- Lint: `max_lines_for_file`
- Lint: `max_lines_for_function`

## [0.3.0] - 2023-09-25

### Added

- Lint: `avoid_inverted_boolean_expression`
- Assist: `invert_boolean_expression`
- Assist: `swap_then_else_expression`

## [0.2.0] - 2023-09-21

### Added

- Lint: `prefer_dedicated_media_query_method`
- Lint: `proper_controller_dispose`
- Lint: `proper_edge_insets_constructor`

## [0.1.1] - 2023-09-18

### Fixed

- README.md image links.

## [0.1.0] - 2023-09-17

- Initial release.

[parlough]: https://github.com/parlough
[imsamgarg]: https://github.com/imsamgarg
[jogboms]: https://github.com/jogboms

[Unreleased]: https://github.com/charlescyt/pyramid_lint/compare/v2.0.3...HEAD
[2.0.3]: https://github.com/charlescyt/pyramid_lint/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/charlescyt/pyramid_lint/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/charlescyt/pyramid_lint/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.5.0...v2.0.0
[1.5.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/charlescyt/pyramid_lint/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.6.0...v1.0.0
[0.6.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/charlescyt/pyramid_lint/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/charlescyt/pyramid_lint/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/charlescyt/pyramid_lint/releases/tag/v0.1.0
