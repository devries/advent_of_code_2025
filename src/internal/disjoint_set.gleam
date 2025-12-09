import gleam/dict
import gleam/list

pub opaque type DisjointSet(a) {
  DisjointSet(parents: dict.Dict(a, a), sizes: dict.Dict(a, Int))
}

pub fn from_list(items: List(a)) -> DisjointSet(a) {
  let #(parents, sizes) =
    list.fold(items, #(dict.new(), dict.new()), fn(acc, item) {
      #(dict.insert(acc.0, item, item), dict.insert(acc.1, item, 1))
    })
  DisjointSet(parents:, sizes:)
}

pub fn find(dj: DisjointSet(a), item: a) -> Result(#(DisjointSet(a), a), Nil) {
  case dict.get(dj.parents, item) {
    Ok(parent) -> {
      case parent == item {
        True -> Ok(#(dj, item))
        False -> {
          // Path compression to make each item point to a single representative set parent
          case find(dj, parent) {
            Error(_) -> Error(Nil)
            Ok(#(dj, rep_parent)) -> {
              let updated_dj =
                DisjointSet(
                  parents: dict.insert(dj.parents, item, rep_parent),
                  sizes: dj.sizes,
                )
              Ok(#(updated_dj, rep_parent))
            }
          }
        }
      }
    }
    Error(_) -> Error(Nil)
  }
}

pub fn union(dj: DisjointSet(a), x: a, y: a) -> Result(DisjointSet(a), Nil) {
  case find(dj, x) {
    Error(Nil) -> Error(Nil)
    Ok(#(dj, root_x)) -> {
      case find(dj, y) {
        Error(Nil) -> Error(Nil)
        Ok(#(dj, root_y)) if root_x != root_y -> {
          case dict.get(dj.sizes, root_x), dict.get(dj.sizes, root_y) {
            Ok(size_x), Ok(size_y) if size_x < size_y -> {
              Ok(DisjointSet(
                dict.insert(dj.parents, root_x, root_y),
                dict.insert(dj.sizes, root_y, size_x + size_y),
              ))
            }
            Ok(size_x), Ok(size_y) -> {
              Ok(DisjointSet(
                dict.insert(dj.parents, root_y, root_x),
                dict.insert(dj.sizes, root_x, size_x + size_y),
              ))
            }
            _, _ -> Error(Nil)
          }
        }
        _ -> Ok(dj)
      }
    }
  }
}

pub fn size(dj: DisjointSet(a), item: a) -> Result(Int, Nil) {
  case find(dj, item) {
    Error(Nil) -> Error(Nil)
    Ok(#(dj, rep_parent)) -> dict.get(dj.sizes, rep_parent)
  }
}

pub fn to_list(dj: DisjointSet(a), item: a) -> Result(List(a), Nil) {
  case find(dj, item) {
    Error(Nil) -> Error(Nil)
    Ok(#(dj, rep_parent)) -> {
      dict.keys(dj.parents)
      |> list.filter(fn(i) {
        case find(dj, i) {
          Ok(#(_, p)) if p == rep_parent -> True
          _ -> False
        }
      })
      |> Ok
    }
  }
}

pub fn setlist(dj: DisjointSet(a)) -> List(a) {
  dict.keys(dj.parents)
  |> list.filter(fn(item) {
    case find(dj, item) {
      Ok(#(_, p)) if p == item -> True
      _ -> False
    }
  })
}
