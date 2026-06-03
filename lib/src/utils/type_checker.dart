import 'package:source_gen/source_gen.dart';

const TypeChecker iterableChecker = TypeChecker.typeNamedLiterally('Iterable', inSdk: true);
const TypeChecker listChecker = TypeChecker.typeNamedLiterally('List', inSdk: true);

const TypeChecker widgetChecker = TypeChecker.typeNamedLiterally('Widget', inPackage: 'flutter');
const TypeChecker stateChecker = TypeChecker.typeNamedLiterally('State', inPackage: 'flutter');
const TypeChecker containerChecker = TypeChecker.typeNamedLiterally('Container', inPackage: 'flutter');
const TypeChecker expandedChecker = TypeChecker.typeNamedLiterally('Expanded', inPackage: 'flutter');
const TypeChecker flexChecker = TypeChecker.typeNamedLiterally('Flex', inPackage: 'flutter');
const TypeChecker flexibleChecker = TypeChecker.typeNamedLiterally('Flexible', inPackage: 'flutter');
const TypeChecker sizedBoxChecker = TypeChecker.typeNamedLiterally('SizedBox', inPackage: 'flutter');
const TypeChecker layoutBuilderChecker = TypeChecker.typeNamedLiterally('LayoutBuilder', inPackage: 'flutter');
const TypeChecker richTextChecker = TypeChecker.typeNamedLiterally('RichText', inPackage: 'flutter');
const TypeChecker borderChecker = TypeChecker.typeNamedLiterally('Border', inPackage: 'flutter');
const TypeChecker borderRadiusChecker = TypeChecker.typeNamedLiterally('BorderRadius', inPackage: 'flutter');
const TypeChecker iconButtonChecker = TypeChecker.typeNamedLiterally('IconButton', inPackage: 'flutter');
const TypeChecker edgeInsetsChecker = TypeChecker.typeNamedLiterally('EdgeInsets', inPackage: 'flutter');
const TypeChecker mediaQueryChecker = TypeChecker.typeNamedLiterally('MediaQuery', inPackage: 'flutter');
const TypeChecker mediaQueryDataChecker = TypeChecker.typeNamedLiterally('MediaQueryData', inPackage: 'flutter');
const TypeChecker changeNotifierChecker = TypeChecker.typeNamedLiterally('ChangeNotifier', inPackage: 'flutter');
const TypeChecker animationControllerChecker = TypeChecker.typeNamedLiterally(
  'AnimationController',
  inPackage: 'flutter',
);

const TypeChecker widgetOrStateChecker = TypeChecker.any([widgetChecker, stateChecker]);
const TypeChecker containerOrSizedBoxChecker = TypeChecker.any([containerChecker, sizedBoxChecker]);
const TypeChecker expandedOrFlexibleChecker = TypeChecker.any([expandedChecker, flexibleChecker]);
const TypeChecker disposableControllerChecker = TypeChecker.any([animationControllerChecker, changeNotifierChecker]);
