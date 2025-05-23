import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:yaml/yaml.dart' show YamlList;

import '../../pyramid_lint_rule.dart';
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

class AvoidAbbreviationsInDocComments
    extends PyramidLintRule<AvoidAbbreviationsInDocCommentsOptions> {
  AvoidAbbreviationsInDocComments({required super.options})
    : super(
        name: ruleName,
        problemMessage:
            'Avoid using abbreviations in doc comments as they can hinder '
            'readability and cause confusion.',
        correctionMessage: 'Consider using the full word instead.',
        url: url,
        errorSeverity: ErrorSeverity.WARNING,
      );

  static const ruleName = 'avoid_abbreviations_in_doc_comments';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidAbbreviationsInDocComments.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: AvoidAbbreviationsInDocCommentsOptions.fromJson,
    );

    return AvoidAbbreviationsInDocComments(options: options);
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

        for (final abbreviation in options.params.abbreviations) {
          if (!commentText.contains(abbreviation)) continue;

          final index = commentText.indexOf(abbreviation);

          reporter.atOffset(
            offset: comment.offset + index,
            length: abbreviation.length,
            errorCode: code,
          );
        }
      }
    });
  }
}
