import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/argument_list_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/type_checker.dart';
import '../../utils/utils.dart';

class ProperEdgeInsetsConstructor extends DartLintRule {
  const ProperEdgeInsetsConstructor() : super(code: _code);

  static const name = 'proper_edge_insets_constructor';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Using incorrect EdgeInsets constructor and arguments.',
    correctionMessage: 'Replace with {0}.',
    url: '$docUrl#${ProperEdgeInsetsConstructor.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !edgeInsetsChecker.isExactlyType(type)) return;

      final constructorName = node.constructorName.name?.name;

      switch (constructorName) {
        case 'fromLTRB':
          handleFromLTRB(node: node, reporter: reporter);
        case 'only':
          handleOnly(node: node, reporter: reporter);
        case 'symmetric':
          handleSymmetric(node: node, reporter: reporter);
        case _:
          return;
      }
    });
  }

  void handleFromLTRB({
    required InstanceCreationExpression node,
    required ErrorReporter reporter,
  }) {
    final arguments = node.argumentList.positionalArguments.toList();
    if (arguments.length != 4) return;

    final left = arguments[0];
    final top = arguments[1];
    final right = arguments[2];
    final bottom = arguments[3];

    switch ((left: left, top: top, right: right, bottom: bottom)) {
      case (
          left: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
          top: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
          right: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
          bottom: IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
        ):
        return;
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l.toSource() == t.toSource() &&
              t.toSource() == r.toSource() &&
              r.toSource() == b.toSource():
        reporter.reportErrorForNode(
          code,
          node,
          ['EdgeInsets.all(${l.toSource()})'],
        );
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l.toSource() == r.toSource() && t.toSource() == b.toSource():
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.symmetric(${[
              if (!isZeroExpression(l)) 'horizontal: ${l.toSource()}',
              if (!isZeroExpression(t)) 'vertical: ${t.toSource()}',
            ].join(', ')})',
          ],
        );
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when [l, t, r, b].any(isZeroExpression):
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.only(${[
              if (!isZeroExpression(l)) 'left: ${l.toSource()}',
              if (!isZeroExpression(t)) 'top: ${t.toSource()}',
              if (!isZeroExpression(r)) 'right: ${r.toSource()}',
              if (!isZeroExpression(b)) 'bottom: ${b.toSource()}',
            ].join(', ')})',
          ],
        );
    }
  }

  void handleOnly({
    required InstanceCreationExpression node,
    required ErrorReporter reporter,
  }) {
    final left = node.argumentList.findArgumentByName('left')?.expression;
    final top = node.argumentList.findArgumentByName('top')?.expression;
    final right = node.argumentList.findArgumentByName('right')?.expression;
    final bottom = node.argumentList.findArgumentByName('bottom')?.expression;

    switch ((left: left, top: top, right: right, bottom: bottom)) {
      case (
          left: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          top: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          right: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          bottom: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
        ):
        return;
      case (
            left: final l?,
            top: final t?,
            right: final r?,
            bottom: final b?,
          )
          when l.toSource() == r.toSource() &&
              r.toSource() == b.toSource() &&
              t.toSource() == b.toSource():
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.all(${l.toSource()})',
          ],
        );
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l?.toSource() == r?.toSource() && t?.toSource() == b?.toSource():
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.symmetric(${[
              if (l != null && !isZeroExpression(l))
                'horizontal: ${l.toSource()}',
              if (t != null && !isZeroExpression(t))
                'vertical: ${t.toSource()}',
            ].join(', ')})',
          ],
        );
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when [l, t, r, b].any(
            (e) =>
                (e is IntegerLiteral && e.value == 0) ||
                (e is DoubleLiteral && e.value == 0.0),
          ):
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.only(${[
              if (l is IntegerLiteral && l.value != 0 ||
                  l is DoubleLiteral && l.value != 0.0)
                'left: ${l?.toSource()}',
              if (t is IntegerLiteral && t.value != 0 ||
                  t is DoubleLiteral && t.value != 0.0)
                'top: ${t?.toSource()}',
              if (r is IntegerLiteral && r.value != 0 ||
                  r is DoubleLiteral && r.value != 0.0)
                'right: ${r?.toSource()}',
              if (b is IntegerLiteral && b.value != 0 ||
                  b is DoubleLiteral && b.value != 0.0)
                'bottom: ${b?.toSource()}',
            ].join(', ')})',
          ],
        );
      case (
          left: final l?,
          top: final t?,
          right: final r?,
          bottom: final b?,
        ):
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.fromLTRB(${[
              l.toSource(),
              t.toSource(),
              r.toSource(),
              b.toSource(),
            ].join(', ')})'
          ],
        );
    }
  }

  void handleSymmetric({
    required InstanceCreationExpression node,
    required ErrorReporter reporter,
  }) {
    final vertical =
        node.argumentList.findArgumentByName('vertical')?.expression;
    final horizontal =
        node.argumentList.findArgumentByName('horizontal')?.expression;

    switch ((vertical: vertical, horizontal: horizontal)) {
      case (
          vertical:
              null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
          horizontal:
              null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
        ):
        return;
      case (
            vertical: final v?,
            horizontal: final h?,
          )
          when v.toSource() == h.toSource():
        reporter.reportErrorForNode(
          code,
          node,
          ['EdgeInsets.all(${v.toSource()})'],
        );
      case (
            vertical: final v?,
            horizontal: final h?,
          )
          when [v, h].any(isZeroExpression):
        reporter.reportErrorForNode(
          code,
          node,
          [
            'EdgeInsets.symmetric(${[
              if (!isZeroExpression(v)) 'vertical: ${v.toSource()}',
              if (!isZeroExpression(h)) 'horizontal: ${h.toSource()}',
            ].join(', ')})',
          ],
        );
    }
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithProperConstructor()];
}

