import gleam/option.{type Option, Some, None}

// ************
// * Result/1 *
// ************

/// Given a Result(a, b) and a callback f(a) -> Result(c, b) applies
/// the callback if the Result has type Ok else maps the Error variant
/// of type Result(a, b) to the Error variant of type Result(c, b).
/// 
/// Equivalent to result.try and to error_ok(_, fn(e) -> {Error(e)}, _).
///
/// ### Example 1
///
/// ```gleam
/// use ok_payload <- on.ok(Ok(3))
/// // -> execution proceeds, ok_payload == 3; the current scope must
/// // return a Result(c, b) for some c, b
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use ok_payload <- on.ok(Error("Joe"))
/// // -> execution discontinues, scope returns Error("Joe")
/// ```
///
pub fn ok(
  result: Result(a, b),
  on_ok f2: fn(a) -> Result(c, b),
) -> Result(c, b) {
  case result {
    Error(e) -> Error(e)
    Ok(a) -> f2(a)
  }
}

/// Given a Result(a, b) and a callback f(b) -> Result(a, c) applies
/// the callback if the Result has type Error else maps the Ok variant
/// of type Result(a, b) to the Ok variant of type Result(c, b).
///
/// Equivalent to on.ok_error(_, fn(o) -> {Ok(o)}, _).
///
/// ### Example 1
///
/// ```gleam
/// use error_payload <- on.error(Ok(3))
/// // -> execution discontinues, scope returns Ok(3)
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use error_payload <- on.error(Error("Joe"))
/// // -> execution proceeds, error_payload == "Joe";
/// // the scope must return a Result(a, c)
/// ```
///
pub fn error(
  result: Result(a, b),
  on_error f2: fn(b) -> Result(a, c),
) -> Result(a, c) {
  case result {
    Ok(a) -> Ok(a)
    Error(e) -> f2(e)
  }
}

// ************
// * Result/2 *
// ************

