# io_stream

[![Package Version](https://img.shields.io/hexpm/v/io_stream)](https://hex.pm/packages/io_stream)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/io_stream/)

Gleam package for working with file and standard io streams on Erlang and NodeJS.
> Note: Currently all text operations use UTF-8.

## Usage
Run this to add the package to your project by:
```sh
gleam add io_stream
```
Then you can read/write from files/stdio just like this:
```gleam
import io_stream

// A dumb example that stores user input from stdin into "input.txt".

pub fn main() -> Nil {
  let assert Ok(file) = io_stream.open_write("input.txt", False)
  let assert Ok(text) = io_stream.read_line(stdin())
  let assert Ok(Nil) = io_stream.write_string(file, text)
  let assert Ok(Nil) = io_stream.close(file)
  Nil
}
```

Documentation can be found at <https://hexdocs.pm/io_stream>.

Also you can look into [the test folder](./test/) to find more examples of how to use the package.
## Development

You can run tests on both Gleam and JS using:
```sh
./test.sh
```
## TODO

Some things that I might or might not add to the package in the future:
- Support for buffering
- Functions
  - read_string/read_chars
  - write_char
  - write_lines
  - tell
  - file_size