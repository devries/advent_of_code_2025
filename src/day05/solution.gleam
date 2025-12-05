import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day05.txt"

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
  let #(ranges, values) = parse_input(lines)

  values
  |> list.filter(fn(val) {
    list.fold_until(ranges, False, fn(_, range) {
      case val >= range.0 && val <= range.1 {
        True -> list.Stop(True)
        False -> list.Continue(False)
      }
    })
  })
  |> list.length
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let #(ranges, _) = parse_input(lines)

  merge_overlaps(ranges)
  |> list.map(fn(range) { range.1 - range.0 + 1 })
  |> int.sum
  |> int.to_string
  |> Ok
}

fn parse_range(line: String) -> Result(#(Int, Int), Nil) {
  use string_vals <- result.try(string.split_once(line, "-"))

  use first <- result.try(int.parse(string_vals.0))
  use second <- result.try(int.parse(string_vals.1))

  Ok(#(first, second))
}

fn parse_input(lines: List(String)) -> #(List(#(Int, Int)), List(Int)) {
  let #(range_part, rest) = list.split_while(lines, fn(l) { l != "" })

  let value_part = list.drop(rest, 1)

  let assert Ok(ranges) =
    range_part
    |> list.map(parse_range)
    |> result.all

  let assert Ok(values) = value_part |> list.map(int.parse) |> result.all

  #(ranges, values)
}

fn merge_overlaps(ranges: List(#(Int, Int))) -> List(#(Int, Int)) {
  ranges
  |> list.sort(fn(ra, rb) { int.compare(ra.0, rb.0) })
  |> merge_sorted_overlaps([])
}

fn merge_sorted_overlaps(
  remain: List(#(Int, Int)),
  complete: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case remain {
    [] -> complete
    [range] -> [range, ..complete]
    [current, next, ..rest] -> {
      let #(current_start, current_end) = current
      let #(next_start, next_end) = next

      case next_start <= current_end, next_end <= current_end {
        True, True -> merge_sorted_overlaps([current, ..rest], complete)
        True, False ->
          merge_sorted_overlaps([#(current_start, next_end), ..rest], complete)
        False, True -> panic as "ranges are not in order"
        False, False ->
          merge_sorted_overlaps([next, ..rest], [current, ..complete])
      }
    }
  }
}
