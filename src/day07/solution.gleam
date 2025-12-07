import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import internal/aoc_utils

pub fn main() {
  let filename = "inputs/day07.txt"

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
  let map = parse(lines)
  let beams = set.new() |> set.insert(map.start)

  count_splits(map.splitters, beams, 0)
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let map = parse(lines)

  count_timelines(map.splitters, dict.from_list([#(map.start, 1)]))
  |> dict.to_list
  |> list.fold(0, fn(acc, tuple) { acc + tuple.1 })
  |> int.to_string
  |> Ok
}

type Map {
  Map(start: Int, splitters: List(List(Int)))
}

fn parse(lines: List(String)) -> Map {
  // let #(startline, splitlines) = list.split(lines, 1)

  let imap =
    lines
    |> list.fold(Map(0, []), fn(acc, row) {
      let row_results =
        string.to_graphemes(row)
        |> list.index_fold(#(acc.start, []), fn(subacc, char, idx) {
          case char {
            "." -> subacc
            "S" -> #(idx, subacc.1)
            "^" -> #(subacc.0, [idx, ..subacc.1])
            _ -> panic as "unexpected character in map"
          }
        })

      Map(row_results.0, [row_results.1, ..acc.splitters])
    })

  Map(imap.start, list.reverse(imap.splitters) |> list.drop(1))
}

fn count_splits(
  splitters: List(List(Int)),
  beams: set.Set(Int),
  split_count: Int,
) -> Int {
  case splitters {
    [splitter_row, ..rest] -> {
      let #(new_beams, new_count) =
        splitter_row
        |> list.fold(#(beams, split_count), fn(acc, splitter_idx) {
          case set.contains(beams, splitter_idx) {
            False -> acc
            True -> #(
              acc.0
                |> set.delete(splitter_idx)
                |> set.insert(splitter_idx + 1)
                |> set.insert(splitter_idx - 1),
              acc.1 + 1,
            )
          }
        })
      count_splits(rest, new_beams, new_count)
    }
    [] -> split_count
  }
}

// beam timelines is the number of timelines leading to a beam
fn count_timelines(
  splitters: List(List(Int)),
  beam_timelines: dict.Dict(Int, Int),
) -> dict.Dict(Int, Int) {
  case splitters {
    [splitter_row, ..rest] -> {
      let new_beam_timelines =
        splitter_row
        |> list.fold(beam_timelines, fn(acc, splitter_idx) {
          // Start with the timeline count for each beam, then if a split
          // happens all the timelines get added to timelines in adjacent beams
          // The current position beam disappears leaving 0 timelines for that
          // position
          let timeline_count =
            dict.get(beam_timelines, splitter_idx) |> result.unwrap(0)

          dict.insert(acc, splitter_idx, 0)
          |> dict.insert(
            splitter_idx - 1,
            { dict.get(acc, splitter_idx - 1) |> result.unwrap(0) }
              + timeline_count,
          )
          |> dict.insert(
            splitter_idx + 1,
            { dict.get(acc, splitter_idx + 1) |> result.unwrap(0) }
              + timeline_count,
          )
        })

      count_timelines(rest, new_beam_timelines)
    }
    [] -> beam_timelines
  }
}
