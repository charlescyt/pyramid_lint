import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;

import 'utils/typedef.dart';

@immutable
abstract class PyramidLintRule<T extends Object?> extends DartLintRule {
  PyramidLintRule({
    required String name,
    required String problemMessage,
    required String correctionMessage,
    required String url,
    required ErrorSeverity errorSeverity,
    required this.options,
  }) : super(
          code: LintCode(
            name: name,
            problemMessage: problemMessage,
            correctionMessage: correctionMessage,
            url: url,
            errorSeverity: options.severity ?? errorSeverity,
          ),
        );

  final PyramidLintRuleOptions<T> options;

  @override
  bool get enabledByDefault => false;
}

@immutable
class PyramidLintRuleOptions<T extends Object?> {
  final T params;
  final ErrorSeverity? severity;

  const PyramidLintRuleOptions({
    required this.params,
    this.severity,
  });

  factory PyramidLintRuleOptions.fromJson({
    required Json json,
    required T Function(Json json) paramsConverter,
  }) {
    final params = paramsConverter(json);
    final severity = switch (json['severity']) {
      'info' => ErrorSeverity.INFO,
      'warning' => ErrorSeverity.WARNING,
      'error' => ErrorSeverity.ERROR,
      _ => null,
    };

    return PyramidLintRuleOptions(
      params: params,
      severity: severity,
    );
  }
}
