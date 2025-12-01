import day01/solution
import gleam/string
import gleeunit/should

const testinput = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  solution.solve_p1(lines)
  |> should.equal(Ok("3"))
}

pub fn part2_test() {
  let lines = string.split(testinput, "\n")
  solution.solve_p2(lines)
  |> should.equal(Ok("6"))
}
