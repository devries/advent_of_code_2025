import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import internal/aoc_utils
import internal/memoize

pub fn main() {
  let filename = "inputs/day10.txt"

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
  |> list.map(fn(row) {
    let parts = parse(row)

    let assert Ok(light_list) = dict.get(parts, "lights")
    let assert Ok(light_string) = list.first(light_list)
    let lights = parse_lights(light_string)

    let assert Ok(button_strings) = dict.get(parts, "buttons")
    let buttons = button_strings |> list.map(parse_button)

    list.range(1, list.length(buttons))
    |> list.fold_until(0, fn(count, pushes) {
      let result =
        list.combinations(buttons, pushes)
        |> list.fold_until(count, fn(c, button_combo) {
          case press_buttons(button_combo) == lights {
            True -> list.Stop(pushes)
            False -> list.Continue(c)
          }
        })

      case result {
        0 -> list.Continue(count)
        n -> list.Stop(n)
      }
    })
  })
  |> int.sum
  |> int.to_string
  |> Ok
}

// Part 2
// see https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
// for an explanation of this method (I did not come up with it).
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  lines
  |> list.map(fn(row) {
    let parts = parse(row)

    let assert Ok(count_list) = dict.get(parts, "joltages")
    let assert Ok(count_string) = list.first(count_list)
    let joltages = parse_joltages(count_string)

    let assert Ok(button_strings) = dict.get(parts, "buttons")
    let buttons =
      button_strings
      |> list.map(fn(one_button) {
        parse_button(one_button) |> button_to_list(list.length(joltages))
      })

    let patterns = parity_patterns(buttons)
    // patterns |> dict.to_list |> list.map(fn(v) { echo v })

    solve_one_joltage(patterns, joltages)
  })
  |> int.sum
  |> int.to_string
  |> Ok
}

type Button {
  Button(wires: List(Int))
}

fn parse(line: String) -> dict.Dict(String, List(String)) {
  string.split(line, " ")
  |> list.group(fn(part) {
    case string.first(part) {
      Ok("[") -> "lights"
      Ok("(") -> "buttons"
      Ok("{") -> "joltages"
      _ -> "unknown"
    }
  })
}

fn parse_lights(part: String) -> set.Set(Int) {
  part
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.to_graphemes
  |> list.index_fold([], fn(illuminated, char, i) {
    case char {
      "." -> illuminated
      "#" -> [i, ..illuminated]
      _ -> panic as "unexpected character in lights string"
    }
  })
  |> set.from_list
}

fn parse_button(part: String) -> Button {
  part
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values
  |> Button
}

fn parse_joltages(part: String) -> List(Int) {
  part
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values
}

// Press a list of buttons and output which lights are on
fn press_buttons(buttons: List(Button)) -> set.Set(Int) {
  buttons
  |> list.fold(dict.new(), fn(acc, button) {
    list.fold(button.wires, acc, fn(acc_inner, wire) {
      dict.upsert(acc_inner, wire, fn(v) {
        case v {
          option.None -> 1
          option.Some(count) -> count + 1
        }
      })
    })
  })
  |> dict.to_list
  |> list.filter_map(fn(tup) {
    case tup.1 % 2 {
      0 -> Error(Nil)
      1 -> Ok(tup.0)
      _ -> panic as "remainder has to be 0 or 1"
    }
  })
  |> set.from_list
}

fn button_to_list(button: Button, length: Int) -> List(Int) {
  let wires = set.from_list(button.wires)

  list.range(0, length - 1)
  |> list.fold([], fn(acc, v) {
    case set.contains(wires, v) {
      True -> [1, ..acc]
      False -> [0, ..acc]
    }
  })
  |> list.reverse
}

fn list_add(left: List(Int), right: List(Int)) -> List(Int) {
  let assert Ok(pairs) = list.strict_zip(left, right)
  list.map(pairs, fn(tup) { tup.0 + tup.1 })
}

fn list_subtract(left: List(Int), right: List(Int)) -> List(Int) {
  let assert Ok(pairs) = list.strict_zip(left, right)
  list.map(pairs, fn(tup) { tup.0 - tup.1 })
}

fn is_not_negative(joltages: List(Int)) -> Bool {
  joltages
  |> list.filter(fn(v) { v < 0 })
  |> list.length
  |> fn(l) { l == 0 }
}

fn is_zero(joltages: List(Int)) -> Bool {
  joltages
  |> list.filter(fn(v) { v != 0 })
  |> list.length
  |> fn(l) { l == 0 }
}

fn parity_patterns(buttons: List(List(Int))) -> dict.Dict(List(Int), Int) {
  list.range(1, list.length(buttons))
  |> list.fold(dict.new(), fn(patterns, pushes) {
    list.combinations(buttons, pushes)
    |> list.fold(patterns, fn(acc, button_presses) {
      let result = case list.reduce(button_presses, list_add) {
        Ok(r) -> r
        Error(Nil) -> panic as "no buttons?"
      }
      dict.upsert(acc, result, fn(current) {
        let push_count = list.length(button_presses)
        case current {
          option.None -> push_count
          option.Some(v) -> int.min(push_count, v)
        }
      })
    })
  })
}

fn solve_one_joltage(patterns: dict.Dict(List(Int), Int), joltages: List(Int)) {
  use cache <- memoize.with_cache()

  case bifurcation_solution(patterns, joltages, cache) {
    Ok(v) -> v
    Error(Nil) -> panic as "no solution found"
  }
}

fn bifurcation_solution(
  patterns: dict.Dict(List(Int), Int),
  joltages: List(Int),
  cache: memoize.Cache(List(Int), Result(Int, Nil)),
) -> Result(Int, Nil) {
  use <- memoize.cache_check(cache, joltages)
  case is_zero(joltages) {
    True -> Ok(0)
    False -> {
      let parity = list.map(joltages, fn(v) { v % 2 })

      let possible_counts =
        patterns
        |> dict.keys
        |> list.filter(fn(p) { list.map(p, fn(v) { v % 2 }) == parity })
        |> list.filter_map(fn(p) {
          let remaining_jolts = list_subtract(joltages, p)
          let assert Ok(press_count) = dict.get(patterns, p)

          case is_not_negative(remaining_jolts) {
            True ->
              case
                bifurcation_solution(
                  patterns,
                  list.map(remaining_jolts, fn(v) { v / 2 }),
                  cache,
                )
              {
                Ok(n) -> Ok({ 2 * n } + press_count)
                Error(Nil) -> Error(Nil)
              }
            False -> Error(Nil)
          }
        })

      let all_counts = case is_zero(parity) {
        True ->
          case
            bifurcation_solution(
              patterns,
              list.map(joltages, fn(v) { v / 2 }),
              cache,
            )
          {
            Ok(n) -> [2 * n, ..possible_counts]
            Error(Nil) -> possible_counts
          }
        False -> possible_counts
      }

      case all_counts {
        [] -> Error(Nil)
        _ ->
          list.max(all_counts, fn(a, b) { int.compare(a, b) |> order.negate })
      }
    }
  }
}
