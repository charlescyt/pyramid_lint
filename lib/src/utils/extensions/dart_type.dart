import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// Whether the type is nullable.
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question || isDartCoreNull;
}
