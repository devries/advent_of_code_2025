# Advent of Code 2025

[![Tests](https://github.com/devries/advent_of_code_2025/actions/workflows/test.yml/badge.svg)](https://github.com/devries/advent_of_code_2025/actions/workflows/test.yml)
[![Stars: 4](https://img.shields.io/badge/⭐_Stars-4-yellow)](https://adventofcode.com/2025)

This year will be my second year doing Advent of Code in [Gleam](https://gleam.run).
Last year I was still learning the language, and in the past year I have used it
much more and even made some small contributions to the compiler, the
[gleam_time](https://hexdocs.pm/gleam_time/index.html) package, and maintain a
timezone database and utility package called [tzif](https://hexdocs.pm/tzif/index.html).
Gleam is a simple language with a wonderful community. I encourage anyone
interested in Gleam to [take the language tour](https://tour.gleam.run/) and
[use the playground](https://playground.gleam.run/).

To start a new day's problem use the command

```sh
gleam run new --day=1
```
where `1` is the day number of the problem. This will create some starting
code in the `src/day01` directory as well as a test in the `test` directory.

To run a day's problems use the command

```sh
gleam run -m day01/solution
```

To run the unit tests for all the days run

```sh
gleam test
```

For some problems, setting the AOC_DEBUG environment variable outputs additional
information.

- [Day 1](https://adventofcode.com/2025/day/1): [⭐ ⭐ solution](src/day01/solution.gleam)
- [Day 2](https://adventofcode.com/2025/day/2): [⭐ ⭐ solution](src/day02/solution.gleam)
