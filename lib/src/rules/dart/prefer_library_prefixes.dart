import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:meta/meta.dart' show immutable;

import '../../utils/rule_options.dart';

@immutable
class PreferLibraryPrefixesOptions {
  final List<String> libraries;

  const PreferLibraryPrefixesOptions({List<String>? libraries}) : libraries = libraries ?? const [];

  factory PreferLibraryPrefixesOptions.fromMap(Map<String, Object?> map) {
    final libraries = switch (map['libraries']) {
      final List<Object?> libraries => libraries.whereType<String>().toList(),
      _ => const <String>[],
    };

    return PreferLibraryPrefixesOptions(libraries: libraries);
  }

  factory PreferLibraryPrefixesOptions.fromRuleContext(RuleContext context) {
    final map = readPluginRuleOptions(context, PreferLibraryPrefixesRule.code.lowerCaseName);
    return PreferLibraryPrefixesOptions.fromMap(map);
  }
}

class PreferLibraryPrefixesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_library_prefixes',
    'Prefix should be used for this library.',
    correctionMessage: 'Consider adding a prefix to this library.',
    severity: DiagnosticSeverity.INFO,
  );

  PreferLibraryPrefixesRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final options = PreferLibraryPrefixesOptions.fromRuleContext(context);
    final visitor = _Visitor(this, context, options);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  final PreferLibraryPrefixesOptions options;

  const _Visitor(this.rule, this.context, this.options);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    if (!options.libraries.contains(uri)) return;

    if (node.prefix != null) return;

    rule.reportAtNode(node);
  }
}

class AddLibraryPrefix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.addLibraryPrefix',
    DartFixKindPriority.standard,
    'Add prefix to the library',
  );

  AddLibraryPrefix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final importDirective = node;
    if (importDirective is! ImportDirective) return;

    final uri = importDirective.uri.stringValue;
    if (uri == null) return;

    final uriSegments = uri.split(RegExp('[/:]'));
    if (uriSegments.isEmpty) return;

    final lastUriSegment = uriSegments.last.replaceAll('.dart', '');

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(importDirective.uri.end, ' as $lastUriSegment');
    });
  }
}
