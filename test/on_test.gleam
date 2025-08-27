import on
import gleeunit
import gleam/string
import gleam/option.{None, Some}

pub fn main() -> Nil {
  gleeunit.main()
}

//**********
//* Result *
//**********

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

pub fn ok_error_test() {
  assert {
    use error_payload <- on.ok_error(
      Error("Max"),
      fn(e){e + 1 |> string.inspect},
    )
    error_payload <> error_payload
  } == "MaxMax"

  assert {
    use error_payload <- on.ok_error(
      Ok(3),
      fn(e){e + 1 |> string.inspect},
    )
    error_payload <> error_payload
  } == "4"
}

//********
//* Bool *
//********

pub fn false_true_test() {
  assert {
    use <- on.false_true(
      False,
      "Max",
    )
    "Sue"
  } == "Max"

  assert {
    use <- on.false_true(
      True,
      "Max",
    )
    "Sue"
  } == "Sue"
}

pub fn lazy_false_true_test() {
  assert {
    use <- on.lazy_false_true(
      False,
      fn() {"Max"},
    )
    "Sue"
  } == "Max"

  assert {
    use <- on.lazy_false_true(
      True,
      fn() {"Max"},
    )
    "Sue"
  } == "Sue"
}

pub fn true_false_test() {
  assert {
    use <- on.true_false(
      False,
      on_true: "Max",
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.true_false(
      True,
      on_true: "Max",
    )
    "Sue"
  } == "Max"
}

pub fn lazy_true_false_test() {
  assert {
    use <- on.lazy_true_false(
      False,
      fn() {"Max"},
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.lazy_true_false(
      True,
      fn() {"Max"},
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

pub fn none_some_test() {
  assert {
    use some_payload <- on.none_some(
      None,
      "Sue",
    )
    some_payload <> some_payload 
  } == "Sue"

  assert {
    use some_payload <- on.none_some(
      Some("Max"),
      "Sue",
    )
    some_payload <> some_payload 
  } == "MaxMax"
}

pub fn lazy_none_some_test() {
  assert {
    use some_payload <- on.lazy_none_some(
      None,
      fn(){"Sue"},
    )
    some_payload <> some_payload 
  } == "Sue"

  assert {
    use some_payload <- on.lazy_none_some(
      Some("Max"),
      fn(){"Sue"},
    )
    some_payload <> some_payload 
  } == "MaxMax"
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

//********
//* List *
//********

pub fn empty_nonempty_test() {
  assert {
    use first, _rest <- on.empty_nonempty(
      [],
      "Sue",
    )
    first <> first
  } == "Sue"

  assert {
    use first, _rest <- on.empty_nonempty(
      ["Max"],
      "Sue",
    )
    first <> first
  } == "MaxMax"
}

pub fn lazy_empty_nonempty_test() {
  assert {
    use first, _rest <- on.lazy_empty_nonempty(
      [],
      fn(){"Sue"},
    )
    first <> first
  } == "Sue"

  assert {
    use first, _rest <- on.lazy_empty_nonempty(
      ["Max"],
      fn(){"Sue"},
    )
    first <> first
  } == "MaxMax"
}

pub fn nonempty_empty_test() {
  assert {
    use <- on.nonempty_empty(
      [],
      fn(first, _rest){first <> first},
    )
    "Sue"
  } == "Sue"

  assert {
    use <- on.nonempty_empty(
      ["Max"],
      fn(first, _rest){first <> first},
    )
    "Sue"
  } == "MaxMax"
}
