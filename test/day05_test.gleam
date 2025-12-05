import day05/solution
import gleam/string

const testinput = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("3")
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p2(lines) == Ok("14")
}
