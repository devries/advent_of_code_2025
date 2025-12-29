import argv
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleam/string_tree
import glint
import handles
import handles/ctx
import handles/format
import simplifile

pub fn main() -> Nil {
  glint.new()
  |> glint.with_name("aoc-dev")
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add(at: [], do: explain())
  |> glint.add(at: ["new"], do: new_day())
  |> glint.run(argv.load().arguments)
}

fn explain() -> glint.Command(Nil) {
  use <- glint.command_help("Explains how to use this program.")

  use _, _, _ <- glint.command()

  io.println(
    "Use \"gleam dev new --day=<day>\" to use the code template to start a new day of\n        advent of code.\n    <day> should be an integer.",
  )
  io.println("")
  io.println(
    "Use \"gleam run -m dayXX/solution\" to run the solution\nfrom a particular day.\n\nFor example:\n    gleam run -m day01/solution",
  )
}

fn day_flag() -> glint.Flag(Int) {
  glint.int_flag("day")
  |> glint.flag_help("advent of code day to create")
}

fn new_day() -> glint.Command(Nil) {
  use <- glint.command_help("Start a new advent of code problem")
  use day_number <- glint.flag(day_flag())
  use _, _, flags <- glint.command()

  case day_number(flags) {
    Error(_) -> {
      io.println("You must specify the day using the \"--day=\" flag.")
    }
    Ok(number) -> {
      case generate_template(number) {
        Ok(Nil) -> io.println("Successfully wrote placeholder code")
        Error(Nil) -> io.println("Did not complete successfully")
      }
    }
  }
}

fn generate_template(day_number) -> Result(Nil, Nil) {
  use sol_input <- result.try(
    simplifile.read(from: "templates/solution.gleam")
    |> result.map_error(fn(e) {
      io.println_error(
        "Error opening templates/solution.gleam: "
        <> simplifile.describe_error(e),
      )
    }),
  )

  use test_input <- result.try(
    simplifile.read(from: "templates/dayXX_test.gleam")
    |> result.map_error(fn(e) {
      io.println_error(
        "Error opening templates/dayXX_test.gleam: "
        <> simplifile.describe_error(e),
      )
    }),
  )

  use sol_template <- result.try(
    handles.prepare(sol_input)
    |> result.map_error(fn(e) {
      case
        format.format_tokenizer_error(
          e,
          "Error parsing solution.gleam: {{ . }}",
        )
      {
        Error(_) -> io.println_error("Unknown error parsing solution.gleam")
        Ok(v) -> io.println_error(v)
      }
    }),
  )
  use test_template <- result.try(
    handles.prepare(test_input)
    |> result.map_error(fn(e) {
      case
        format.format_tokenizer_error(
          e,
          "Error parsing dayXX_test.gleam: {{ . }}",
        )
      {
        Error(_) -> io.println_error("Unknown error parsing dayXX_test.gleam")
        Ok(v) -> io.println_error(v)
      }
    }),
  )

  let day_value =
    day_number |> int.to_string |> string.pad_start(to: 2, with: "0")

  use sol_tree <- result.try(
    handles.run(sol_template, ctx.Str(day_value), [])
    |> result.map_error(fn(e) {
      case
        format.format_runtime_error(
          e,
          "Error rendering solution.gleam: {{ . }}",
        )
      {
        Error(_) -> io.println_error("Unknown error rendering solution.gleam")
        Ok(v) -> io.println_error(v)
      }
    }),
  )

  use test_tree <- result.try(
    handles.run(test_template, ctx.Str(day_value), [])
    |> result.map_error(fn(e) {
      case
        format.format_runtime_error(
          e,
          "Error rendering day" <> day_value <> "_test.gleam: {{ . }}",
        )
      {
        Error(_) ->
          io.println_error(
            "Unknown error rendering day" <> day_value <> "_test.gleam",
          )
        Ok(v) -> io.println_error(v)
      }
    }),
  )

  use _ <- result.try(
    simplifile.create_directory("src/day" <> day_value)
    |> result.map_error(fn(e) {
      io.println_error(
        "Error creating the src/day"
        <> day_value
        <> " directory: "
        <> simplifile.describe_error(e),
      )
    }),
  )

  use _ <- result.try(
    simplifile.write(
      "src/day" <> day_value <> "/solution.gleam",
      string_tree.to_string(sol_tree),
    )
    |> result.map_error(fn(e) {
      io.println_error(
        "Error writing solution.gleam: " <> simplifile.describe_error(e),
      )
    }),
  )

  use _ <- result.map(
    simplifile.write(
      "test/day" <> day_value <> "_test.gleam",
      string_tree.to_string(test_tree),
    )
    |> result.map_error(fn(e) {
      io.println_error(
        "Error writing day"
        <> day_value
        <> "_test.gleam: "
        <> simplifile.describe_error(e),
      )
    }),
  )
  Nil
}
