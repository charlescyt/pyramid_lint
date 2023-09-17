// expect_lint: avoid_empty_block
void emptyFunction() {}

void emptyIfBlock(bool condition) {
  // expect_lint: avoid_empty_block
  if (condition) {}
}
