import on.{Select, Return}
import gleeunit
import gleam/string
import gleam/option.{None, Some}

pub fn main() -> Nil {
  gleeunit.main()
}

//**********
//* Result *
//**********

pub fn eager_error_ok_test() {
  assert {
    use ok_payload <- on.eager_error_ok(
      Error(Nil),
      "Bob",
    )
    ok_payload + 1 |> string.inspect
  } == "Bob"

  assert {
    use ok_payload <- on.eager_error_ok(
      Ok(3),
      "Bob",
    )
    ok_payload + 1 |> string.inspect
  } == "4"
}

pub fn error_ok_test() {
  assert {
    use ok_payload <- on.error_ok(
      Error("Max"),
      fn(e){e <> e},
    )
    ok_payload + 1 |> string.inspect
  } == "MaxMax"

  assert {
    use ok_payload <- on.error_ok(
      Ok(3),
      fn(e){e <> e},
    )
    ok_payload + 1 |> string.inspect
  } == "4"
}

pub fn eager_ok_error_test() {
  assert {
    use error_payload <- on.eager_ok_error(
      Error("Max"),
      "r",
    )
    error_payload <> error_payload
  } == "MaxMax"

  assert {
    use error_payload <- on.eager_ok_error(
      Ok(3),
      "r",
    )
    error_payload <> error_payload
  } == "r"
}

pub fn ok_error_test() {
  assert {
    use error_payload <- on.ok_error(
      Error("Max"),
      fn(e){e + 1 |> string.inspect },
    )
    error_payload <> error_payload
  } == "MaxMax"

  assert {
    use error_payload <- on.ok_error(
      Ok(3),
      fn(e){e + 1 |> string.inspect },
    )
    error_payload <> error_payload
  } == "4"
}

//********
//* Bool *
//********

pub fn eager_false_true_test() {
  assert {
    use <- on.eager_false_true(
      False,
      "Max",
    )
    "Sue"
  } == "Max"

  assert {
    use <- on.eager_false_true(
      True,
      "Max",
    )
    "Sue"
  } == "Sue"
}

pub fn false_true_test() {
  assert {
    use <- on.false_true(
      False,
      fn() { "Max" },
    )
    "Sue"
  } == "Max"

  assert {
    use <- on.false_true(
      True,
      fn() { "Max" },
    )
    "Sue"
  } == "Sue"
}

