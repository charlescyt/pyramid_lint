<p align="center">
  <img src="https://raw.githubusercontent.com/charlescyt/pyramid_lint/main/docs/assets/logo-192x192.png" alt="Pyramid Lint logo" width="96" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/pyramid_lint"><img alt="Pub Version" src="https://img.shields.io/pub/v/pyramid_lint"></a>
  <a href="https://github.com/charlescyt/pyramid_lint/actions/workflows/build.yml"><img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/charlescyt/pyramid_lint/build.yml"></a>
  <a href="https://opensource.org/licenses/MIT"><img alt="License" src="https://img.shields.io/github/license/charlescyt/pyramid_lint"></a>
</p>

<p align="center">
  <strong>Custom lints, quick fixes, and assists for Dart and Flutter.</strong>
</p>

# Pyramid Lint

[Pyramid Lint](https://pub.dev/packages/pyramid_lint) extends the Dart analyzer with optional rules for general Dart code and Flutter widgets. Enable only the checks you want, apply quick fixes from your IDE, and run the same analysis from the command line with `dart analyze` or `flutter analyze`.

Built as an [analyzer plugin](https://dart.dev/tools/analyzer-plugins) on [`analysis_server_plugin`](https://pub.dev/packages/analysis_server_plugin).

## Features

- **Lints** — Opt-in rules for Dart and Flutter (see [available lints](https://docs.page/charlescyt/pyramid_lint/available-lints)).
- **Quick fixes** — Automated corrections for many diagnostics in the IDE.
- **Assists** — Refactorings such as `wrap_with_stack` and `convert_to_for_in_iterable_indexed_loop`.

## Requirements

- **Dart** 3.10+ or **Flutter** 3.38+

## Installation

Analyzer plugins are configured in the **root** `analysis_options.yaml` of your package or workspace via the top-level `plugins` section (not the legacy `analyzer.plugins` list).

To add pyramid_lint to your project, add the following to your `analysis_options.yaml` file:

```yaml
plugins:
  pyramid_lint: ^3.0.0 # replace with the latest version
```

## Configuration

### Enable lints

All Pyramid Lint rules are **disabled by default**. Turn them on under `diagnostics`:

```yaml
plugins:
  pyramid_lint: ^3.0.0
    diagnostics:
      specific_lint_rule: true
```

Browse the full list in the [documentation](https://docs.page/charlescyt/pyramid_lint/available-lints) or copy the [recommended preset](https://docs.page/charlescyt/pyramid_lint/getting-started#lint-preset).

### Configure a lint

Some rules accept options under `options`:

```yaml
plugins:
  pyramid_lint: ^3.0.0
    diagnostics:
      max_lines_for_file: true
    options:
      max_lines_for_file:
        max_lines: 300
```

## Documentation

Full guides, rule reference, and assists: **[docs.page/charlescyt/pyramid_lint](https://docs.page/charlescyt/pyramid_lint)**

## Contributing

Contributions are welcome—issues, pull requests, and doc improvements.

See the [contributing guide](CONTRIBUTING.md) to get started.

## License

[MIT](LICENSE)
