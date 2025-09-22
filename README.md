# on

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

Ergonomic guards for the core gleam types to apply with the `<- use` syntax.

```sh
gleam add on@1
```

To be compared with the [given](https://hexdocs.pm/given/) package. While [given](https://hexdocs.pm/given/) uses truthiness-based semantics, [on](https://hexdocs.pm/on/) uses a "variantyness" -based approach.

To wit, the general [given](https://hexdocs.pm/given/) API call has the form and usage:

```
// 'given' package

fn statement_of_truthiness_about_thing(
  thing: Thing,
  else_return f1: fn(falsiness_payload) -> ...,   // what to compute if statement does not hold
  return f2: fn(truthiness_payload) -> ...,       // what to compute if statement holds
)
```

```
// usage

use truthiness_payload <- given.statement_of_truthiness_about_thing(
  some_thing(),
  what_to_do_with_falsiness_payload,              // the 'f1' from above
)

...
```

While for [on](https://hexdocs.pm/on/) the general form and usage is:

```
// 'on' package

fn variant1_variant2_variant3(
  thing: Thing,
  on_variant1 f1: fn(variant1_payload) -> ...,
  on_variant2 f1: fn(variant2_payload) -> ...,
  on_variant3 f1: fn(variant3_payload) -> ...,
)
```

```
// usage

use variant3_payload <- on.variant1_variant2_variant3(
  some_thing(),
  what_to_do_with_variant1_payload,
  what_to_do_with_variant2_payload,
)

...
```

Note that [on](https://hexdocs.pm/on/) expects values, not callbacks, for 0-ary variants. Use the `lazy_` version of the API call (e.g., `on.lazy_true_false` instead of `on.true_false`) if eager evaluation is problematic. (E.g., expensive or side-effectful.)

Variants are elided when mapped to themselves. E.g., `on.ok` is the specialized version of `on.error_ok` for which the `Error`-variant callback maps `Error(b)` to `Error(b)`. (I.e., `on.ok` is isomorphic to `result.try`.)

#### Example 1

```gleam
import gleam/io
import gleam/string
import on
import simplifile

fn read_file(path: String) -> Result(String, String) {
  simplifile.read(path)
  |> result.map_error(
    // map the error to an 'Error(String)'
    // one could also use 'on.error' instead of 'result.map_error'
    // as the two functions are isomorphic
    fn(e) { Error("simplifile FileError: " <> string.inspect(e)) } 
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
