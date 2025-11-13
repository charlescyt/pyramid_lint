import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/iterable_extension.dart';

class NoDuplicateImports extends PyramidLintRule {
  NoDuplicateImports({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'Duplicate imports can lead to confusion.',
        correctionMessage: 'Consider combining or removing the duplicate imports.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'no_duplicate_imports';
  static const url = '$dartLintDocUrl/$ruleName';

  factory NoDuplicateImports.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return NoDuplicateImports(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final importDirectives = node.directives.whereType<ImportDirective>();
      final duplicateUrls = importDirectives.map((e) => e.uri.stringValue).nonNulls.duplicates;

      for (final importDirective in importDirectives) {
        final url = importDirective.uri.stringValue;
        if (duplicateUrls.contains(url)) {
          reporter.atNode(importDirective.uri, code);
        }
      }
    });
  }
}
