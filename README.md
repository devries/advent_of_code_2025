# Advent of Code 2025

[![Tests](https://github.com/devries/advent_of_code_2025/actions/workflows/test.yml/badge.svg)](https://github.com/devries/advent_of_code_2025/actions/workflows/test.yml)
[![Stars: 20](https://img.shields.io/badge/⭐_Stars-20-yellow)](https://adventofcode.com/2025)

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
- [Day 3](https://adventofcode.com/2025/day/3): [⭐ ⭐ solution](src/day03/solution.gleam)
- [Day 4](https://adventofcode.com/2025/day/4): [⭐ ⭐ solution](src/day04/solution.gleam)
- [Day 5](https://adventofcode.com/2025/day/5): [⭐ ⭐ solution](src/day05/solution.gleam)
- [Day 6](https://adventofcode.com/2025/day/6): [⭐ ⭐ solution](src/day06/solution.gleam)
- [Day 7](https://adventofcode.com/2025/day/7): [⭐ ⭐ solution](src/day07/solution.gleam)
- [Day 8](https://adventofcode.com/2025/day/8): [⭐ ⭐ solution](src/day08/solution.gleam)

    This was an interesting problem, and I ended up learning a few new things. If
    you define a circuit as the set of all connected junctions, then you can find
    the union of the sets to which the two junction boxes you are connecting belong
    in order to find the new connected circuit. The difficulty is finding an
    efficient way to look up a set given one element from the set. 
    In my [initial solution](https://github.com/devries/advent_of_code_2025/blob/b4ecead2fd971f0fec5223da3679160b599e851e/src/day08/solution.gleam) I created a dict which had junction boxes as the key
    and sets of junction boxes as the values. This meant changing the values of
    all the elements in the dictionary that belonged to a set when a new union
    was made. In the Gleam Discord the [disjoint-set data structure](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
    came up as a way to do this more efficiently, so I decided to try it and
    created a simple [disjoint-set library](src/internal/disjoint_set.gleam).
    Using the new structure, and making a few other changes, the second part of
    my [solution](src/day08/solution.gleam) is roughly 3 times faster.

- [Day 9](https://adventmfcode.com/2025/day/9): [⭐   solution](src/day09/solution.gleam)

    I ran into an issue doing part 2. I think it is that I am only checking if
    the corners are inside the figure. It may be that the corners are inside,
    but there is a line going through one of the walls. I ran out of time
    this morning to work on this and will pick it up later.

- [Day 10](https://adventmfcode.com/2025/day/10): [⭐   solution](src/day10/solution.gleam)

    I tried doing part 2 a naive way with some memoization, but it seems like
    I still need to work on it. Code was getting very convoluted anyway, not
    pretty like the first several days.

- [Day 11](https://adventmfcode.com/2025/day/11): [⭐ ⭐ solution](src/day11/solution.gleam)

    Back on track with today's problem. This is a straightforward depth-first
    search, but I add memoization so I don't have to keep revisiting paths
    I have counted before.
