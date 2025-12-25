# on

![logo](./logo.png)

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

```
gleam add on@2
```

The ‘on’ package consists of a collection of guards that can be 
paired with Gleam's `<- use` syntax. The package replicates some functions
from the Gleam stdlib under a uniform naming scheme.

## Breaking Changes in V2.0.0

V2.0.0 switches to lazy-by-default escape values. The `lazy_` prefix is no longer a thing, while
the `eager_` prefix becomes a thing.

The second breaking change in V2.0.0 is that `type Return(a, b) { Return(a) Continue(b) }` has been
replaced by `type Return(a, b) { Return(a) Select(b) }`, with `on.continue`
renamed to `on.select`. This change was made because `Select` has the same number of characters as `Return`
and because the author had an irrational aesthetics-based prejudice against the `Continue`
variant name.

## API Overview

All package functions adhere to the same pattern as:

```gleam
// 'on' package

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
```

With corresponding usage:

```gleam
// 'on' consumer

use ok_payload <- on.error_ok(
  some_result,
  on_error: fn (error_payload) { /* map error_payload to desired return value here */ },
)

// ...keep working with 'ok_payload' down here
```

Symmetrically, for example,
`on.ok_error` allows the `Error` variant to
correspond to the happy path instead; per the
consumer:

```gleam
// 'on' consumer

use error_payload <- on.ok_error(
  some_result,
  on_ok: fn (ok_payload) { /* map ok_payload to desired return value here */ },
)

// ...keep working with 'error_payload' down here
```

The package contains similar two-variant guards for `Bool`, `Option`
and `List`:

```gleam
// Result
on.error_ok
on.ok_error

// Option
on.none_some
on.some_none

// Bool
on.true_false
on.false_true

// List
on.empty_nonempty
on.nonempty_empty
```

E.g., usage of `empty_nonempty`:

```gleam
// 'on' consumer

use first, rest <- on.empty_nonempty(
  some_list(),   // type List(a)
  on_empty: fn() { /* create return value for empty case here */ }
)

// ...work down here with first: a and rest: List(a), in the
// case where the list is nonempty
```

Values can be provided instead of callbacks by using the `eager_` prefix.
Specifically, the call names are:

```gleam
on.eager_none_some        // takes a value instead of a 0-ary callback for `on_none`
on.eager_true_false       // takes a value instead of a 0-ary callback for `on_true`
on.eager_false_true       // takes a value instead of a 0-ary callback for `on_false`
on.eager_empty_nonempty   // takes a value instead of a 0-ary callback for `on_empty`
```

For example:

```gleam
// 'on' consumer

use first, rest <- on.eager_empty_nonempty(
  some_list(),   // type List(a)
  on_empty: Error("empty list")
)

// ...work down here with first: a and rest: List(a), in the
// case where the list is nonempty; we must return a Result(b, String)
// to match the `on_empty` return value
```

The API also offers `eager_` variants (no pun intended) for variants that payloads, as well, i.e.,
to replace callbacks that would take an argument with a precomputed value.
For example `on.eager_error_ok`:

```gleam
// 'on' package

pub fn eager_error_ok(
  result: Result(a, b),
  on_error c,
  on_ok f2: fn(a) -> c,
) -> c {
  case result {
    Error(_) -> c
    Ok(a) -> f2(a)
  }
}
```

Of usage:

```gleam
// 'on' consumer

use ok_payload <- on.eager_error_ok(some_result, None)

// ...keep working with 'ok_payload' down here,
// while the Error case has been escaped with a None return value
// (and this scope must return an Option(a), to match the None)
```

## Single-variant shorthands

Specialized API functions have names that refer to
only one variant when the simple identity-like mapping (e.g. mapping
`None` variant of an `Option(a)` to the `None` variant of
an `Option(b)`) should be used for the second (elided) variant.

For example, `on.some` only expects one callback—the second
callback
defaults to mapping a `None: Option(a)` to a `None: Option(b)`:

```gleam
// 'on' package

pub fn some(
  option: Option(a),
  on_some f2: fn(a) -> Option(b),
) -> Option(b) {
  case option {
    None -> None
    Some(a) -> f2(a)
  }
}
```

E.g.:

```gleam
// 'on' consumer

use x <- on.some(option_value)

// work with payload x down here, in case option_value == Some(x);
// otherwise code has already returned None
```

Similarly, `on.ok` only expects a callback for the `Ok` payload:

