import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';
import '../../utils/version_constraint_extension.dart';

class WrapWithListenableBuilder extends DartAssist {
  /// ListenableBuilder requires Flutter 3.10.0 which corresponds to Dart 3.0.0
  static Version minimumRequiredDartSdkVersion = Version(3, 0, 0);

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    final dartSdkVersion = context.pubspec.dartSdkVersion;
    if (dartSdkVersion == null) return;

    if (!dartSdkVersion
        .meetMinimumRequiredVersion(minimumRequiredDartSdkVersion)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = switch (node.keyword) {
        null => node.constructorName.sourceRange,
        final keyword => range.startEnd(
            keyword,
            node.constructorName,
          ),
      };
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;
      if (type == null || !widgetChecker.isSuperTypeOf(type)) return;

      SimpleIdentifier? listenableVariable;
      node.visitChildren(
        _SingleLevelChangeNotifierIdentifierVisitor(
          onVisitNotifierIdentifier: (identifier) =>
              listenableVariable = identifier,
        ),
      );

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with ListenableBuilder',
        priority: 29,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(
          node.offset,
          (builder) {
            builder.write('ListenableBuilder(');
            if (listenableVariable != null) {
              builder.write('listenable: ${listenableVariable!.name},');
            }
            builder.write('builder: (context, child) { return ');
          },
        );

        builder.addSimpleInsertion(node.end, '; },)');
      });
    });
  }
}

class _SingleLevelChangeNotifierIdentifierVisitor
    extends RecursiveAstVisitor<void> {
  const _SingleLevelChangeNotifierIdentifierVisitor({
    required this.onVisitNotifierIdentifier,
  });

  final void Function(SimpleIdentifier node) onVisitNotifierIdentifier;

  @override
  void visitNamedExpression(NamedExpression node) {
    // We only want to traverse the current node not the node's child subtree
    if (node.name.label.name == 'child' &&
        node.expression is InstanceCreationExpression) {
      return;
    }

    node.visitChildren(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.staticType != null &&
        changeNotifierChecker.isAssignableFromType(node.staticType!)) {
      onVisitNotifierIdentifier(node);
      return;
    }

    node.visitChildren(this);
  }
}
