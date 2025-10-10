# on

![logo](./logo.png)

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

```sh
gleam add on@1
```

The ‘on’ package consists of a collection of guards that can be 
paired with Gleam's `<- use` syntax. The package replicates some functions
from the Gleam stdlib under a uniform naming scheme.

## Overview

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

Note that 0-ary variants expect values
instead of values by default, following the convention 
of the Gleam stdlib. As in the standard
library as well, apply the `lazy_` prefix to access lazy
evaluation versions:

```gleam
on.lazy_none_some        // takes 0-ary callback instead of value for `on_none`
on.lazy_true_false       // takes 0-ary callback instead of value for `on_true`
on.lazy_false_true       // takes 0-ary callback instead of value for `on_false`
on.lazy_empty_nonempty   // takes 0-ary callback instead of value for `on_empty`
```

## One-variant shorthands

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

Etc. The list of all 1-callback API functions, excluding `on.continue`
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
of a boolean". An application might be a case where
some side-effect such as printing to I/O is desired for only one
half of a boolean value.)

## Ternary guards for List(a) values

At the other end of the spectrum 'on' provides API
functions that take three callbacks for `List(a)` values,
specifically to distinguish between the cases where a list
has 0, 1, or greater than 1 values, with the 
second and last being named as `singleton`, `gt1`
respectively in function names:

```gleam
on.empty_singleton_gt1
on.empty_gt1_singleton
on.singleton_gt1_empty

on.lazy_empty_singleton_gt1
on.lazy_empty_gt1_singleton
```

For example, `on.lazy_empty_singleton_gt1` has the 
following implementation and usage:

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

## Generic Return/Continue mechanism

The package also offers a one-size-fits-all guard named
`on.continue` that consumes a value of type `Return(a, b)`:

```gleam
// 'on' package

pub type Return(a, b) {
  Return(a)
  Continue(b)
}
```

Specifically, given a `Return(a, b)` value, `on.continue`
returns the `a`-payload if the value has the form `Return(a)`
or else applies a given callback of type `f(b) -> a` to the
`b`-payload if the value has the form `Continue(b)`:

```gleam
// 'on' package

pub fn continue(
  r: Return(a, b),
  on_continue f: fn(b) -> a,
) -> a {
  case r {
    Return(a) -> a
    Continue(b) -> f(b)
  }
}
```

This allows some many-valued variant to be sorted into
`Return` and `Continue` buckets; the restriction being that
all `Return` buckets contain the same type `a`, that all
`Continue` buckets contain the same type `b`, and that
code below the `on.continue` needs to resolve
to a value of type `a`, as well:

```gleam
// 'on' consumer
import on.{Continue, Return}

use b <- on.continue(
  case some_5_variant_thing() {
    Variant1(v1) -> Return(some_function_from_v1_type_to_a_type(v1))
    Variant2(v2) -> Return(some_function_from_v2_type_to_a_type(v2))
    Variant3(v3) -> Return(some_function_from_v3_type_to_a_type(v3))
    Variant4(v4) -> Continue(some_function_from_v3_type_to_b_type(v3))
    Variant5(v5) -> Continue(some_function_from_v4_type_to_b_type(v4))
  }
)

// ...down here, code that evaluates to type a with access to value
// b; this code only executes if some_5_variant_thing() is Variant4
// or Variant5
```

## See also

The [given](https://github.com/inoas/gleam-given) package
with a different variety of guards.

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

  use first, rest <- on.lazy_empty_nonempty(
    string.split(contents, "\n"),
    on_empty: fn() { io.println("empty contents") },
  )

  use <- on.lazy_false_true(
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
