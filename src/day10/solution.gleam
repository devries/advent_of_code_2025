import gleam/deque
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/option
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
pub fn solve_p2(lines: List(String)) -> Result(String, String) {
  lines
  |> list.map(fn(row) {
    let parts = parse(row)

    let assert Ok(count_list) = dict.get(parts, "joltages")
    let assert Ok(count_string) = list.first(count_list)
    let joltages = parse_joltages(count_string)

    echo joltages
    let assert Ok(button_strings) = dict.get(parts, "buttons")
    let buttons =
      button_strings
      |> list.map(fn(one_button) {
        parse_button(one_button) |> button_to_list(list.length(joltages))
      })

    use cache <- memoize.with_cache()

    let queue =
      list.fold(buttons, deque.new(), fn(acc, b) {
        deque.push_back(acc, #(b, 1))
      })

    find_p2_solution(cache, queue, buttons, joltages)
    |> echo
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

fn find_p2_solution(
  cache: memoize.Cache(List(Int), Int),
  queue: deque.Deque(#(List(Int), Int)),
  buttons: List(List(Int)),
  joltages: List(Int),
) -> Int {
  case deque.pop_front(queue) {
    Error(Nil) -> panic as "no solution found"
    Ok(#(#(current, pushes), new_deque)) -> {
      let new_sums =
        buttons
        |> list.map(list_add(_, current))

      let remains =
        list.map(new_sums, list_subtract(joltages, _))
        // remove negatives
        |> list.filter(fn(l) {
          list.fold_until(l, True, fn(_, element) {
            case element < 0 {
              True -> list.Stop(False)
              False -> list.Continue(True)
            }
          })
        })

      // check if you found it
      case list.contains(remains, list.repeat(0, list.length(joltages))) {
        True -> pushes + 1
        False -> {
          // check if the cache has a way to complete this value
          let cache_result =
            remains
            |> list.map(fn(k) { process.call(cache, 100, memoize.Get(_, k)) })
            |> list.fold_until(0, fn(_, cache_value) {
              case cache_value {
                Ok(v) -> list.Stop(v + pushes + 1)
                Error(Nil) -> list.Continue(0)
              }
            })

          case cache_result {
            0 -> {
              // add results to cache, queue, and keep going
              list.each(new_sums, fn(sum) {
                process.send(cache, memoize.Put(sum, pushes + 1))
              })

              let new_deque =
                list.fold(new_sums, new_deque, fn(acc, sum) {
                  deque.push_back(acc, #(sum, pushes + 1))
                })

              find_p2_solution(cache, new_deque, buttons, joltages)
            }
            v -> v
          }
        }
      }
    }
  }
}
