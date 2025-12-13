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
    |> list.map(minimal_coordinate_first)
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
  |> list.map(minimal_coordinate_first)
  |> list.filter(no_vertical_intersections(_, vertical_edges))
  |> list.filter(no_horizontal_intersections(_, horizontal_edges))
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

fn minimal_coordinate_first(
  value: #(#(Int, Int), #(Int, Int)),
) -> #(#(Int, Int), #(Int, Int)) {
  #(#(int.min(value.0.0, value.1.0), int.min(value.0.1, value.1.1)), #(
    int.max(value.0.0, value.1.0),
    int.max(value.0.1, value.1.1),
  ))
}

// The pair will always have coordinate pair.0 less than pair.1
// because of the minimal_coordinate_first filter.
fn within_figure(
  point: #(Int, Int),
  vertical_edges: List(#(#(Int, Int), #(Int, Int))),
  horizontal_edges: List(#(#(Int, Int), #(Int, Int))),
) -> Bool {
  horizontal_edges
  |> list.filter(fn(pair) { pair.0.1 == point.1 })
  |> list.filter(fn(pair) { pair.0.0 <= point.0 && pair.1.0 >= point.0 })
  |> list.length
  |> fn(v) { v > 0 }
  || vertical_edges
  // Edge to the right of point
  |> list.filter(fn(pair) { pair.0.0 > point.0 })
  // horizontal line from point intersects edge
  |> list.filter(fn(pair) { pair.0.1 <= point.1 && pair.1.1 > point.1 })
  |> list.length
  |> fn(v) { v % 2 == 1 }
}

// The box will also be regularized with minimal_coordinate_first to make
// it easier to find intersections.
fn no_vertical_intersections(
  box: #(point.Point, point.Point),
  vertical_edges: List(#(point.Point, point.Point)),
) -> Bool {
  vertical_edges
  // vertical edge is within the x-range of the box
  |> list.filter(fn(line) { box.0.0 < line.0.0 && line.0.0 < box.1.0 })
  // vertical edge intersects lower or upper edge of box
  |> list.filter(fn(line) {
    { box.0.1 > line.0.1 && box.0.1 < line.1.1 }
    || { box.1.1 > line.0.1 && box.1.1 < line.1.1 }
  })
  |> list.length
  |> fn(l) { l == 0 }
}

// The box will also be regularized with minimal_coordinate_first to make
// it easier to find intersections.
fn no_horizontal_intersections(
  box: #(point.Point, point.Point),
  horizontal_edges: List(#(point.Point, point.Point)),
) -> Bool {
  horizontal_edges
  // horizontal edge is within the y-range of the box
  |> list.filter(fn(line) { box.0.1 < line.0.1 && line.0.1 < box.1.1 })
  // horizontal edge intersects left or right edge of box
  |> list.filter(fn(line) {
    { box.0.0 > line.0.0 && box.0.0 < line.1.0 }
    || { box.1.0 > line.0.0 && box.1.0 < line.1.0 }
  })
  |> list.length
  |> fn(l) { l == 0 }
}
