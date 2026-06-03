/// Custom lints, quick fixes, and assists for Dart and Flutter.
///
/// Add to the root `analysis_options.yaml` under `plugins` (rules are off by
/// default—enable them under `diagnostics`):
///
/// ```yaml
/// plugins:
///   pyramid_lint: ^3.0.0 # replace with the latest version
///     diagnostics:
///       specific_lint_rule: true
/// ```
///
/// See the [docs](https://docs.page/charlescyt/pyramid_lint) for the rule list,
/// presets, and per-rule `options`.
library;

import 'package:analysis_server_plugin/plugin.dart';

import 'src/plugin.dart';

/// This is the entry point for the Dart Analysis Server to load the Pyramid Lint plugin.
final Plugin plugin = PyramidLintPlugin();
