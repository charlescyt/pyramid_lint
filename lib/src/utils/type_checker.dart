import 'package:source_gen/source_gen.dart';

const TypeChecker iterableChecker = TypeChecker.typeNamedLiterally('Iterable', inSdk: true);
const TypeChecker listChecker = TypeChecker.typeNamedLiterally('List', inSdk: true);

const TypeChecker containerChecker = TypeChecker.typeNamedLiterally('Container', inPackage: 'flutter');
const TypeChecker expandedChecker = TypeChecker.typeNamedLiterally('Expanded', inPackage: 'flutter');
const TypeChecker flexChecker = TypeChecker.typeNamedLiterally('Flex', inPackage: 'flutter');
const TypeChecker flexibleChecker = TypeChecker.typeNamedLiterally('Flexible', inPackage: 'flutter');
const TypeChecker sizedBoxChecker = TypeChecker.typeNamedLiterally('SizedBox', inPackage: 'flutter');
const TypeChecker richTextChecker = TypeChecker.typeNamedLiterally('RichText', inPackage: 'flutter');
const TypeChecker borderRadiusChecker = TypeChecker.typeNamedLiterally('BorderRadius', inPackage: 'flutter');

const TypeChecker containerOrSizedBoxChecker = TypeChecker.any([containerChecker, sizedBoxChecker]);
const TypeChecker expandedOrFlexibleChecker = TypeChecker.any([expandedChecker, flexibleChecker]);
