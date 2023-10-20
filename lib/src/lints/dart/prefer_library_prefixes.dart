import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

final _defaultLibraries = [
  'dart:developer',
  'dart:math',
];

class PreferLibraryPrefixes extends DartLintRule {
  const PreferLibraryPrefixes({
    this.libraries = const {},
  }) : super(code: _code);

  static const name = 'prefer_library_prefixes';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Prefix should be used for this library.',
    correctionMessage: 'Try adding a prefix to this library.',
    url: '$docUrl#${PreferLibraryPrefixes.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  final Set<String> libraries;

  factory PreferLibraryPrefixes.fromConfigs(CustomLintConfigs configs) {
    final options = configs.rules[PreferLibraryPrefixes.name];
    final includeDefaultLibraries =
        options?.json['include_default_libraries'] as bool? ?? true;
    final customLibraries =
        (options?.json['libraries'] as List<Object?>?)?.cast<String>();
    final libraries = {
      if (includeDefaultLibraries) ..._defaultLibraries,
      ...?customLibraries,
    };

    return PreferLibraryPrefixes(libraries: libraries);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;
      if (uri == null) return;

      if (!libraries.contains(uri)) return;

      final prefix = node.prefix;
      if (prefix != null) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_AddPrefix()];
}

class _AddPrefix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addImportDirective((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final uri = node.uri.stringValue;
      if (uri == null) return;

      final uriSegments = uri.split(RegExp('[/:]'));
      if (uriSegments.isEmpty) return;

      final lastUriSegment = uriSegments.last.replaceAll('.dart', '');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add prefix to the library',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(
          node.uri.end,
          ' as $lastUriSegment',
        );
      });
    });
  }
}
