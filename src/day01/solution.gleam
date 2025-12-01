import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day01.txt"

  let lines_result = aoc_utils.read_lines(from: filename)
  case lines_result {
    Ok(lines) -> {
      // If the file was converting into a list of lines
      // successfully then run each part of the problem
      aoc_utils.run_part_and_print("Part 1", fn() { solve_p1(lines) })
      aoc_utils.run_part_and_print("Part 2", fn() { solve_p2(lines) })
    }
    Error(_) -> io.println("Error reading file")
  }
}

// Part 1
pub fn solve_p1(lines: List(String)) -> Result(String, String) {
  let start = 50

  lines
  |> list.map_fold(start, fn(acc, line) {
    let cur = { acc + parse_line(line) } % 100
    case cur < 0 {
      True -> #(100 + cur, 100 + cur)
      False -> #(cur, cur)
    }
  })
  |> pair.second
  |> list.count(fn(v) { v == 0 })
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let start = 50

  lines
  |> list.fold(#(start, 0), fn(acc, line) {
    case acc.0, parse_line(line) {
      // Don't count starting at 0 and going down as a zero pass
      0, delta if delta < 0 -> 100 + delta
      s, delta -> s + delta
    }
    |> turn_and_count_zeros(acc.1)
  })
  |> pair.second
  |> int.to_string
  |> Ok
}

pub fn parse_line(line: String) -> Int {
  case line {
    "L" <> rem -> {
      let assert Ok(v) = int.parse(rem)
      int.negate(v)
    }
    "R" <> rem -> {
      let assert Ok(v) = int.parse(rem)
      v
    }
    _ -> panic as "unexpected input"
  }
}

pub fn turn_and_count_zeros(val: Int, count: Int) -> #(Int, Int) {
  case val {
    val if val > 100 -> turn_and_count_zeros(val - 100, count + 1)
    val if val < 0 -> turn_and_count_zeros(val + 100, count + 1)
    0 -> #(0, count + 1)
    // 100 is 0 too
    100 -> #(0, count + 1)
    _ -> #(val, count)
  }
}