class _ReplaceWithProperConstructor extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final constructorName = node.constructorName.name?.name;

      switch (constructorName) {
        case 'fromLTRB':
          handleFromLTRB(node: node, reporter: reporter);
        case 'only':
          handleOnly(node: node, reporter: reporter);
        case 'symmetric':
          handleSymmetric(node: node, reporter: reporter);
        case _:
          return;
      }
    });
  }

  void handleFromLTRB({
    required InstanceCreationExpression node,
    required ChangeReporter reporter,
  }) {
    final arguments = node.argumentList.positionalArguments.toList();
    if (arguments.length != 4) return;

    final left = arguments[0];
    final top = arguments[1];
    final right = arguments[2];
    final bottom = arguments[3];

    switch ((left: left, top: top, right: right, bottom: bottom)) {
      case (
          left: IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          top: IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          right: IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          bottom: IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
        ):
        return;
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l.toSource() == t.toSource() &&
              t.toSource() == r.toSource() &&
              r.toSource() == b.toSource():
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.all',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.all(${l.toSource()})',
          );
        });
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l.toSource() == r.toSource() && t.toSource() == b.toSource():
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.symmetric',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.symmetric(${[
              if (!isZeroExpression(l)) 'horizontal: ${l.toSource()}',
              if (!isZeroExpression(t)) 'vertical: ${t.toSource()}',
            ].join(', ')})',
          );
        });
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when [l, t, r, b].any(isZeroExpression):
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.only',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.only(${[
              if (!isZeroExpression(l)) 'left: ${l.toSource()}',
              if (!isZeroExpression(t)) 'top: ${t.toSource()}',
              if (!isZeroExpression(r)) 'right: ${r.toSource()}',
              if (!isZeroExpression(b)) 'bottom: ${b.toSource()}',
            ].join(', ')})',
          );
        });
    }
  }

  void handleOnly({
    required InstanceCreationExpression node,
    required ChangeReporter reporter,
  }) {
    final left = node.argumentList.findArgumentByName('left')?.expression;
    final top = node.argumentList.findArgumentByName('top')?.expression;
    final right = node.argumentList.findArgumentByName('right')?.expression;
    final bottom = node.argumentList.findArgumentByName('bottom')?.expression;

    switch ((left: left, top: top, right: right, bottom: bottom)) {
      case (
          left: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          top: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          right: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
          bottom: null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0),
        ):
        return;
      case (
            left: final l?,
            top: final t?,
            right: final r?,
            bottom: final b?,
          )
          when l.toSource() == t.toSource() &&
              t.toSource() == r.toSource() &&
              r.toSource() == b.toSource():
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.all',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.all(${l.toSource()})',
          );
        });
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when l?.toSource() == r?.toSource() && t?.toSource() == b?.toSource():
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.symmetric',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.symmetric(${[
              if (l != null && !isZeroExpression(l))
                'horizontal: ${l.toSource()}',
              if (t != null && !isZeroExpression(t))
                'vertical: ${t.toSource()}',
            ].join(', ')})',
          );
        });
      case (
            left: final l,
            top: final t,
            right: final r,
            bottom: final b,
          )
          when [l, t, r, b].any((e) => e != null && isZeroExpression(e)):
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.only',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.only(${[
              if (l is IntegerLiteral && l.value != 0 ||
                  l is DoubleLiteral && l.value != 0.0)
                'left: ${l?.toSource()}',
              if (t is IntegerLiteral && t.value != 0 ||
                  t is DoubleLiteral && t.value != 0.0)
                'top: ${t?.toSource()}',
              if (r is IntegerLiteral && r.value != 0 ||
                  r is DoubleLiteral && r.value != 0.0)
                'right: ${r?.toSource()}',
              if (b is IntegerLiteral && b.value != 0 ||
                  b is DoubleLiteral && b.value != 0.0)
                'bottom: ${b?.toSource()}',
            ].join(', ')})',
          );
        });
      case (
          left: final l?,
          top: final t?,
          right: final r?,
          bottom: final b?,
        ):
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.fromLTRB',
          priority: 80,
        );
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.fromLTRB(${[
              l.toSource(),
              t.toSource(),
              r.toSource(),
              b.toSource(),
            ].join(', ')})',
          );
        });
    }
  }

  void handleSymmetric({
    required InstanceCreationExpression node,
    required ChangeReporter reporter,
  }) {
    final vertical =
        node.argumentList.findArgumentByName('vertical')?.expression;
    final horizontal =
        node.argumentList.findArgumentByName('horizontal')?.expression;

    switch ((vertical: vertical, horizontal: horizontal)) {
      case (
          vertical:
              null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
          horizontal:
              null || IntegerLiteral(value: 0) || DoubleLiteral(value: 0.0),
        ):
        return;
      case (
            vertical: final v?,
            horizontal: final h?,
          )
          when v.toSource() == h.toSource():
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.all',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.all(${v.toSource()})',
          );
        });
      case (
            vertical: final v?,
            horizontal: final h?,
          )
          when [v, h].any(isZeroExpression):
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with EdgeInsets.symmetric',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.sourceRange,
            'EdgeInsets.symmetric(${[
              if (!isZeroExpression(v)) 'vertical: ${v.toSource()}',
              if (!isZeroExpression(h)) 'horizontal: ${h.toSource()}',
            ].join(', ')})',
          );
        });
    }
  }
}
