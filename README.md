# on

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

A gleam package to keep code on the happy path with `<- use`.

```sh
gleam add on@1
```

A first example:

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
  s: String
) -> Result(#(Float, Option(CSSUnit)), Nil) {
  let #(before_unit, unit) = extract_css_unit(s)
  use number <- on.ok(parse_to_float(before_unit))
  Ok(#(number, unit))
}
```

A second example:

```gleam
import gleam/io
import gleam/string
import on
import simplifile

fn read_file(path: String) -> Result(String, String) {
  on.error(
    simplifile.read(path),
    on_error: fn(e) {Error("simplifile FileError: " <> string.inspect(e))},
  )
}

pub fn main() -> Nil {
  use contents <- on.error_ok(
    read_file("./sample.txt"),
    on_error: fn(msg) {io.println("\n" <> msg)}
  )

  use first, rest <- on.lazy_empty_nonempty(
    string.split(contents, "\n"),
    on_empty: fn() {io.println("empty contents")},
  )

  use <- on.lazy_false_true(
    string.trim(first) == "<!DOCTYPE html>",
    on_false: fn() {io.println("expecting DOCTYPE in first line")},
  )

  use parse_tree <- on.error_ok(
    parse_html(rest),
    on_error: fn(e) {println("parse error: " <> string.inspect(e))}
  )

  // ...
}
```

Further documentation can be found at <https://hexdocs.pm/on>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
