import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day06.txt"

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
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.filter(fn(v) { v != "" })
  })
  |> list.transpose
  |> list.map(perform_calculation)
  |> int.sum
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  lines
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.reverse
  })
  |> list.transpose
  |> list.filter(fn(l) {
    list.fold_until(l, False, fn(_, v) {
      case v == " " {
        True -> list.Continue(False)
        False -> list.Stop(True)
      }
    })
  })
  |> list.map(fn(column) {
    let l = list.length(column)
    let #(numbers, operation) = list.split(column, l - 1)
    let assert Ok(value) = string.join(numbers, "") |> string.trim |> int.parse
    #(value, operation)
  })
  |> accumulate_operation(0, [])
  |> int.to_string
  |> Ok
}

fn perform_calculation(parts: List(String)) -> Int {
  let l = list.length(parts)
  let #(values, operation) = list.split(parts, l - 1)

  let int_values =
    values
    |> list.map(int.parse)
    |> result.values

  case operation {
    ["+"] -> int.sum(int_values)
    ["*"] -> list.fold(int_values, 1, fn(acc, v) { acc * v })
    _ -> {
      echo parts
      panic as "unexpected operation"
    }
  }
}

fn accumulate_operation(
  tuples: List(#(Int, List(String))),
  sum: Int,
  values: List(Int),
) -> Int {
  case tuples {
    [] -> sum
    [first, ..rest] -> {
      case first {
        #(n, [" "]) -> accumulate_operation(rest, sum, [n, ..values])
        #(n, ["*"]) -> {
          let product = list.fold([n, ..values], 1, fn(p, v) { p * v })
          accumulate_operation(rest, sum + product, [])
        }
        #(n, ["+"]) ->
          accumulate_operation(rest, sum + int.sum([n, ..values]), [])
        _ -> panic as "unexpected tuple"
      }
    }
  }
}
