import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import internal/aoc_utils
import internal/point

pub fn main() {
  let filename = "inputs/day09.txt"

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
    let assert [x, y] =
      string.split(line, ",") |> list.map(int.parse) |> result.values

    #(x, y)
  })
  |> list.combination_pairs
  |> list.map(fn(pair) {
    point.sub(pair.1, pair.0)
    |> fn(d) {
      { int.absolute_value(d.0) + 1 } * { int.absolute_value(d.1) + 1 }
    }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
  |> int.to_string
  |> Ok
}

// Part 2
// 4690044150 too high
// 4635268638 too high
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let vertices =
    lines
    |> list.map(fn(line) {
      let assert [x, y] =
        string.split(line, ",") |> list.map(int.parse) |> result.values

      #(x, y)
    })
  let assert Ok(first) = list.first(vertices)
  let assert Ok(last) = list.last(vertices)

  let closing = #(last, first)

  let #(vertical_edges, horizontal_edges) =
    [closing, ..list.window_by_2(vertices)]
    |> list.partition(fn(pair) { pair.0.0 == pair.1.0 })

  list.combination_pairs(vertices)
  |> list.filter(fn(pair) {
    {
      within_figure(#(pair.0.0, pair.1.1), vertical_edges, horizontal_edges)
      == True
    }
    && {
      within_figure(#(pair.1.0, pair.0.1), vertical_edges, horizontal_edges)
      == True
    }
  })
  |> list.map(fn(pair) {
    point.sub(pair.1, pair.0)
    |> fn(d) {
      { int.absolute_value(d.0) + 1 } * { int.absolute_value(d.1) + 1 }
    }
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
  |> int.to_string
  |> Ok
}

fn within_figure(
  point: #(Int, Int),
  vertical_edges: List(#(#(Int, Int), #(Int, Int))),
  horizontal_edges: List(#(#(Int, Int), #(Int, Int))),
) -> Bool {
  horizontal_edges
  |> list.filter(fn(pair) { pair.0.1 == point.1 })
  |> list.filter(fn(pair) {
    { pair.0.0 <= point.0 && pair.1.0 >= point.0 }
    || { pair.1.0 <= point.0 && pair.0.0 >= point.0 }
  })
  |> list.length
  |> fn(v) { v > 0 }
  || vertical_edges
  // Edge to the right of point
  |> list.filter(fn(pair) { pair.0.0 > point.0 })
  // horizontal line from point intersects edge
  |> list.filter(fn(pair) {
    { pair.0.1 > point.1 && pair.1.1 <= point.1 }
    || { pair.0.1 <= point.1 && pair.1.1 > point.1 }
  })
  |> list.length
  |> fn(v) { v % 2 == 1 }
}

fn within_rectangle(
  point: #(Int, Int),
  pair: #(#(Int, Int), #(Int, Int)),
) -> Bool {
  {
    { pair.0.0 > point.0 && pair.1.0 < point.0 }
    || { pair.1.0 > point.0 && pair.0.0 < point.0 }
  }
  && {
    { pair.0.1 > point.1 && pair.1.1 < point.1 }
    || { pair.1.1 > point.1 && pair.1.0 < point.1 }
  }
}