```gleam
// 'on' package

pub fn ok(
  result: Result(a, b),
  on_ok f2: fn(a) -> Result(c, b),
) -> Result(c, b) {
  case result {
    Error(b) -> Error(b)
    Ok(a) -> f2(a)
  }
}
```

E.g.:

```gleam
// 'on' consumer

use x <- on.ok(result_value)

// work with payload x down here, in case result_value == Ok(x);
// otherwise code has already returned Error(b)
```

(One can note that `on.ok` is isomorphic to `result.try` from the standard library.)

Etc. The list of all 1-callback API functions, excluding `on.select`
discussed below, is:

```gleam
on.ok        // maps Error(b) to Error(b)
on.error     // maps Ok(a) to Ok(a)
on.some      // maps None to None
on.none      // maps Some(a) to Some(a)
on.true      // maps False to False
on.false     // maps True to True
on.empty     // maps [first, ..rest] to [first, ..rest]
on.nonempty  // maps [] to []
```

(Note that `on.true` and `on.false` are expected to get
less use as it is somewhat unusual to want to early-return only "one half
of a boolean". But there might be a case where
some side-effect such as printing to I/O is desired for only one
half of a boolean value.)

## Ternary guards for List(a) values

At the other end of the spectrum 'on' provides API
functions that take three callbacks for `List(a)` values,
specifically to distinguish between the cases where a list
has 0, 1, or greater than 1 values, with the 
second and last being named as `singleton`, `gt1`
respectively in function names. Including all of the
`eager_` variants this API consists of:

```gleam
on.empty_singleton_gt1
on.empty_gt1_singleton
on.singleton_gt1_empty

on.eager_empty_singleton_gt1
on.empty_eager_singleton_gt1
on.eager_empty_eager_singleton_gt1

on.eager_empty_gt1_singleton
on.empty_eager_gt1_singleton
on.eager_empty_eager_gt1_singleton

on.eager_singleton_gt1_empty
on.singleton_eager_gt1_empty
on.eager_singleton_eager_gt1_empty
```

For example, `on.empty_singleton_gt1` has the 
following implementation and usage:

```gleam
// 'on' package

pub fn empty_singleton_gt1(
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
```

```gleam
// 'on' consumer

use first, second, rest <- on.empty_singleton_gt1(
  some_list : List(a),
  fn() { /* ... */ },
  fn(some_element: a) { /* ... */ },
)

// keep working with first: a, second: a, and rest: List(a)
// down here
```

## Generic Return/Select (previously 'Return/Continue') mechanism

The package also offers a one-size-fits-all guard named
`on.select` that consumes a value of type `Return(a, b)`, defined as:

```gleam
// 'on' package

pub type Return(a, b) {
  Return(a)
  Select(b)
}
```

Specifically, given a `Return(a, b)` value, `on.select`
returns the `a`-payload if the value has the form `Return(a)`
or else applies a given callback of type `f(b) -> a` to the
`b`-payload if the value has the form `Select(b)`:

```gleam
// 'on' package

pub fn select(
  r: Return(a, b),
  on_select f: fn(b) -> a,
) -> a {
  case r {
    Return(a) -> a
    Select(b) -> f(b)
  }
}
```

This allows some many-valued variant to be sorted into
`Return` and `Select` buckets; the restriction being that
all `Return` buckets contain a payload of same type `a`, that all
`Select` buckets contain a payload of same type `b`, and that
the code below the `on.select` resolves
to a value of type `a`, as well:

```gleam
// 'on' consumer
import on.{Select, Return}

use b <- on.select(
  case some_5_variant_thing() {
    Variant1(v1) -> Return( /* construct value of type a from v1 here */ )
    Variant2(v2) -> Return( /* construct value of type a from v2 here */ )
    Variant3(v3) -> Return( /* construct value of type a from v3 here */ )
    Variant4(v4) -> Select( /* construct value of type b from v4 here */ )
    Variant5(v5) -> Select( /* construct value of type b from v5 here */ )
  }
)

// ...down here, code that evaluates to type a with access to value
// b; this code only executes if some_5_variant_thing() is Variant4
// or Variant5
```

## See also

