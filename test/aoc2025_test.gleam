import gleam/time/duration
import gleeunit
import internal/aoc_utils
import internal/point

pub fn main() {
  gleeunit.main()
}

pub fn solution_or_error_test() {
  assert aoc_utils.solution_or_error(Ok("This is good")) == "This is good"

  assert aoc_utils.solution_or_error(Error("This is bad"))
    == "ERROR: This is bad"
}

pub fn chunk_up_test() {
  assert {
      ["aaa", "bbb", "ccc", "", "ddd", "eee", "", "", "fff"]
      |> aoc_utils.chunk_around_empty_strings()
    }
    == [["aaa", "bbb", "ccc"], ["ddd", "eee"], ["fff"]]
}

pub fn point_addition_test() {
  assert point.add(#(2, 1), #(-1, 1)) == #(1, 2)
}

pub fn point_multiplication_test() {
  assert point.mul(#(2, 5), 5) == #(10, 25)

  assert point.mul(#(2, 5), 0) == #(0, 0)
}

pub fn duration_to_string_test() {
  assert aoc_utils.duration_string(duration.nanoseconds(123_000)) == "123 μs"
  assert aoc_utils.duration_string(duration.milliseconds(1)) == "1000 μs"
  assert aoc_utils.duration_string(duration.milliseconds(123)) == "123 ms"
  assert aoc_utils.duration_string(duration.milliseconds(1234)) == "1234 ms"
  assert aoc_utils.duration_string(duration.milliseconds(12_345)) == "12.345 s"
  assert aoc_utils.duration_string(duration.milliseconds(12_340)) == "12.340 s"
}
