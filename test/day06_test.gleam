import day06/solution
import gleam/string

const testinput = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("4277556")
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p2(lines) == Ok("3263827")
}
