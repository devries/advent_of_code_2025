import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import internal/aoc_utils
import internal/disjoint_set

pub fn main() {
  let filename = "inputs/day08.txt"

  let lines_result = aoc_utils.read_lines(from: filename)
  case lines_result {
    Ok(lines) -> {
      // If the file was converting into a list of lines
      // successfully then run each part of the problem
      aoc_utils.run_part_and_print("Part 1", fn() { solve_p1(lines, 1000) })
      aoc_utils.run_part_and_print("Part 2", fn() { solve_p2(lines) })
    }
    Error(_) -> io.println("Error reading file")
  }
}

// Part 1
pub fn solve_p1(lines: List(String), connections: Int) -> Result(String, String) {
  let boxes =
    lines
    |> list.map(parse_line)

  let closest_boxes =
    boxes
    |> list.combination_pairs
    |> list.map(fn(pair) { #(pair, dsq_boxes(pair.0, pair.1)) })
    |> list.sort(fn(v1, v2) { int.compare(v1.1, v2.1) })
    |> list.take(connections)
    |> list.map(fn(t) { t.0 })

  let circuits = wire(disjoint_set.from_list(boxes), closest_boxes)

  disjoint_set.setlist(circuits)
  |> list.map(disjoint_set.size(circuits, _))
  |> result.values
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
  |> int.to_string
  |> Ok
}

// Part 2
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  let boxes =
    lines
    |> list.map(parse_line)

  let closest_boxes =
    boxes
    |> list.combination_pairs
    |> list.map(fn(pair) { #(pair, dsq_boxes(pair.0, pair.1)) })
    |> list.sort(fn(v1, v2) { int.compare(v1.1, v2.1) })
    |> list.map(fn(t) { t.0 })

  build_circuit_sized(
    list.length(boxes),
    disjoint_set.from_list(boxes),
    closest_boxes,
  )
  |> fn(v) { { v.0 }.x * { v.1 }.x }
  |> int.to_string
  |> Ok
}

type Junction {
  Junction(x: Int, y: Int, z: Int)
}

fn dsq_boxes(b1: Junction, b2: Junction) -> Int {
  [b1.x - b2.x, b1.y - b2.y, b1.z - b2.z]
  |> list.map(fn(v) { v * v })
  |> int.sum
}

fn parse_line(line: String) -> Junction {
  let assert [x, y, z] =
    line |> string.split(",") |> list.map(int.parse) |> result.values
  Junction(x:, y:, z:)
}

// End up making a dictionary of all the junction boxes with the circuit
// they are part of. The circuit is a set of all involved junction boxes.
// When I combine two boxes I have to update the circuit of all involed
// junctions.
fn wire(
  circuit_table: disjoint_set.DisjointSet(Junction),
  connections: List(#(Junction, Junction)),
) -> disjoint_set.DisjointSet(Junction) {
  list.fold(connections, circuit_table, fn(acc, conn) {
    let assert Ok(new_table) = disjoint_set.union(acc, conn.0, conn.1)
    new_table
  })
}

// Just keep combining until the set representing the circuit
// has the desired size. Then output the junction boxes of the
// connection that achieved that size.
fn build_circuit_sized(
  size: Int,
  circuit_table: disjoint_set.DisjointSet(Junction),
  connections: List(#(Junction, Junction)),
) -> #(Junction, Junction) {
  case connections {
    [] -> panic as "unable to build requested circuit size"
    [first, ..rest] -> {
      let assert Ok(new_table) =
        disjoint_set.union(circuit_table, first.0, first.1)
      case disjoint_set.size(new_table, first.0) {
        Ok(s) if s == size -> first
        _ -> build_circuit_sized(size, new_table, rest)
      }
    }
  }
}
