# on

![logo](./logo.png)

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

Ergonomic guards for the core gleam types to apply with the `<- use` syntax.

```sh
gleam add on@1
```

## Overview

All ‘on’ API functions adhere to the same pattern exemplified by `on.error_ok`:

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

A consumer of the package uses the API like so:

```gleam
// 'on' consumer

use ok_payload <- on.error_ok(
  some_result,
  fn (e) { /* map e to desired return value here */ },
)

// ...keep working with 'ok_payload' down here
```

Following the same pattern, 
`on.ok_error` allows the `Error` variant to
correspond to the happy path instead, by reversing
the order of callbacks:

```gleam
// 'on package

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

// 'on' consumer

use error_payload <- on.ok_error(
  some_result,
  fn (ok_payload) { /* map ok_payload to desired return value here */ },
)

// ...keep working with 'error_payload' down here
```

The complete list of similar two-variant guards provided by the
package is:

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

However, note that for 0-ary variants
the package expects a value instead of a callback, as eager evaluation
is considered default, as in the Gleam standard library. As in the standard
library, apply the `lazy_` prefix to access lazy evaluation versions:

```gleam
on.lazy_none_some           // (instead of on.none_some)
on.lazy_true_false          // (instead of on.true_false)
on.lazy_false_true          // (instead of on.false_true)
on.lazy_empty_nonempty      // (instead of on.empty_nonempty)
```

## Skipping variants for which the identity callback should be used

Specialized API functions whose names refer to
only one variant when the simple identity-like mapping (e.g. mapping
`None` variant of an `Option(a)` to the `None` variant of
an `Option(b)`) should be used for the second (elided) variant.

For example, `on.some` only expects one callback—the second defaults
to the identity(-like) mapping:

```gleam
// 'on' package

pub fn some(
  option: Option(a),
  on_some f2: fn(a) -> Option(c),
) -> Option(c) {
  case option {
    None -> None
    Some(a) -> f2(a)
  }
}
```

To be used like so:

```gleam
// 'on' consumer

use x <- on.some(option_value)

// work with payload x down here, in case option_value == Some(x);
// otherwise code has already returned None
```

Likewise, `on.ok` only expects a callback for the `Ok` payload:

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

To be used like so:

```gleam
// 'on' consumer

use a <- on.ok(result_value)

// work with payload x down here, in case result_value == Ok(a);
// otherwise code has already returned Error(b)
```

(This is isomorphic to `result.try` from the standard library.)

The list of all such 1-callback API functions is:

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
of a boolean". An application might be a case where
some side-effect such as printing to I/O is desired for only one
half of a boolean value.)

## Ternary variants for List(a) values

At the other end of the spectrum 'on' provides API
functions that take three callbacks for `List(a)` values,
specifically to distinguish between the cases where a list
has 0, 1, or greater than 1 values, with the 
second and last being named as `singleton`, `gt1`
respectively in function names.

In comporting with the pattern followed by other 'on' API functions, such
three-variant guards have names of the form `on.a_b_c` where `a`,
`b`, `c` list the variants in the same order as the callbacks.

The names of these functions are `empty_singleton_gt1`,
`empty_gt1_singleton`, and `singleton_gt1_empty`, together with their `lazy_`
varsions for the 0-ary `empty` variant:

```gleam
on.empty_singleton_gt1
on.empty_gt1_singleton
on.singleton_gt1_empty

on.lazy_empty_singleton_gt1
on.lazy_empty_gt1_singleton
```

For example, `on.lazy_empty_singleton_gt1` has the following implementation:

```gleam
// 'on' package

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
```

Its usage would look like:

```gleam
// 'on' consumer

use first, second, rest <- on.lazy_empty_singleton_gt1(
  some_list : List(a),
  fn() { /* ... */ },
  fn(some_element: a) { /* ... */ },
)

// keep working with first: a, second: a, and rest: List(a)
// down here
```

## Examples

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

  use first, rest <- on.lazy_empty_nonempty(
    string.split(contents, "\n"),
    on_empty: fn() { io.println("empty contents") },
  )

  use <- on.lazy_false_true(
    string.trim(first) == "<!DOCTYPE html>",
    on_false: fn() { io.println("expecting DOCTYPE in first line") },
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
  use <- on.true_false(
    string.ends_with(s, "rem"),
    on_true: #(string.drop_end(s, 3), Some(REM)),
  )

  use <- on.true_false(
    string.ends_with(s, "em"),
    on_true: #(string.drop_end(s, 2), Some(EM)),
  )

  use <- on.true_false(
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
