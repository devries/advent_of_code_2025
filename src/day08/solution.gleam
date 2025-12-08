import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import internal/aoc_utils

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
    |> list.combinations(2)
    |> list.map(fn(pair) {
      case pair {
        [b1, b2] -> #(#(b1, b2), dsq_boxes(b1, b2))
        _ -> panic as "expected a pair of junctions"
      }
    })
    |> list.sort(fn(v1, v2) { int.compare(v1.1, v2.1) })
    |> list.take(connections)
    |> list.map(fn(t) { t.0 })

  wire(dict.new(), closest_boxes)
  |> dict.to_list
  |> list.map(fn(dtup) { dtup.1 })
  |> set.from_list
  |> set.to_list
  |> list.map(set.size)
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
    |> list.combinations(2)
    |> list.map(fn(pair) {
      case pair {
        [b1, b2] -> #(#(b1, b2), dsq_boxes(b1, b2))
        _ -> panic as "expected a pair of junctions"
      }
    })
    |> list.sort(fn(v1, v2) { int.compare(v1.1, v2.1) })
    |> list.map(fn(t) { t.0 })

  build_circuit_sized(list.length(boxes), dict.new(), closest_boxes)
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
  circuit_table: dict.Dict(Junction, set.Set(Junction)),
  connections: List(#(Junction, Junction)),
) -> dict.Dict(Junction, set.Set(Junction)) {
  list.fold(connections, circuit_table, fn(acc, conn) {
    // Get the circuit for a box, if it's not part of a circuit yet
    // just provide a set containing only itself
    let s1 = dict.get(acc, conn.0) |> result.unwrap(set.from_list([conn.0]))
    let s2 = dict.get(acc, conn.1) |> result.unwrap(set.from_list([conn.1]))

    // new combined circuit
    let combined = set.union(s1, s2)

    set.fold(combined, acc, fn(acc_inner, jb) {
      dict.insert(acc_inner, jb, combined)
    })
  })
}

// Just keep combining until the set representing the circuit
// has the desired size. Then output the junction boxes of the
// connection that achieved that size.
fn build_circuit_sized(
  size: Int,
  circuit_table: dict.Dict(Junction, set.Set(Junction)),
  connections: List(#(Junction, Junction)),
) -> #(Junction, Junction) {
  case connections {
    [] -> panic as "unable to build requested circuit size"
    [first, ..rest] -> {
      // Get the circuit for a box, if it's not part of a circuit yet
      // just provide a set containing only itself
      let s1 =
        dict.get(circuit_table, first.0)
        |> result.unwrap(set.from_list([first.0]))
      let s2 =
        dict.get(circuit_table, first.1)
        |> result.unwrap(set.from_list([first.1]))

      // new combined circuit
      let combined = set.union(s1, s2)

      case set.size(combined) {
        s if s == size -> first
        _ -> {
          let new_table =
            set.fold(combined, circuit_table, fn(acc, jb) {
              dict.insert(acc, jb, combined)
            })
          build_circuit_sized(size, new_table, rest)
        }
      }
    }
  }
}
