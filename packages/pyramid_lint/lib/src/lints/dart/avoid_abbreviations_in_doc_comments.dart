import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:yaml/yaml.dart' show YamlList;

import '../../utils/constants.dart';
import '../../utils/typedef.dart';

@immutable
class AvoidAbbreviationsInDocCommentsOptions {
  const AvoidAbbreviationsInDocCommentsOptions({
    List<String>? abbreviations,
  }) : _abbreviations = abbreviations;

  static const defaultAbbreviations = [
    'e.g.',
    'i.e.',
    'etc.',
    'et al.',
  ];

  final List<String>? _abbreviations;

  List<String> get abbreviations => [
        ...defaultAbbreviations,
        ...?_abbreviations,
      ];

  factory AvoidAbbreviationsInDocCommentsOptions.fromJson(Json json) {
    final abbreviations = switch (json['abbreviations']) {
      final YamlList abbreviations => abbreviations.cast<String>(),
      _ => null,
    };

    return AvoidAbbreviationsInDocCommentsOptions(
      abbreviations: abbreviations,
    );
  }
}

class AvoidAbbreviationsInDocComments extends DartLintRule {
  const AvoidAbbreviationsInDocComments._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'Avoid using abbreviations in doc comments as they can hinder '
                'readability and cause confusion.',
            correctionMessage: 'Consider using the full word instead.',
            url: url,
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const name = 'avoid_abbreviations_in_doc_comments';
  static const url = '$dartLintDocUrl/$name';

  final AvoidAbbreviationsInDocCommentsOptions options;

  factory AvoidAbbreviationsInDocComments.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[name]?.json ?? {};
    final options = AvoidAbbreviationsInDocCommentsOptions.fromJson(json);

    return AvoidAbbreviationsInDocComments._(options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addComment((node) {
      final comments = node.tokens;

      for (final comment in comments) {
        final commentText = comment.lexeme;

        for (final abbreviation in options.abbreviations) {
          if (!commentText.contains(abbreviation)) continue;

          final index = commentText.indexOf(abbreviation);

          reporter.reportErrorForOffset(
            code,
            comment.offset + index,
            abbreviation.length,
          );
        }
      }
    });
  }
}
