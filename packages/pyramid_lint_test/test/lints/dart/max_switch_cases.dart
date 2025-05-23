// ignore_for_file: avoid_print

enum Direction {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

void fn(Direction direction) {
  // expect_lint: max_switch_cases
  switch (direction) {
    case Direction.north:
      print('north');
    case Direction.northEast:
      print('northEast');
    case Direction.east:
      print('east');
    case Direction.southEast:
      print('southEast');
    case Direction.south:
      print('south');
    case Direction.southWest:
      print('southWest');
    case Direction.west:
      print('west');
    case Direction.northWest:
      print('northWest');
  }
}

String fn2(Direction direction) {
  // expect_lint: max_switch_cases
  return switch (direction) {
    Direction.north => 'north',
    Direction.northEast => 'northEast',
    Direction.east => 'east',
    Direction.southEast => 'southEast',
    Direction.south => 'south',
    Direction.southWest => 'southWest',
    Direction.west => 'west',
    Direction.northWest => 'northWest',
  };
}
