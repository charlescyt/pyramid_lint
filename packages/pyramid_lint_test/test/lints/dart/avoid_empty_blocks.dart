// expect_lint: avoid_empty_blocks
void emptyFunction() {}

void emptyIfBlock(bool condition) {
  // expect_lint: avoid_empty_blocks
  if (condition) {}
}
