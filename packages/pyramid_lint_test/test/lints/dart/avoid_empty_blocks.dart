// expect_lint: avoid_empty_blocks
void emptyFunction() {}

void emptyIfBlock(bool condition) {
  // expect_lint: avoid_empty_blocks
  if (condition) {}
}

void emptyBlockWithTodo() {
  // It's okay to have an empty block with a TODO comment.
  // TODO: Implement this function.
}
