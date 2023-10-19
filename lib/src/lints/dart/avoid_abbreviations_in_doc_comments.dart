import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

final _defaultAbbreviations = [
  'e.g.',
  'i.e.',
  'etc.',
  'et al.',
];

class AvoidAbbreviationsInDocComments extends DartLintRule {
  const AvoidAbbreviationsInDocComments({
    this.abbreviations = const [],
  }) : super(code: _code);

  static const name = 'avoid_abbreviations_in_doc_comments';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Using abbreviations in doc comments can be confusing.',
    correctionMessage: 'Try using the full word instead.',
    url: '$docUrl#${AvoidAbbreviationsInDocComments.name}',
    errorSeverity: ErrorSeverity.WARNING,
  );

  final List<String> abbreviations;

  factory AvoidAbbreviationsInDocComments.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final options = configs.rules[AvoidAbbreviationsInDocComments.name];
    final jsonList = options?.json['abbreviations'] as List<Object?>?;
    final abbreviations = jsonList?.cast<String>() ?? [];

    return AvoidAbbreviationsInDocComments(
      abbreviations: [..._defaultAbbreviations, ...abbreviations],
    );
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
