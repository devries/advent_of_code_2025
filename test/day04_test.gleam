import day04/solution
import gleam/string

const testinput = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("13")
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p2(lines) == Ok("43")
}
