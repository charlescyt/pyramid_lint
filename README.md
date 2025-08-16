<p align="center">
  <img src="https://raw.githubusercontent.com/charlescyt/pyramid_lint/main/docs/assets/logo-192x192.png" alt="logo" />
</p>

<p align="center">
<a href="https://pub.dev/packages/pyramid_lint"><img alt="Pub Version" src="https://img.shields.io/pub/v/pyramid_lint"></a>
<a href="https://github.com/charlescyt/pyramid_lint/actions/workflows/build.yml"><img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/charlescyt/pyramid_lint/build.yml"></a>
<a href="https://opensource.org/licenses/MIT>"><img alt="GitHub License" src="https://img.shields.io/github/license/charlescyt/pyramid_lint"></a>
</p>

<p align="center">
<strong>Linting tool for Dart and Flutter projects.</strong>
</p>

# Pyramid Lint

Pyramid Lint is a linting tool for Dart and Flutter projects. It provides a set of additional lints and quick fixes to help developers identify issues within their Dart code, offers suggestions for potential fixes, and enforces consistent coding styles.

Pyramid Lint is built with [custom_lint][custom_lint].

## Quick Start

Run the following command to add `custom_lint` and `pyramid_lint` to your project's dev dependencies:

```sh
dart pub add dev:custom_lint dev:pyramid_lint
```

Then enable `custom_lint` in your `analysis_options.yaml` file.

```yaml
analyzer:
  plugins:
    - custom_lint
```

By default, all lints are disabled. To enable a specific lint, add the following to your `analysis_options.yaml` file:

```yaml
custom_lint:
  rules:
    - specific_lint_rule # enable specific_lint_rule
```

A list of all available lints can be found [here][available-lints].

A [lint preset][lint-preset] is available to help you get started.

For more information, please visit the [documentation][documentation].

## Contributing

Contributions are appreciated! You can contribute by:

- Creating an issue to report a bug or suggest a new feature.
- Submitting a pull request to fix a bug or implement a new feature.
- Improving the documentation.

To get started contributing to Pyramid Lint, please refer to the [Contributing guide][contributing].

## License

Pyramid Lint is licensed under the [MIT License][license].

<!-- Links -->

[custom_lint]: https://pub.dev/packages/custom_lint
[documentation]: https://docs.page/charlescyt/pyramid_lint
[available-lints]: https://docs.page/charlescyt/pyramid_lint/available-lints
[lint-preset]: https://docs.page/charlescyt/pyramid_lint/getting-started#lint-preset
[contributing]: https://github.com/charlescyt/pyramid_lint/blob/main/CONTRIBUTING.md
[license]: https://github.com/charlescyt/pyramid_lint/blob/main/LICENSE
