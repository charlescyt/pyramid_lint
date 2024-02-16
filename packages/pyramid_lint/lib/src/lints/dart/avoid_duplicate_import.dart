import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';
import '../../utils/iterable_extension.dart';

class AvoidDuplicateImport extends DartLintRule {
  const AvoidDuplicateImport()
      : super(
          code: const LintCode(
            name: name,
            problemMessage: 'Duplicate imports can lead to confusion.',
            correctionMessage:
                'Consider combining or removing the duplicate imports.',
            url: url,
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const name = 'avoid_duplicate_import';
  static const url = '$dartLintDocUrl/$name';

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