The [given](https://github.com/inoas/gleam-given) package
with a simpler variety of guards. (But that may lead to less
overengineering and overthinking.)

## Table: Comparison with stdlib guards and [given](https://github.com/inoas/gleam-given)

```
on                            stdlib                     given
=============================================================================
// 1-callback guards:

on.ok                         result.try                 --
on.error                      result.try_recover         --
on.some                       option.then                --
on.none                       --                         --
on.true                       --                         --
on.false                      --                         --
on.empty                      --                         --
on.nonempty                   --                         --
on.select                     --                         --

// 2-callback guards lazy versions:

on.error_ok                   --                         given.ok
on.ok_error                   --                         given.error
on.none_some                  --                         given.some
on.some_none                  --                         given.none
on.true_false                 bool.lazy_guard            given.that
on.false_true                 --                         given.not
on.empty_nonempty             --                         given.non_empty
on.nonempty_empty             --                         given.empty
--                            --                         given.any       // (for List(Bool) value)
--                            --                         given.all       // (for List(Bool) value)
--                            --                         given.any_not   // (for List(Bool) value)
--                            --                         given.all_not   // (for List(Bool) value)
--                            --                         given.when      // (for fn() -> Bool value)
--                            --                         given.when_not  // (for fn() -> Bool value)
--                            --                         given.any_ok    // (for List(Result) value)
--                            --                         given.all_ok    // (for List(Result) value)
--                            --                         given.any_error // (for List(Result) value)
--                            --                         given.all_error // (for List(Result) value)
--                            --                         given.any_some  // (for List(Option) value)
--                            --                         given.all_some  // (for List(Option) value)
--                            --                         given.any_none  // (for List(Option) value)
--                            --                         given.all_none  // (for List(Option) value)

// 2-callback guards eager versions:

on.eager_error_ok             --                         --
on.eager_ok_error             --                         --
on.eager_none_some            --                         --
on.eager_some_none            --                         --
on.eager_true_false           bool.guard                 --
on.eager_false_true           --                         --
on.eager_empty_nonempty       --                         --
on.eager_nonempty_empty       --                         --

// 3-callback guards lazy versions:

on.empty_singleton_gt1        --                         --
on.empty_gt1_singleton        --                         --
on.singleton_gt1_empty        --                         --

// 3-callback guards mized eager/lazy:

on.eager_empty_singleton_gt1  --                         --
on.empty_eager_singleton_gt1  --                         --
on.eager_empty_gt1_singleton  --                         --
on.empty_eager_gt1_singleton  --                         --
on.eager_singleton_gt1_empty  --                         --
on.singleton_eager_gt1_empty  --                         --

// 3-callback guards doubly eager:

on.eager_empty_eager_singleton_gt1        --             --
on.eager_empty_eager_gt1_singleton        --             --
on.eager_singleton_eager_gt1_empty        --             --
```

## Additional Examples

```gleam
import gleam/io
import gleam/string
import on
import simplifile

pub fn main() -> Nil {
  use contents <- on.error_ok(
    simplifile.read("./sample.txt"),
    on_error: fn(e) { io.println("simplifile.read error: " <> string.inspect(e)) }
  )

  use first, rest <- on.empty_nonempty(
    string.split(contents, "\n"),
    on_empty: fn() { io.println("empty contents") },
  )

  use <- on.false_true(
    string.trim(first) == "<!DOCTYPE html>",
    on_false: fn() { io.println("expecting vanilla DOCTYPE in first line") },
  )

  use parse_tree <- on.error_ok(
    parse_html(rest),
    on_error: fn(e) { println("html parse error: " <> string.inspect(e)) },
  )

  // ...
}
```

```gleam
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import on

type CSSUnit {
  PX
  REM
  EM
}

fn extract_css_unit(s: String) -> #(String, Option(CSSUnit)) {
  use <- on.eager_true_false(
    string.ends_with(s, "rem"),
    on_true: #(string.drop_end(s, 3), Some(REM)),
  )

  use <- on.eager_true_false(
    string.ends_with(s, "em"),
    on_true: #(string.drop_end(s, 2), Some(EM)),
  )

  use <- on.eager_true_false(
    string.ends_with(s, "px"),
    on_true: #(string.drop_end(s, 2), Some(PX)),
  )

  #(s, None)
}

fn parse_to_float(s: String) -> Result(Float, Nil) {
  case float.parse(s), int.parse(s) {
    Ok(number), _ -> Ok(number)
    _, Ok(number) -> Ok(int.to_float(number))
    _, _ -> Error(Nil)
  }
}

pub fn parse_number_and_optional_css_unit(
  s: String,
) -> Result(#(Float, Option(CSSUnit)), Nil) {
  let #(before_unit, unit) = extract_css_unit(s)
  use number <- on.ok(parse_to_float(before_unit))      // on.ok === result.try
  Ok(#(number, unit))
}
```
