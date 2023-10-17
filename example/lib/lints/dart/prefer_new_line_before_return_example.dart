String example(bool isTrue) {
  if (isTrue) {
    return 'true';
  } // expect_lint: prefer_new_line_before_return
  return 'false';
}
