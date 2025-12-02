import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day02.txt"

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
  use range_line <- result.try(
    list.first(lines) |> result.replace_error("No input lines found"),
  )

  string.split(range_line, ",")
  |> list.map(fn(range) {
    let assert [start, stop] = string.split(range, "-")
    sum_invalids(start, stop)
  })
  |> int.sum
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  use range_line <- result.try(
    list.first(lines) |> result.replace_error("No input lines found"),
  )

  string.split(range_line, ",")
  |> list.map(fn(range) {
    let assert [start, stop] = string.split(range, "-")
    sum_invalids_p2(start, stop)
  })
  |> int.sum
  |> int.to_string
  |> Ok
}

fn sum_invalids(start: String, stop: String) -> Int {
  numbers_in_range(start, stop)
  |> yielder.filter(fn(s) { string.length(s) % 2 == 0 })
  |> yielder.filter(fn(s) {
    let l = string.length(s) / 2
    let p1 = string.slice(from: s, at_index: 0, length: l)
    let p2 = string.slice(from: s, at_index: l, length: l)
    p1 == p2
  })
  |> yielder.to_list
  |> list.map(int.parse)
  |> result.values
  |> int.sum
}

fn numbers_in_range(start: String, stop: String) -> yielder.Yielder(String) {
  let assert Ok(start_int) = int.parse(start)
  let assert Ok(stop_int) = int.parse(stop)

  yielder.unfold(from: start_int, with: fn(v) {
    case v {
      v if v > stop_int -> yielder.Done
      _ -> yielder.Next(v, v + 1)
    }
  })
  |> yielder.map(int.to_string)
}

fn sum_invalids_p2(start: String, stop: String) -> Int {
  numbers_in_range(start, stop)
  |> yielder.filter(multirepeater_filter)
  |> yielder.to_list
  |> list.map(int.parse)
  |> result.values
  |> int.sum
}

fn multirepeater_filter(v: String) -> Bool {
  let len = string.length(v)
  let max = len / 2
  let letters = string.to_graphemes(v)

  list.range(1, max)
  |> list.filter(fn(n) { len % n == 0 })
  |> list.fold_until(False, fn(_, i) {
    case
      letters
      |> list.sized_chunk(i)
      |> all_equal
    {
      True -> list.Stop(True)
      False -> list.Continue(False)
    }
  })
}

fn all_equal(l: List(a)) -> Bool {
  case l {
    [] -> panic as "This should not happen"
    // If there is only one element there is no comparison
    [_] -> False
    // On last two elements just check equality
    [la, lb] -> la == lb
    [la, lb, ..rest] ->
      case la == lb {
        True -> all_equal([lb, ..rest])
        False -> False
      }
  }
}
