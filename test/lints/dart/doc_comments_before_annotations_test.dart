import 'package:flutter/foundation.dart' show immutable;

@immutable
// expect_lint: doc_comments_before_annotations
/// Some documentation.
class A {}

@immutable
// expect_lint: doc_comments_before_annotations
/// Some documentation.
///
/// More documentation.
@Deprecated('Use A instead')
class B {}

/// Some documentation.
///
/// More documentation.
@immutable
class C {}
