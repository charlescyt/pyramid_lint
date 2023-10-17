// ignore_for_file: avoid_print, unnecessary_lambdas

void fetchData() {
  // expect_lint: prefer_async_await
  performAsyncOperation().then((result) {
    print(result);
  }).catchError((Object? error) {
    print('Error: $error');
  }).whenComplete(() {
    print('Done');
  });
}

Future<String> performAsyncOperation() async {
  return 'Result';
}
