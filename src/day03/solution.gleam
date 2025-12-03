import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day03.txt"

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
  lines
  |> list.map(parse_line)
  |> list.map(fn(vals) {
    let assert Ok(max) =
      list.take(vals, list.length(vals) - 1) |> list.max(int.compare)

    let remnants = list.drop_while(vals, fn(v) { v < max }) |> list.drop(1)
    let assert Ok(second_max) = list.max(remnants, int.compare)

    10 * max + second_max
  })
  |> int.sum
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  lines
  |> list.map(parse_line)
  |> list.map(find_max_ndigit(_, 12, 0))
  |> int.sum
  |> int.to_string
  |> Ok
}

fn parse_line(line: String) -> List(Int) {
  line
  |> string.to_graphemes
  |> list.map(int.parse)
  |> result.values
}

fn find_max_ndigit(values: List(Int), digits: Int, current: Int) -> Int {
  let assert Ok(max) =
    list.take(values, list.length(values) - digits + 1) |> list.max(int.compare)

  case digits {
    1 -> current * 10 + max
    n if n > 1 -> {
      let remnants = list.drop_while(values, fn(v) { v < max }) |> list.drop(1)

      find_max_ndigit(remnants, digits - 1, current * 10 + max)
    }
    _ -> panic as "digits to find is 0 or less"
  }
}
