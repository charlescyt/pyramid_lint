import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:yaml/yaml.dart' show YamlList;

import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';
import '../../utils/typedef.dart';

@immutable
class AvoidReturningWidgetsOptions {
  const AvoidReturningWidgetsOptions({
    List<String>? ignoredMethodNames,
  }) : _ignoredMethodNames = ignoredMethodNames;

  final List<String>? _ignoredMethodNames;

  List<String> get ignoredMethods => [...?_ignoredMethodNames];

  factory AvoidReturningWidgetsOptions.fromJson(Json json) {
    final ignoredMethodNames = switch (json['ignored_method_names']) {
      final YamlList ignoredMethodNames => ignoredMethodNames.cast<String>(),
      _ => null,
    };

    return AvoidReturningWidgetsOptions(
      ignoredMethodNames: ignoredMethodNames,
    );
  }
}

class AvoidReturningWidgets extends DartLintRule {
  const AvoidReturningWidgets._(this.options)
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'Returning widgets is not recommended for performance reasons.',
            correctionMessage: 'Consider creating a separate widget instead.',
            url: '$flutterLintDocUrl/${AvoidReturningWidgets.name}',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'avoid_returning_widgets';

  final AvoidReturningWidgetsOptions options;

  factory AvoidReturningWidgets.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[AvoidReturningWidgets.name]?.json ?? {};
    final options = AvoidReturningWidgetsOptions.fromJson(json);

    return AvoidReturningWidgets._(options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addMethodDeclaration((node) {
      final element = node.declaredElement;
      if (element?.enclosingElement.kind == ElementKind.EXTENSION) return;
      if (element?.hasOverride == true) return;
      if (element?.isStatic == true) return;

      final returnType = node.returnType?.type;
      if (returnType == null ||
          !widgetChecker.isAssignableFromType(returnType)) {
        return;
      }

      if (options.ignoredMethods.contains(node.name.lexeme)) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null ||
          !widgetChecker.isAssignableFromType(returnType)) {
        return;
      }

      if (options.ignoredMethods.contains(node.name.lexeme)) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
