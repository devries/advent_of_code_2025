import day12/solution
import gleam/string

const testinput = "0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Error("Marginal fitting case detected")
}
