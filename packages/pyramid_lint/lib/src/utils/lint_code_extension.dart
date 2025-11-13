import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:custom_lint_builder/custom_lint_builder.dart';

extension LintCodeExtension on LintCode {
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    DiagnosticSeverity? errorSeverity,
  }) {
    return LintCode(
      name: name ?? this.name,
      problemMessage: problemMessage ?? this.problemMessage,
      correctionMessage: correctionMessage ?? this.correctionMessage,
      uniqueName: uniqueName ?? this.uniqueName,
      url: url ?? this.url,
      errorSeverity: errorSeverity ?? this.errorSeverity,
    );
  }
}
