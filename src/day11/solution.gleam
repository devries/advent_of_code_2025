import gleam/deque
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import internal/aoc_utils
import internal/memoize

pub fn main() {
  let filename = "inputs/day11.txt"

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
  let links =
    lines
    |> list.map(parse)
    |> dict.from_list

  start_path_count(links, "you", "out")
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let links =
    lines
    |> list.map(parse)
    |> dict.from_list

  start_path_count(links, "svr", "fft")
  * start_path_count(links, "fft", "dac")
  * start_path_count(links, "dac", "out")
  |> int.to_string
  |> Ok
}

fn parse(line: String) -> #(String, set.Set(String)) {
  let assert Ok(#(start, ends)) = string.split_once(line, ": ")

  let endset = ends |> string.split(" ") |> set.from_list

  #(start, endset)
}

fn start_path_count(
  links: dict.Dict(String, set.Set(String)),
  start: String,
  end: String,
) -> Int {
  use cache <- memoize.with_cache()

  count_paths(links, start, end, 0, cache)
}

fn count_paths(
  links: dict.Dict(String, set.Set(String)),
  start: String,
  end: String,
  total: Int,
  cache: memoize.Cache(String, Int),
) -> Int {
  use <- memoize.cache_check(cache, start)

  case start == end {
    True -> total + 1
    False -> {
      let next_steps = case dict.get(links, start) {
        Ok(s) -> s |> set.to_list
        Error(_) -> []
      }

      list.fold(next_steps, total, fn(acc, next) {
        acc + count_paths(links, next, end, 0, cache)
      })
    }
  }
}
