import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import internal/aoc_utils
import internal/point

pub fn main() {
  let filename = "inputs/day12.txt"

  let lines_result = aoc_utils.read_lines(from: filename)
  case lines_result {
    Ok(lines) -> {
      // If the file was converting into a list of lines
      // successfully then run each part of the problem
      aoc_utils.run_part_and_print("Part 1", fn() { solve_p1(lines) })
    }
    Error(_) -> io.println("Error reading file")
  }
}

// Part 1
pub fn solve_p1(lines: List(String)) -> Result(String, String) {
  let sections = aoc_utils.chunk_around_empty_strings(lines)

  let #(present_input, requirements_input) =
    list.split(sections, list.length(sections) - 1)

  let presents =
    present_input
    |> list.map(parse_present)
    |> dict.from_list

  let requirements =
    requirements_input
    |> list.flatten
    |> list.map(parse_requirements)

  requirements
  |> list.fold_until(Ok(0), fn(fit_count, r) {
    case fit_count {
      Ok(c) ->
        case definite_fit(r), definite_notfit(r, presents) {
          True, _ -> list.Continue(Ok(c + 1))
          _, True -> list.Continue(Ok(c))
          _, _ -> list.Stop(Error("Marginal fitting case detected"))
        }
      _ -> list.Stop(Error("Marginal fitting case detected"))
    }
  })
  |> result.map(int.to_string)
}

fn parse_present(lines: List(String)) -> #(Int, set.Set(point.Point)) {
  let assert [index_line, ..shape_lines] = lines

  let assert Ok(present_index) =
    string.replace(index_line, ":", "") |> int.parse

  let present =
    shape_lines
    |> list.index_fold(set.new(), fn(acc, line, y) {
      string.to_graphemes(line)
      |> list.index_fold(acc, fn(acc, character, x) {
        case character {
          "#" -> set.insert(acc, #(x, y))
          _ -> acc
        }
      })
    })

  #(present_index, present)
}

fn parse_requirements(line: String) -> #(point.Point, List(Int)) {
  let assert Ok(#(dimensions, present_counts)) = string.split_once(line, ": ")
  let assert Ok(#(x_string, y_string)) = string.split_once(dimensions, "x")
  let counts =
    string.split(present_counts, " ") |> list.map(int.parse) |> result.values

  let assert Ok(x) = int.parse(x_string)
  let assert Ok(y) = int.parse(y_string)
  #(#(x, y), counts)
}

fn definite_fit(requirements: #(point.Point, List(Int))) -> Bool {
  let area = requirements.0.0 * requirements.0.1

  int.sum(requirements.1) * 9 <= area
}

fn definite_notfit(
  requirements: #(point.Point, List(Int)),
  presents: dict.Dict(Int, set.Set(point.Point)),
) -> Bool {
  let area = requirements.0.0 * requirements.0.1

  requirements.1
  |> list.index_fold(0, fn(present_area, present_count, idx) {
    let assert Ok(p) = dict.get(presents, idx)
    present_area + { present_count * set.size(p) }
  })
  > area
}