pub fn eager_true_false_test() {
  assert {
    use <- on.eager_true_false(
      False,
      on_true: "Max",
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.eager_true_false(
      True,
      on_true: "Max",
    )
    "Sue"
  } == "Max"
}

pub fn lazy_true_false_test() {
  assert {
    use <- on.true_false(
      False,
      fn() { "Max" },
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.true_false(
      True,
      fn() { "Max" },
    )
    "Sue"
  } == "Max"
}

pub fn true_test() {
  assert {
    use <- on.true(False)
    True
  } == False

  assert {
    use <- on.true(False)
    False
  } == False

  assert {
    use <- on.true(True)
    True
  } == True

  assert {
    use <- on.true(True)
    False
  } == False
}

pub fn false_test() {
  assert {
    use <- on.false(False)
    True
  } == True

  assert {
    use <- on.false(False)
    False
  } == False

  assert {
    use <- on.false(True)
    True
  } == True

  assert {
    use <- on.false(True)
    False
  } == True
}

//**********
//* Option *
//**********

pub fn eager_none_some_test() {
  assert {
    use some_payload <- on.eager_none_some(
      None,
      "Sue",
    )
    some_payload <> some_payload 
  } == "Sue"

  assert {
    use some_payload <- on.eager_none_some(
      Some("Max"),
      "Sue",
    )
    some_payload <> some_payload 
  } == "MaxMax"
}

pub fn none_some_test() {
  assert {
    use some_payload <- on.none_some(
      None,
      fn(){ "Sue" },
    )
    some_payload <> some_payload 
  } == "Sue"

  assert {
    use some_payload <- on.none_some(
      Some("Max"),
      fn(){ "Sue" },
    )
    some_payload <> some_payload 
  } == "MaxMax"
}

pub fn eager_some_none_test() {
  assert {
    use <- on.eager_some_none(
      None,
      "z",
    )
    "Max"
  } == "Max"

  assert {
    use <- on.eager_some_none(
      Some("Sue"),
      "z",
    )
    "Max"
  } == "z"
}

pub fn some_none_test() {
  assert {
    use <- on.some_none(
      None,
      fn(e){e <> e},
    )
    "Max"
  } == "Max"

  assert {
    use <- on.some_none(
      Some("Sue"),
      fn(e){e <> e},
    )
    "Max"
  } == "SueSue"
}

//**********
//* List/1 *
//**********

pub fn empty_test() {
  assert {
    use <- on.empty(
      ["bob", "jake"]
    )
    ["suzan"]
  } == ["bob", "jake"]

  assert {
    use <- on.empty(
      []
    )
    ["suzan"]
  } == ["suzan"]
}

pub fn nonempty_test() {
  assert {
    use first, _rest <- on.nonempty(
      ["bob", "jake"]
    )
    [first <> first]
  } == ["bobbob"]

  assert {
    use first, _rest <- on.nonempty(
      []
    )
    [first <> first]
  } == []
}

//**********
//* List/2 *
//**********

pub fn eager_empty_nonempty_test() {
  assert {
    use first, _rest <- on.eager_empty_nonempty(
      [],
      "Sue",
    )
    first <> first
  } == "Sue"

  assert {
    use first, _rest <- on.eager_empty_nonempty(
      ["Max"],
      "Sue",
    )
    first <> first
  } == "MaxMax"
}

pub fn empty_nonempty_test() {
  assert {
    use first, _rest <- on.empty_nonempty(
      [],
      fn(){ "Sue" },
    )
    first <> first
  } == "Sue"

  assert {
    use first, _rest <- on.empty_nonempty(
      ["Max"],
      fn(){ "Sue" },
    )
    first <> first
  } == "MaxMax"
}

pub fn eager_nonempty_empty_test() {
  assert {
    use <- on.eager_nonempty_empty(
      [],
      "z",
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.eager_nonempty_empty(
      ["Max"],
      "z",
    )
    "Sue"
  } == "z"
}

pub fn nonempty_empty_test() {
  assert {
    use <- on.nonempty_empty(
      [],
      fn(first, _rest){ first <> first },
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.nonempty_empty(
      ["Max"],
      fn(first, _rest){ first <> first },
    )
    "Sue"
  } == "MaxMax"
}

//**********
//* List/3 *
//**********

pub fn eager_empty_eager_singleton_gt1_test() {
  assert {
    use first, second, _rest <- on.eager_empty_eager_singleton_gt1(
      ["Sue", "Max"],
      "Empty",
      "Singleton",
    )
    first <> second
  } == "SueMax"

  assert {
    use first, second, _rest <- on.eager_empty_eager_singleton_gt1(
      ["Sue"],
      "Empty",
      "Singleton",
    )
    first <> second
  } == "Singleton"

  assert {
    use first, second, _rest <- on.eager_empty_eager_singleton_gt1(
      [],
      "Empty",
      "Singleton",
    )
    first <> second
  } == "Empty"
}

pub fn eager_empty_singleton_gt1_test() {
  assert {
    use first, second, _rest <- on.eager_empty_singleton_gt1(
      ["Sue", "Max"],
      "Empty",
      fn(f) -> String { f <> f},
    )
    first <> second
  } == "SueMax"

  assert {
    use first, second, _rest <- on.eager_empty_singleton_gt1(
      ["Sue"],
      "Empty",
      fn(f) -> String { f <> f <> f},
    )
    first <> second
  } == "SueSueSue"

  assert {
    use first, second, _rest <- on.eager_empty_singleton_gt1(
      [],
      "Empty",
      fn(f) -> String { f <> f},
    )
    first <> second
  } == "Empty"
}

pub fn empty_eager_singleton_gt1_test() {
  assert {
    use first, second, _rest <- on.empty_eager_singleton_gt1(
      ["Sue", "Max"],
      fn() { "Empty" },
      "z",
    )
    first <> second
  } == "SueMax"

  assert {
    use first, second, _rest <- on.empty_eager_singleton_gt1(
      ["Sue"],
      fn() { "Empty" },
      "z",
    )
    first <> second
  } == "z"

  assert {
    use first, second, _rest <- on.empty_eager_singleton_gt1(
      [],
      fn() { "Empty" },
      "z",
    )
    first <> second
  } == "Empty"
}

pub fn empty_singleton_gt1_test() {
  assert {
    use first, second, _rest <- on.empty_singleton_gt1(
      ["Sue", "Max"],
      fn() { "Empty" },
      fn(f) -> String { f <> f},
    )
    first <> second
  } == "SueMax"

  assert {
    use first, second, _rest <- on.empty_singleton_gt1(
      ["Sue"],
      fn() { "Empty" },
      fn(f) -> String { f <> f},
    )
    first <> second
  } == "SueSue"

  assert {
    use first, second, _rest <- on.empty_singleton_gt1(
      [],
      fn() { "Empty" },
      fn(f) -> String { f <> f},
    )
    first <> second
  } == "Empty"
}

pub fn eager_empty_eager_gt1_singleton_test() {
  assert {
    use first <- on.eager_empty_eager_gt1_singleton(
      [1, 4, 7],
      on_empty: Error("empty list"),
      on_gt1: Error("> 1 element in list"),
    )
    Ok(first + first)
  } == Error("> 1 element in list")
  assert {
    use first <- on.eager_empty_eager_gt1_singleton(
      [4],
      on_empty: Error("empty list"),
      on_gt1: Error("> 1 element in list"),
    )
    Ok(first + first)
  } == Ok(8)
  assert {
    use first <- on.eager_empty_eager_gt1_singleton(
      [],
      on_empty: Error("empty list"),
      on_gt1: Error("> 1 element in list"),
    )
    Ok(first + first)
  } == Error("empty list")
}

pub fn eager_empty_gt1_singleton_test() {
  assert {
    use first <- on.eager_empty_gt1_singleton(
      ["Sue", "Max"],
      "Empty",
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "SueMax"

  assert {
    use first <- on.eager_empty_gt1_singleton(
      ["Sue"],
      "Empty",
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "SueSue"

  assert {
    use first <- on.eager_empty_gt1_singleton(
      [],
      "Empty",
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "Empty"
}

pub fn empty_eager_gt1_singleton_test() {
  assert {
    use first <- on.empty_eager_gt1_singleton(
      [1, 4, 7],
      on_empty: fn() { Error("empty list") },
      on_gt1: Error("> 1 elements in list"),
    )
    Ok(first + first)
  } == Error("> 1 elements in list")

  assert {
    use first <- on.empty_eager_gt1_singleton(
      [4],
      on_empty: fn() { Error("empty list") },
      on_gt1: Error("> 1 elements in list"),
    )
    Ok(first + first)
  } == Ok(8)

  assert {
    use first <- on.empty_eager_gt1_singleton(
      [],
      on_empty: fn() { Error("empty list") },
      on_gt1: Error("> 1 elements in list"),
    )
    Ok(first + first)
  } == Error("empty list")
}

pub fn empty_gt1_singleton_test() {
  assert {
    use first <- on.empty_gt1_singleton(
      ["Sue", "Max"],
      fn(){ "Empty" },
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "SueMax"

  assert {
    use first <- on.empty_gt1_singleton(
      ["Sue"],
      fn(){ "Empty" },
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "SueSue"

  assert {
    use first <- on.empty_gt1_singleton(
      [],
      fn(){ "Empty" },
      fn(f, s, _rest) -> String { f <> s},
    )
    first <> first
  } == "Empty"
}

pub fn eager_singleton_eager_gt1_empty_test() {
  assert {
    use <- on.eager_singleton_eager_gt1_empty(
      [1, 4, 7],
      on_singleton: 55,
      on_gt1: 66,
    )
    0
  } == 66

  assert {
    use <- on.eager_singleton_eager_gt1_empty(
      [4],
      on_singleton: 55,
      on_gt1: 66,
    )
    0
  } == 55

  assert {
    use <- on.eager_singleton_eager_gt1_empty(
      [],
      on_singleton: 55,
      on_gt1: 66,
    )
    0
  } == 0
}

pub fn eager_singleton_gt1_empty_test() {
  assert {
    use <- on.eager_singleton_gt1_empty(
      [1, 4, 7],
      on_singleton: 55,
      on_gt1: fn(first, second, _) { first + second },
    )
    0
  } == 5

  assert {
    use <- on.eager_singleton_gt1_empty(
      [4],
      on_singleton: 55,
      on_gt1: fn(first, second, _) { first + second },
    )
    0
  } == 55

  assert {
    use <- on.eager_singleton_gt1_empty(
      [],
      on_singleton: 55,
      on_gt1: fn(first, second, _) { first + second },
    )
    0
  } == 0
}

pub fn singleton_eager_gt1_empty_test() {
  assert {
    use <- on.singleton_eager_gt1_empty(
      ["Sue", "Max"],
      fn(f) { f <> f},
      "Bob",
    )
    "Empty"
  } == "Bob"

  assert {
    use <- on.singleton_eager_gt1_empty(
      ["Sue"],
      fn(f) { f <> f},
      "Bob",
    )
    "Empty"
  } == "SueSue"

  assert {
    use <- on.singleton_eager_gt1_empty(
      [],
      fn(f) { f <> f},
      "Bob",
    )
    "Empty"
  } == "Empty"
}

pub fn singleton_gt1_empty_test() {
  assert {
    use <- on.singleton_gt1_empty(
      ["Sue", "Max"],
      fn(f) { f <> f},
      fn(f, s, _rest) -> String { f <> s},
    )
    "Empty"
  } == "SueMax"

  assert {
    use <- on.singleton_gt1_empty(
      ["Sue"],
      fn(f) { f <> f},
      fn(f, s, _rest) -> String { f <> s},
    )
    "Empty"
  } == "SueSue"

  assert {
    use <- on.singleton_gt1_empty(
      [],
      fn(f) { f <> f},
      fn(f, s, _rest) -> String { f <> s},
    )
    "Empty"
  } == "Empty"
}

pub fn select_test() {
  assert {
    use name <- on.select(
      Return("Max")
    )
    name <> name
  } == "Max"

  assert {
    use name <- on.select(
      Select("Max")
    )
    name <> name
  } == "MaxMax"
}
