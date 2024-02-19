import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidRecordPositionalFieldGetters extends PyramidLintRule {
  AvoidRecordPositionalFieldGetters({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'Using positional field getters decreases readability.',
          correctionMessage: 'Consider using named field getters instead.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'avoid_record_positional_field_getters';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidRecordPositionalFieldGetters.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return AvoidRecordPositionalFieldGetters(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
      final targetType = node.realTarget.staticType;
      if (targetType is! RecordType) return;

      final propertyName = node.propertyName.name;
      if (!propertyName.startsWith(r'$')) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
