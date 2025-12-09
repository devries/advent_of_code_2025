import gleam/dict
import gleam/list
import gleam/pair

pub opaque type DisjointSet(a) {
  DisjointSet(parents: dict.Dict(a, a), sizes: dict.Dict(a, Int))
}

/// Create a disjoint set from a list of items. Initially all items are
/// separate sets.
pub fn from_list(items: List(a)) -> DisjointSet(a) {
  let #(parents, sizes) =
    list.fold(items, #(dict.new(), dict.new()), fn(acc, item) {
      #(dict.insert(acc.0, item, item), dict.insert(acc.1, item, 1))
    })
  DisjointSet(parents:, sizes:)
}

/// Find the set to which an item belogs. This will return an updated
/// copy of the disjoint set with some path optimization and the root
/// element defining the set.
pub fn find(dj: DisjointSet(a), item: a) -> Result(#(DisjointSet(a), a), Nil) {
  case dict.get(dj.parents, item) {
    Ok(parent) -> {
      case parent == item {
        True -> Ok(#(dj, item))
        False -> {
          // Path compression to make each item point to a single representative set parent
          case find(dj, parent) {
            Error(_) -> Error(Nil)
            Ok(#(dj, root)) -> {
              let updated_dj =
                DisjointSet(
                  parents: dict.insert(dj.parents, item, root),
                  sizes: dj.sizes,
                )
              Ok(#(updated_dj, root))
            }
          }
        }
      }
    }
    Error(_) -> Error(Nil)
  }
}

/// Create a union set from the set containing the element x
/// and the set containing the element y. If they are already
/// in the same set nothing happens. This returns an updated
/// disjoint set.
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

/// Find the size of the set which contains item.
pub fn size(dj: DisjointSet(a), item: a) -> Result(Int, Nil) {
  case find(dj, item) {
    Error(Nil) -> Error(Nil)
    Ok(#(dj, rep_parent)) -> dict.get(dj.sizes, rep_parent)
  }
}

// I am thinking about just providing all sets
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
  dict.to_list(dj.parents)
  |> list.filter(fn(pair) { pair.0 == pair.1 })
  |> list.map(pair.first)
}
