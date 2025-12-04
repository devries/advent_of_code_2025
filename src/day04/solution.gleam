import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import internal/aoc_utils
import internal/point

pub fn main() {
  let filename = "inputs/day04.txt"

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
  let map = parse_map(lines)

  dict.to_list(map)
  |> list.filter(fn(tup) { tup.1 == "@" })
  |> list.map(fn(tup) { count_surrounding_rolls(tup.0.0, tup.0.1, map) })
  |> list.filter(fn(count) { count < 4 })
  |> list.length
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let map = parse_map(lines)

  recursive_removal_sum(map, 0)
  |> int.to_string
  |> Ok
}

fn parse_map(lines: List(String)) -> dict.Dict(point.Point, String) {
  lines
  |> list.index_fold(dict.new(), fn(acc, line, idx_y) {
    string.to_graphemes(line)
    |> list.index_fold(acc, fn(acc, char, idx_x) {
      dict.insert(acc, #(idx_x, idx_y), char)
    })
  })
}

fn count_surrounding_rolls(
  x: Int,
  y: Int,
  map: dict.Dict(point.Point, String),
) -> Int {
  [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x - 1, y),
    #(x + 1, y),
    #(x - 1, y + 1),
    #(x, y + 1),
    #(x + 1, y + 1),
  ]
  |> list.fold(0, fn(acc, p) {
    case dict.get(map, p) {
      Ok("@") -> acc + 1
      _ -> acc
    }
  })
}

fn remove_accessible_rolls(
  map: dict.Dict(point.Point, String),
) -> #(dict.Dict(point.Point, String), Int) {
  let removable =
    dict.to_list(map)
    |> list.filter(fn(tup) { tup.1 == "@" })
    |> list.filter(fn(tup) {
      count_surrounding_rolls(tup.0.0, tup.0.1, map) < 4
    })
    |> list.map(pair.first)

  let new_map =
    removable
    |> list.fold(map, fn(acc, pt) { dict.insert(acc, pt, ".") })

  #(new_map, list.length(removable))
}

fn recursive_removal_sum(map: dict.Dict(point.Point, String), acc: Int) -> Int {
  case remove_accessible_rolls(map) {
    #(_, 0) -> acc
    #(new_map, n) -> recursive_removal_sum(new_map, acc + n)
  }
}
