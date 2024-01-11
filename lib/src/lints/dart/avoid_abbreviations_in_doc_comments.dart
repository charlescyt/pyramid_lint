import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

const _defaultAbbreviations = [
  'e.g.',
  'i.e.',
  'etc.',
  'et al.',
];

class AvoidAbbreviationsInDocComments extends DartLintRule {
  const AvoidAbbreviationsInDocComments._({
    this.abbreviations = const {},
  }) : super(code: _code);

  static const name = 'avoid_abbreviations_in_doc_comments';

  static const _code = LintCode(
    name: name,
    problemMessage:
        'Avoid using abbreviations in doc comments as they can hinder '
        'readability and cause confusion.',
    correctionMessage: 'Consider using the full word instead.',
    url: '$dartLintDocUrl/${AvoidAbbreviationsInDocComments.name}',
    errorSeverity: ErrorSeverity.WARNING,
  );

  final Set<String> abbreviations;

  factory AvoidAbbreviationsInDocComments.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final options = configs.rules[AvoidAbbreviationsInDocComments.name];
    final customAbbreviations =
        (options?.json['abbreviations'] as List<Object?>?)?.cast<String>();
    final abbreviations = {..._defaultAbbreviations, ...?customAbbreviations};

    return AvoidAbbreviationsInDocComments._(abbreviations: abbreviations);
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

        for (final abbreviation in abbreviations) {
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
