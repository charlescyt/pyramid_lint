// ignore_for_file: avoid_print, unused_local_variable

void example(bool condition) {
  if (condition) {
    print('then');
  } else {
    print('else');
  }

  final text = condition ? 'then' : 'else';
}
