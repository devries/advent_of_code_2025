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
  |> list.count(fn(v) {
    case v {
      0 -> True
      _ -> False
    }
  })
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let start = 50

  lines
  |> list.fold(#(start, 0), fn(acc, line) {
    let cur = case acc.0, parse_line(line) {
      // Don't count starting at 0 and going down as a zero pass
      0, delta if delta < 0 -> 100 + delta
      s, delta -> s + delta
    }
    let add = count_zero_passes(cur)
    let cur = cur % 100
    case cur < 0 {
      True -> #(100 + cur, acc.1 + add)
      False -> #(cur, acc.1 + add)
    }
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

pub fn count_zero_passes(val: Int) -> Int {
  count_zero_acc(val, 0)
}

pub fn count_zero_acc(val: Int, count: Int) -> Int {
  case val {
    val if val > 100 -> count_zero_acc(val - 100, count + 1)
    val if val < 0 -> count_zero_acc(val + 100, count + 1)
    0 -> count + 1
    // 100 is also landing at 0
    100 -> count + 1
    _ -> count
  }
}
