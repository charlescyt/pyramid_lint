// expect_lint: prefer_async_callback
typedef A = Future<void> Function();

// expect_lint: prefer_async_callback
typedef B = Future<void> Function()?;
