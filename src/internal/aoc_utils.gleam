import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/time/duration.{type Duration}
import gleam/time/timestamp
import simplifile

/// Read Advent of Code input file and split into a list of lines.
pub fn read_lines(
  from filepath: String,
) -> Result(List(String), simplifile.FileError) {
  use content <- result.map(simplifile.read(from: filepath))

  // Drop one trailing newline if present
  case string.ends_with(content, "\n") {
    False -> content
    True -> string.drop_end(content, 1)
  }
  |> string.split("\n")
}

pub fn solution_or_error(v: Result(String, String)) -> String {
  case v {
    Ok(solution) -> solution
    Error(error) -> "ERROR: " <> error
  }
}

pub fn chunk_around_empty_strings(lines: List(String)) -> List(List(String)) {
  lines
  |> list.chunk(fn(x) { x == "" })
  |> list.filter(fn(x) {
    case x {
      [item, ..] if item == "" -> False
      _ -> True
    }
  })
}

pub fn time_execution(
  timed_function: fn() -> a,
  callback: fn(Duration, a) -> Nil,
) {
  let start = timestamp.system_time()
  let result = timed_function()
  let duration = timestamp.difference(start, timestamp.system_time())

  callback(duration, result)
}

pub fn duration_string(d: Duration) -> String {
  case duration.to_seconds_and_nanoseconds(d) {
    #(0, nanos) if nanos < 10_000_000 -> int.to_string(nanos / 1000) <> " μs"

    #(secs, nanos) if secs < 10 ->
      int.to_string(secs * 1000 + nanos / 1_000_000) <> " ms"
    #(secs, nanos) ->
      int.to_string(secs)
      <> "."
      <> int.to_string(nanos / 1_000_000) |> string.pad_start(to: 3, with: "0")
      <> " s"
  }
}

pub fn run_part_and_print(
  label: String,
  part: fn() -> Result(String, String),
) -> Nil {
  use duration, result <- time_execution(part)
  io.println(
    label
    <> " ("
    <> duration_string(duration)
    <> ")"
    <> ": "
    <> solution_or_error(result),
  )
}
