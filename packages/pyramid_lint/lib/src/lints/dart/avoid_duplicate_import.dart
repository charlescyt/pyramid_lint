import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/iterable_extension.dart';

class AvoidDuplicateImport extends PyramidLintRule {
  AvoidDuplicateImport({required super.options})
      : super(
          name: name,
          problemMessage: 'Duplicate imports can lead to confusion.',
          correctionMessage:
              'Consider combining or removing the duplicate imports.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const name = 'avoid_duplicate_import';
  static const url = '$dartLintDocUrl/$name';

  factory AvoidDuplicateImport.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidDuplicateImport(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final importDirectives = node.directives.whereType<ImportDirective>();
      final duplicateUrls =
          importDirectives.map((e) => e.uri.stringValue).nonNulls.duplicates;

      for (final importDirective in importDirectives) {
        final url = importDirective.uri.stringValue;
        if (duplicateUrls.contains(url)) {
          reporter.reportErrorForNode(code, importDirective.uri);
        }
      }
    });
  }
}
