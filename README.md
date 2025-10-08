# on

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

Ergonomic guards for the core gleam types to apply with the `<- use` syntax.

```sh
gleam add on@1
```

All API calls in the package adhere to the same structure. Specifically, an 'on' API
call lists the types over which it maps in the function name, in the same order as
the arguments:

```
fn variant1_variant2_variant3(
  thing: Thing,
  on_variant1 f1: fn(variant1_payload) -> ...,
  on_variant2 f1: fn(variant2_payload) -> ...,
  on_variant3 f1: fn(variant3_payload) -> ...,
)
```

For example `on.error_ok`:

```
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

Symmetrically `on.ok_error`:

```
pub fn ok_error(
  result: Result(a, b),
  on_ok f1: fn(b) -> c,
  on_error f2: fn(a) -> c,
) -> c {
  case result {
    Error(b) -> f2(b)
    Ok(a) -> f1(a)
  }
}
```

Specifically, we would use `on.error_ok` to keep working with an `Ok()` payload, while
mapping and early-returning an `Error()` value:

```
use ok_payload <- on.error_ok(
  some_result,
  fn (e) { /* map e to desired return value here */ },
)

// keep working with 'ok_payload' down here
```

Symmetrically, `on.ok_error` would be used for cases where the `Ok`
variant can be early-returned after processing step, while `Error`
variant requires further processing.

Specialized guards may elide a variant when an identity-like mapping
is to be used on the elided variant. For example, `on.some` is the
version of `on.none_some` for which the `None` variant is mapped to
`None` [of an `Option(a)` to an `Option(b)`], 
while `on.ok` is the specialization of `on.error_ok` to the case
where the `on_error` that maps `Error(b)` to `Error(b)` [of a `Result(a, b)`
to a `Result(c, b)`]:

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

Note that `on.ok` is isomorphic to `result.try`.

Note that 'on' expects simple values, not 0-argument callbacks, for 0-ary variants by default. The `lazy_` version of the relevant API call (e.g., `on.lazy_none_some` instead of `on.none_some`) reverts to lazy evaluation via a 0-argument callback.

### Examples

#### Example 1

```gleam
import gleam/io
import gleam/string
import on
import simplifile

fn read_file(path: String) -> Result(String, String) {
  simplifile.read(path)
  |> result.map_error(
    fn(e) { "could not read '" <> path <> "' because of error '" <> string.inspect(e) <> "'" } 
  )
}

pub fn main() -> Nil {
  use contents <- on.error_ok(
    read_file("./sample.txt"),
    on_error: fn(msg) { io.println("\n" <> msg) }
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

#### Example 1

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
