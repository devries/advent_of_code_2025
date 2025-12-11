import day11/solution
import gleam/string

const testinput = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

const testinput_two = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn part1_test() {
  let lines = string.split(testinput, "\n")
  assert solution.solve_p1(lines) == Ok("5")
}

pub fn part2_test() {
  let lines = string.split(testinput_two, "\n")
  assert solution.solve_p2(lines) == Ok("2")
}
