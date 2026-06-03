import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

import '../../utils/extensions/ast.dart';
import '../../utils/type_checker.dart';
import '../../utils/utils.dart';

class WrapWithLayoutBuilder extends ResolvedCorrectionProducer {
  static const _assistKind = AssistKind(
    'dart.assist.wrapWithLayoutBuilder',
    29,
    'Wrap with LayoutBuilder',
  );

  WrapWithLayoutBuilder({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => _assistKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final constructorSourceRange = instanceCreation.keywordAndConstructorNameSourceRange;
    if (!_selectionCovers(constructorSourceRange)) return;

    final type = instanceCreation.staticType;
    if (type == null || !widgetChecker.isSuperTypeOf(type)) return;
    if (layoutBuilderChecker.isExactlyType(type)) return;

    final parentWidget = findParentWidget(instanceCreation);
    if (parentWidget != null) {
      final parentType = parentWidget.staticType;
      if (parentType != null && layoutBuilderChecker.isExactlyType(parentType)) {
        return;
      }
    }

    await builder.addDartFileEdit(file, (fileEdit) {
      fileEdit.addSimpleInsertion(instanceCreation.offset, 'LayoutBuilder(builder: (context, constraints) { return ');
      fileEdit.addSimpleInsertion(instanceCreation.end, '; },)');
    });
  }

  bool _selectionCovers(SourceRange sourceRange) {
    return selectionOffset >= sourceRange.offset && selectionEnd <= sourceRange.end;
  }
}
