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

```
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

To be consumed like so:

```
// 'on' consumer

use ok_payload <- on.error_ok(
  some_result,
  fn (e) { /* map e to desired return value here */ },
)

// keep working with 'ok_payload' down here
```

By reversing the order of callbacks, `on.ok_error` allows the `Error()` value to
become the happy path:

```
use error_payload <- on.ok_error(
  some_result,
  fn (ok_payload) { /* map ok_payload to desired return value here */ },
)

// keep working with 'error_payload' down here
```

Similar two-variant API callbacks are provided not only for `Result`
but also for `Bool`, `Option` and `List` (the latter vis-à-vis empty- or
non-empty- lists):

```
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

For 0-ary variants (i.e. variants without a payload) eager evaluation
is used by default, as in the Gleam standard library. Use the `lazy_`
prefix to access lazy evaluation variants:

```
on.lazy_none_some           // instead of on.none_some
on.lazy_true_false          // instead of on.true_false
on.lazy_false_true          // instead of on.false_true
on.lazy_empty_nonempty      // instead of on.empty_nonempty
```

(The second callback always uses lazy evaluation since otherwise the
API function could not be used with the `use <-` syntax.)

## Eliding variants with identity mappings

Specialized API functions whose names refer to
only one variant when the simple identity-like mapping (e.g. mapping
`None` variant of an `Option(a)` to the `None` variant of
an `Option(b)`) should be used for the second (elided) variant.

For example `on.some`:

```
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

And `on.ok`:

```
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

The list of all such 1-callback API functions is:

```
on.ok        // maps Error(b) to Error(b)
on.error     // maps Ok(a) to Ok(a)
on.some      // maps None to None
on.none      // maps Some(a) to Some(a)
on.true      // maps False to False
on.false     // maps True to True
on.empty     // maps [first, ..rest] to [first, ..rest]
on.nonempty  // maps [] to []
```

(As such, `on.ok` is ismorphic to `result.try`.)

## Ternary variants for List(a) values

At the other extreme, the package provides some API
functions that take 3 instead of 2 callbacks, namely
for `List(a)` values. The callbacks 

## Examples

### Example 1

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

### Example 2

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
  use number <- on.ok(parse_to_float(before_unit))
  Ok(#(number, unit))
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
