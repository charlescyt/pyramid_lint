import 'package:analyzer/analysis_rule/rule_context.dart';
// ignore: implementation_imports
import 'package:analyzer/src/utilities/extensions/file_system.dart';
import 'package:yaml/yaml.dart';

/// The pub package name of this analyzer plugin.
const String pluginPackageName = 'pyramid_lint';

/// Reads per-rule options from the root `analysis_options.yaml` for [ruleName].
///
/// Expected shape:
///
/// ```yaml
/// plugins:
///   pyramid_lint: <version>
///     options:
///       my_rule:
///         some_option: true
/// ```
Map<String, Object?> readPluginRuleOptions(RuleContext context, String ruleName) {
  final optionsFile = context.package?.root.findAnalysisOptionsYamlFile();
  if (optionsFile == null) return const {};

  final document = loadYaml(optionsFile.readAsStringSync());
  if (document is! YamlMap) return const {};

  final plugins = document.value['plugins'];
  if (plugins is! YamlMap) return const {};

  final plugin = plugins.value[pluginPackageName];
  if (plugin is! YamlMap) return const {};

  final options = plugin.value['options'];
  if (options is! YamlMap) return const {};

  final ruleOptions = options.value[ruleName];
  if (ruleOptions is! YamlMap) return const {};

  return Map.unmodifiable(
    ruleOptions.map((key, value) => MapEntry('$key', value)),
  );
}
