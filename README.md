# on

[![Package Version](https://img.shields.io/hexpm/v/on)](https://hex.pm/packages/on)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/on/)

```sh
gleam add on@1
```
```gleam
import gleam/io
import gleam/string
import on
import simplifile

fn read_file(path: String) -> Result(String, String) {
  use e <- on.error(simplifile.read(path))
  Error("simplifile FileError: " <> string.inspect(e))
}

pub fn main() -> Nil {
  use contents <- on.error_ok(
    read_file("./sample.txt"),
    on_error: fn(msg) {
      io.println("")
      io.println(msg)
    }
  )
  io.println("contents obtained:")
  io.println("")
  io.println(contents)
}
```

Further documentation can be found at <https://hexdocs.pm/on>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
