import day03/solution
import gleam/string

const testinput = "987654321111111
811111111111119
234234234234278
818181911112111"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("357")
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p2(lines) == Ok("3121910778619")
}
