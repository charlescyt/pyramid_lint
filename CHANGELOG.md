# Changelog

## [Unreleased]

## [1.0.0] - 2023-10-12

### Added

- New lint
  - `boolean_prefix`

### Changed

- **BREAKING**: `proper_usage_of_from_environment` is renamed to `proper_from_environment`.
- **BREAKING**: `proper_usage_of_expanded_and_flexible` is renamed to `proper_expanded_and_flexible`.
- **BREAKING**: `correct_order_for_super_init_state` is renamed to `proper_super_init_state`.
- **BREAKING**: `correct_order_for_super_dispose` is renamed to `proper_super_dispose`.
- **BREAKING**: `prefer_declaring_parameter_name` is renamed to `always_declare_parameter_names`.
- **BREAKING**: `avoid_inverted_boolean_expression` is renamed to `avoid_inverted_boolean_expressions`.
- **BREAKING**: `avoid_empty_block` is renamed to `avoid_empty_blocks`.
- **BREAKING**: `prefer_declaring_const_constructor` is renamed to `prefer_declaring_const_constructors`.
- `proper_edge_insets_constructor` now works when arguments are variables.
- `proper_edge_insets_constructor` is no longer triggered if all the arguments are 0 in flavor of the built-in `use_named_constants`.

### Fixed

- Fix `prefer_underscore_for_unused_callback_parameters` false positive on unused parameters in function declarations.

## [0.6.0] - 2023-10-10

### Added

- New lints
  - `avoid_dynamic`
  - `prefer_async_callback`
  - `prefer_value_changed`
  - `prefer_void_callback`
  - `prefer_underscore_for_unused_callback_parameters`

## [0.5.0] - 2023-10-05

### Added

- New Assist
  - `wrap_with_layout_builder`

- New lint
  - `proper_usage_of_from_environment`

### Changed

- Assists triggered on InstanceCreationExpression are now available on `new` and `const` keywords.

### Fixed

- Fix a bug where the fix for `correct_order_for_super_dispose` is not working.

## [0.4.0] - 2023-09-26

### Added

- New lints
  - `avoid_duplicate_import`
  - `max_lines_for_file`
  - `max_lines_for_function`

## [0.3.0] - 2023-09-25

### Added

- New lints
  - `avoid_inverted_boolean_expression`

- New assists
  - `invert_boolean_expression`
  - `swap_then_else_expression`

## [0.2.0] - 2023-09-21

### Added

- New lints
  - `prefer_dedicated_media_query_method`
  - `proper_controller_dispose`
  - `proper_edge_insets_constructor`

## [0.1.1] - 2023-09-18

- Fix README.md image links.

## [0.1.0] - 2023-09-17

- Initial release.