/// Given a Result(a, b) and callbacks f(b) -> c, f(a) -> c 
/// returns the evaluation of the first callback at b1 if the
/// Result is Error(b1) and the evaluation of the second callback
/// at a1 if the Result is Ok(a1).
///
/// ### Example 1
/// 
/// ```gleam
/// use ok_payload <- on.error_ok(
///   Ok(3),
///   on_error: fn(e) { "hi " <> e <> "!" },
/// )
/// // -> execution proceeds, ok_payload == 3; the scope must return
/// // a String to match the return value of the on_error callback
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use ok_payload <- on.error_ok(
///   Error("Joe"),
///   on_error: fn(e) { "hi " <> e <> "!" },
/// )
/// // -> execution discontinues, scope returns "hi Joe!"
/// ```
///
pub fn error_ok(
  result: Result(a, b),
  on_error f1: fn(b) -> c,
  on_ok f2: fn(a) -> c,
) -> c {
  case result {
    Error(b) -> f1(b)
    Ok(a) -> f2(a)
  }
}

/// Given a Result(a, b) and callbacks f(b) -> c, f(a) -> c 
/// returns the evaluation of the first callback at a1 if the
/// Result is Ok(a1) and the evaluation of the second callback
/// at b1 if the Result is Error(b1).
///
/// ### Example 1
///
/// ```gleam
/// use error_payload <- on.ok_error(
///   Ok(3),
///   on_ok: fn(x) { x + 1 },
/// )
/// // -> execution discontinues, scope returns 4
/// ```
///
/// ### Example 2
/// 
/// ```gleam
/// use error_payload <- on.ok_error(
///   Error("Joe"),
///   on_ok: fn(x) { x + 1 },
/// )
/// // -> execution proceeds, error_payload == "Joe"; the scope
/// // must return an Int to match the return value of the on_ok
/// // callback
/// ```
///
pub fn ok_error(
  result: Result(a, b),
  on_ok f1: fn(a) -> c,
  on_error f2: fn(b) -> c,
) -> c {
  case result {
    Ok(a) -> f1(a)
    Error(b) -> f2(b)
  }
}

// **********
// * Bool/1 *
// **********

/// Given a Bool returns False if the bool is False, else
/// returns a lazily evaluated callback.
///
/// Equivalent to on.false_true(_, False, _).
///
/// ### Example 1
///
/// ```gleam
/// use <- on.true(True)
/// // -> execution proceeds, scope must return a Bool
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.true(False)
/// // -> execution discontinues, scope returns False
/// ```
///
pub fn true(
  bool: Bool,
  on_true f2: fn() -> Bool,
) -> Bool {
  case bool {
    False -> False
    True -> f2()
  }
}

/// Given a Bool returns True if the bool is True, else
/// returns a lazily evaluated callback.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.false(True)
/// // -> execution discontinues, scope returns True
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.false(False)
/// // -> execution proceeds, scope must return a Bool
/// ```
///
pub fn false(
  bool: Bool,
  on_false f2: fn() -> Bool,
) -> Bool {
  case bool {
    True -> True
    False -> f2()
  }
}

// **********
// * Bool/2 *
// **********

/// Given a Bool, a value of type c and a callback f() -> c,
/// returns the value of type c if the bool is False, else the
/// evaluation of the callback.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.false_true(
///   True,
///   on_false: "Joe",
/// )
/// // -> execution proceeds, the scope must return a String to 
/// // match the return value of the on_false argument
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.false_true(
///   False,
///   on_false: "Joe",
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
///
pub fn false_true(
  bool: Bool,
  on_false c: c,
  on_true f2: fn() -> c,
) -> c {
  case bool {
    False -> c
    True -> f2()
  }
}

/// Given a Bool and two callbacks f() -> c returns the
/// evaluation of the first callback if the bool is False,
/// else the second callback.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.lazy_false_true(
///   True,
///   on_false: fn() { "Joe" },
/// )
/// // -> execution proceeds, the scope must return a String 
/// // to match the return value of the on_false argument
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.lazy_false_true(
///   False,
///   on_false: fn() { "Joe" },
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
///
pub fn lazy_false_true(
  bool: Bool,
  on_false f1: fn() -> c,
  on_true f2: fn() -> c,
) -> c {
  case bool {
    False -> f1()
    True -> f2()
  }
}

/// Given a Bool, a value of type c and a callback f() -> c, 
/// returns the value of type c if the bool is True, else the
/// evaluation of the callback.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.true_false(
///   True,
///   on_true: "Joe",
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
///
/// ### Example 2
/// 
/// ```gleam
/// use <- on.true_false(
///   False,
///   on_true: "Joe",
/// )
/// // -> execution proceeds, the scope must return a String to 
/// // match the return value of the on_true argument
/// ```
///
pub fn true_false(
  bool: Bool,
  on_true c: c,
  on_false f2: fn() -> c,
) -> c {
  case bool {
    True -> c
    False -> f2()
  }
}

/// Given a Bool and two callbacks f() -> c returns the
/// evaluation of the first callback if the bool is True,
/// else the second callback.
///
///
/// ### Example 1
///
/// ```gleam
/// use <- on.lazy_true_false(
///   True,
///   on_true: fn() { "Joe" },
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.lazy_true_false(
///   False,
///   on_true: fn() { "Joe" },
/// )
/// // -> execution proceeds, the scope must return a String to 
/// // match the return value of the on_false argument
/// ```
///
pub fn lazy_true_false(
  bool: Bool,
  on_true f1: fn() -> c,
  on_false f2: fn() -> c,
) -> c {
  case bool {
    True -> f1()
    False -> f2()
  }
}

// ************
// * Option/1 *
// ************

/// Given an Option(a) and a callback f(a) -> Option(c)
/// applies the callback to the payload a if the option is Some(a),
/// else returns None.
///
/// Equivalent to:
/// - on.none_some(_, None, _).
/// - option.then
/// 
/// ### Example 1
///
/// ```gleam
/// use payload <- on.some(Some(3))
/// // -> execution proceeds, payload == 3; the scope must return
/// // an Option(c)
/// ```
///
/// ### Example 2
/// 
/// ```gleam
/// use payload <- on.some(None)
/// // -> execution discontinues, scope returns None
/// ```
///
pub fn some(
  option: Option(a),
  on_some f2: fn(a) -> Option(c),
) -> Option(c) {
  case option {
    None -> None
    Some(a) -> f2(a)
  }
}

/// Given an Option(a) and a callback f() -> Option(a), applies
/// the callback if the option is None, else returns the option
/// unchanged.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.none(Some(3))
/// // -> execution discontinues, scope returns Some(3)
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.none(None)
/// // -> execution proceeds, the scope must return an Option(a)
/// ```
///
pub fn none(
  option: Option(a),
  on_none f2: fn() -> Option(a),
) -> Option(a) {
  case option {
    Some(a) -> Some(a)
    None -> f2()
  }
}

// ************
// * Option/2 *
// ************

/// Given an Option(a), a value of type c and a callback f(a) -> c, 
/// returns the value of type c if the option is None, else
/// applies the callback to the option's payload.
///
/// ## Examples
///
/// ```gleam
/// use payload <- on.none_some(
///   Some(3),
///   on_none: "Bob",
/// )
/// // -> execution proceeds, payload == 3; the scope must return a
/// // String to match the return value of the on_none return value
/// ```
///
/// ```gleam
/// use payload <- on.none_some(
///   None,
///   on_none: "Bob",
/// )
/// // -> execution discontinues, scope returns "Bob"
/// ```
///
pub fn none_some(
  option: Option(a),
  on_none c: c,
  on_some f2: fn(a) -> c,
) -> c {
  case option {
    None -> c
    Some(a) -> f2(a)
  }
}

/// Given an Option(a), a callback f() -> c and a callback
/// f(a) -> c evaluates the first callback if the option is
/// None, else evaluates the second callback on the option's
/// payload.
///
/// ### Example 1
///
/// ```gleam
/// use payload <- on.lazy_none_some(
///   Some(3),
///   on_none: fn() { "Bob" },
/// )
/// // -> execution proceeds, payload == 3; the scope must return
/// // a String to match the return value of the on_none return
/// // value
/// ```
///
/// ### Example 2
/// 
/// ```gleam
/// use payload <- on.lazy_none_some(
///   None,
///   on_none: fn() { "Bob" },
/// )
/// // -> execution discontinues, scope returns "Bob"
/// ```
///
pub fn lazy_none_some(
  option: Option(a),
  on_none f1: fn() -> c,
  on_some f2: fn(a) -> c,
) -> c {
  case option {
    None -> f1()
    Some(a) -> f2(a)
  }
}

/// Given an Option(a), a callback f(a) -> c and a callback
/// f() -> c, evaluates the first callback on the option's
/// payload, else evaluates the second callback if the option
/// is None.
///
/// ### Example 1
///
/// ```gleam
/// use <- on.some_none(
///   Some(3),
///   on_some: fn(x) { x + 1 },
/// )
/// // -> execution discontinues, scope returns 4
/// ```
///
/// ### Example 2
///
/// ```gleam
/// use <- on.some_none(
///   None,
///   on_some: fn(x) { x + 1 },
/// )
/// // -> execution proceeds, the scope must return an Int to match
/// // the return value of the on_some return value
/// ```
///
pub fn some_none(
  option: Option(a),
  on_some f1: fn(a) -> c,
  on_none f2: fn() -> c,
) -> c {
  case option {
    Some(a) -> f1(a)
    None -> f2()
  }
}

// **********
// * List/1 *
// **********

/// Given a List(a) and a callback
/// f(a, List(a)) -> List(c), returns the empty list if the
/// list is empty, else evaluates the callback on (first, rest)
/// where 'first' is the first element and 'tail' is the tail of 
/// the list.
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first, rest <- on.nonempty([1, 4, 7])
/// // -> execution proceeds, first == 1, rest == [1, 7];
/// // scope must return a List(c)
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, rest <- on.nonempty([])
/// // -> execution discontinues, scope returns []
/// ```
/// 
pub fn nonempty(
  list: List(a),
  on_nonempty f2: fn(a, List(a)) -> List(c),
) -> List(c) {
  case list {
    [] -> []
    [first, ..rest] -> f2(first, rest)
  }
}

/// Given a List(a) and a callback f() -> List(a)
/// returns the list if the is nonempty, else evaluates
/// the callback.
///
/// ### Example 1
/// 
/// ```gleam
/// use <- on.empty([1, 4, 7])
/// // -> execution discontinues, scope returns [1, 4, 7]
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use <- on.empty([])
/// // -> execution proceeds, the scope must return a List(c)
/// ```
/// 
pub fn empty(
  list: List(a),
  on_empty f2: fn() -> List(a),
) -> List(a) {
  case list {
    [_, .._] -> list
    [] -> f2()
  }
}

// **********
// * List/2 *
// **********

/// Given a List(a), a value of type c, and callback
/// f(a, List(a)) -> c, returns either the value of type c
/// if the list is empty or else applies the callback to 
/// the head: a and tail: List(a) of the list.
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first, rest <- on.empty_nonempty(
///   [1, 4, 7],
///   on_empty: "Joe",
/// )
/// // -> execution proceeds, first == 1, rest == [4, 7];
/// // scope must return a String to match the empty list
/// // return value
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, rest <- on.empty_nonempty(
///   [],
///   on_empty: "Joe",
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
/// 
pub fn empty_nonempty(
  list: List(a),
  on_empty c: c,
  on_nonempty f2: fn(a, List(a)) -> c,
) -> c {
  case list {
    [] -> c
    [first, ..rest] -> f2(first, rest)
  }
}

/// Given a List(a), a callback fn() -> c and a callback
/// f(a, List(a)) -> c, evaluates the first callback if the
/// list is empty else applies the second callback to the
/// head: a and tail: List(a) of the list.
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first, rest <- on.lazy_empty_nonempty(
///   [1, 4, 7],
///   on_empty: fn() { "Joe" },
/// )
/// // -> execution proceeds, first == 1, rest == [4, 7];
/// // scope must return a String to match the empty list
/// // callback return value
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, rest <- on.lazy_empty_nonempty(
///   [],
///   on_empty: fn() { "Joe" },
/// )
/// // -> execution discontinues, scope returns "Joe"
/// ```
/// 
pub fn lazy_empty_nonempty(
  list: List(a),
  on_empty f1: fn() -> c,
  on_nonempty f2: fn(a, List(a)) -> c,
) -> c {
  case list {
    [] -> f1()
    [first, ..rest] -> f2(first, rest)
  }
}

/// Given a List(a), a callback  f(a, List(a)) -> c, and
/// a callback f() -> c, returns either the first callback
/// evaluated on the first element and tail of the list if
/// the list is nonempty, and otherwise evaluates the 
/// second callback, if the list is empty. 
/// 
/// ### Example 1
/// 
/// ```gleam
/// use <- on.nonempty_empty(
///   [1, 4, 7],
///   fn(first, _rest) { first + 1 },
/// )
/// // -> execution discontinues, scope returns 2
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use <- on.nonempty_empty(
///   [],
///   fn(first, _rest) { first + 1 },
/// )
/// // -> execution proceeds, the scope must return an
/// // integer to match the return value of the first
/// // callback
/// ```
/// 
pub fn nonempty_empty(
  list: List(a),
  on_nonempty f1: fn(a, List(a)) -> c,
  on_empty f2: fn() -> c,
) -> c {
  case list {
    [first, ..rest] -> f1(first, rest)
    [] -> f2()
  }
}

// **********
// * List/3 *
// **********

/// Given a List(a), a value of type c, and callbacks
/// f(a) -> c, f(a, a, List(a)) -> c, returns:
///
/// - the value of type c if the list is empty
/// - the first callback evaluated with argument a1 if the list as the form [a1]
/// - the second callback evaluated with arguments a1, a2, rest if the list has the form [a1, a2, ..rest]
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first, second, ..rest <- on.empty_singleton_gt1(
///   [1, 4, 7],
///   on_empty: 0,
///   on_singleton: fn(first) { first },
/// )
/// // -> execution proceeds, first == 1, second == 4, rest == [7];
/// // scope must return an Int to match the on_empty, on_singleton callbacks
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, second, ..rest <- on.empty_singleton_gt1(
///   [4],
///   on_empty: 0,
///   on_singleton: fn(first) { first },
/// )
/// // -> execution discontinues, scope resturns 4
/// ```
/// 
pub fn empty_singleton_gt1(
  list: List(a),
  on_empty c: c,
  on_singleton f2: fn(a) -> c,
  on_gt1 f3: fn(a, a, List(a)) -> c,
) -> c {
  case list {
    [] -> c
    [first] -> f2(first)
    [first, second, ..rest] -> f3(first, second, rest)
  }
}

/// Given a List(a), and callbacks f() -> c, f(a) -> c,
/// f(a, a, List(a)) -> c, returns:
///
/// - the evaluation of the first callback if the list is empty
/// - the second callback evaluated with argument a1 if the list as the form [a1]
/// - the third callback evaluated with arguments a1, a2, rest if the list has the form [a1, a2, ..rest]
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first, second, ..rest <- on.lazy_empty_singleton_gt1(
///   [1, 4, 7],
///   on_empty: 0,
///   on_singleton: fn(first) { first },
/// )
/// // -> execution proceeds, first == 1, second == 4, rest == [7];
/// // scope must return an Int to match the on_empty, on_singleton callbacks
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, second, ..rest <- on.lazy_empty_singleton_gt1(
///   [4],
///   on_empty: 0,
///   on_singleton: fn(first) { first },
/// )
/// // -> execution discontinues, scope resturns 4
/// ```
/// 
pub fn lazy_empty_singleton_gt1(
  list: List(a),
  on_empty f1: fn() -> c,
  on_singleton f2: fn(a) -> c,
  on_gt1 f3: fn(a, a, List(a)) -> c,
) -> c {
  case list {
    [] -> f1()
    [first] -> f2(first)
    [first, second, ..rest] -> f3(first, second, rest)
  }
}

/// Given a List(a), a value of type c, and callbacks
/// f(a, a, List(a)) -> c, f(a) -> c, returns:
///
/// - the value of type c if the list is empty
/// - the first callback evaluated with arguments a1, a2, rest if the list has the form [a1, a2, ..rest]
/// - the second callback evaluated with argument a1 if the list as the form [a1]
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first <- on.empty_gt1_singleton(
///   [1, 4, 7],
///   on_empty: Error("empty list"),
///   on_gt1: Error("> 1 element in list"),
/// )
/// // -> execution discontinues, scope returns Error("> 1 element in list")
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first <- on.empty_gt1_singleton(
///   [4],
///   on_empty: Error("empty list"),
///   on_gt1: Error("> 1 element in list"),
/// )
/// // -> execution proceeds, first == 4;
/// // scope must return a Result(c, String) to match the on_empty 
/// // and on_gt1 callbacks
/// ```
/// 
pub fn empty_gt1_singleton(
  list: List(a),
  on_empty c: c,
  on_gt1 f2: fn(a, a, List(a)) -> c,
  on_singleton f3: fn(a) -> c,
) -> c {
  case list {
    [] -> c
    [first, second, ..rest] -> f2(first, second, rest)
    [first] -> f3(first)
  }
}

/// Given a List(a) and callbacks f() -> c,
/// f(a, a, List(a)) -> c, f(a) -> c, returns:
///
/// - the evaluation of the first callback if the list is empty
/// - the second callback evaluated with arguments a1, a2, rest if the list has the form [a1, a2, ..rest]
/// - the third callback evaluated with argument a1 if the list as the form [a1]
/// 
/// ### Example 1
/// 
/// ```gleam
/// use first <- on.lazy_empty_gt1_singleton(
///   [1, 4, 7],
///   on_empty: Error("empty list"),
///   on_gt1: fn(_, _, _) {Error("> 1 element in list")},
/// )
/// // -> execution discontinues, scope returns Error("> 1 element in list")
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first <- on.lazy_empty_gt1_singleton(
///   [4],
///   on_empty: Error("empty list"),
///   on_gt1: Error("> 1 element in list"),
/// )
/// // -> execution proceeds, first == 4;
/// // scope must return a Result(c, String) to match the on_empty 
/// // and on_gt1 callbacks
/// ```
/// 
pub fn lazy_empty_gt1_singleton(
  list: List(a),
  on_empty f1: fn() -> c,
  on_gt1 f2: fn(a, a, List(a)) -> c,
  on_singleton f3: fn(a) -> c,
) -> c {
  case list {
    [] -> f1()
    [first, second, ..rest] -> f2(first, second, rest)
    [first] -> f3(first)
  }
}

/// Given a List(a) and callbacks f(a) -> c,
/// f(a, a, List(a)) -> c, f() -> c, returns:
///
/// - the first callback evaluated with argument a1 if the list as the form [a1]
/// - the second callback evaluated with arguments a1, a2, rest if the list has the form [a1, a2, ..rest]
/// - the evaluation of the third callback if the list is empty
/// 
/// ### Example 1
/// 
/// ```gleam
/// use <- on.singleton_gt1_empty(
///   [1, 4, 7],
///   on_singleton: fn(x) { x + 1 },
///   on_gt1: fn(first, second, ..rest) { first + second},
/// )
/// // -> execution discontinues, scope returns 5 (= 1 + 4)
/// ```
/// 
/// ### Example 2
/// 
/// ```gleam
/// use first, second, ..rest <- on.singleton_gt1_empty(
///   [],
///   on_singleton: fn(x) { x + 1 },
///   on_gt1: fn(first, second, ..rest) { first + second},
/// )
/// // -> execution proceeds, scope must return an Int to 
/// // match the on_singleton, on_gt1 callbacks
/// 
/// ```
/// 
pub fn singleton_gt1_empty(
  list: List(a),
  on_singleton f1: fn(a) -> c,
  on_gt1 f2: fn(a, a, List(a)) -> c,
  on_empty f3: fn() -> c,
) -> c {
  case list {
    [first] -> f1(first)
    [first, second, ..rest] -> f2(first, second, rest)
    [] -> f3()
  }
}

// ****************
// * Return(a, b) *
// ****************

/// A choice type whose semantics indicate intent to return from local
/// scope or not, to be paired with 'on.continue'.
pub type Return(a, b) {
  Return(a)
  Continue(b)
}

/// Given a value of type Return(a, b) and a callback f(b) -> a, returns
/// f(b1) if the value has the form Continue(b1) and returns a1
/// if the value has the form Return(a1).
/// 
/// ### Example 1
///
/// ```gleam
/// let #(string1, string2) = #("bob", "")
/// use _ <- on.continue(case string {
///   "" -> Return(#(string1, string1))
///   _ -> Continue(Nil)
/// })
/// // -> execution discontinues, scope returns #("bob", "bob")
/// ```
///
/// ### Example 2
///
/// ```gleam
/// let #(string1, string2) = #("bob", "alice")
/// use _ <- on.continue(case string {
///   "" -> Return(#(string1, string1))
///   _ -> Continue(Nil)
/// })
/// // -> execution proceeds; the current scope must return a
/// // #(String, String)
/// ```
///
pub fn continue(
  r: Return(a, b),
  on_continue f1: fn(b) -> a,
) -> a {
  case r {
    Return(a) -> a
    Continue(b) -> f1(b)
  }
}
