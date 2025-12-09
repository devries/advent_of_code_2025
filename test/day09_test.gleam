import day09/solution
import gleam/string

const testinput = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("50")
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p2(lines) == Ok("24")
}
