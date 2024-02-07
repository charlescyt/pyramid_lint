import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class WrapWithValueListenableBuilder extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.keywordAndConstructorNameSourceRange;
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;
      if (type == null || !widgetChecker.isSuperTypeOf(type)) return;

      SimpleIdentifier? listenableVariable;
      node.visitChildren(
        _SingleLevelValueNotifierIdentifierVisitor(
          onVisitNotifierIdentifier: (identifier) =>
              listenableVariable = identifier,
        ),
      );

      if (listenableVariable == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with ValueListenableBuilder',
        priority: 29,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(
          node.offset,
          (builder) {
            builder.write('ValueListenableBuilder(');
            builder.write('valueListenable: ${listenableVariable!.name},');
            builder.write('builder: (context, value, child) { return ');
          },
        );

        builder.addSimpleInsertion(node.end, '; },)');
      });
    });
  }
}

class _SingleLevelValueNotifierIdentifierVisitor
    extends RecursiveAstVisitor<void> {
  const _SingleLevelValueNotifierIdentifierVisitor({
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
        valueNotifierChecker.isAssignableFromType(node.staticType!)) {
      onVisitNotifierIdentifier(node);
      return;
    }

    node.visitChildren(this);
  }
}
