import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtensions on DartType {
  bool get isNullable =>
      nullabilitySuffix == NullabilitySuffix.question || isDartCoreNull;
}
