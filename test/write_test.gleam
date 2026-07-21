import gleam/list
import gleeunit/should
import io_streams
import io_streams/errors
import io_streams_test

fn write_text(path: String, text: String) {
  let assert Ok(stream) = io_streams.open_write(path, False)
  let assert Ok(_) = io_streams.write_string(stream, text)
  let assert Ok(_) = io_streams.close(stream)
}

fn write_lines(path: String, lines: List(String)) {
  let assert Ok(stream) = io_streams.open_write(path, False)
  lines
  |> list.each(fn(line) {
    let assert Ok(_) = io_streams.write_line(stream, line)
  })
  let assert Ok(_) = io_streams.close(stream)
}

fn write_bin(path: String, bytes: BitArray) {
  let assert Ok(stream) = io_streams.open_write_bin(path, False)
  let assert Ok(_) = io_streams.write_bytes(stream, bytes)
  let assert Ok(_) = io_streams.close(stream)
}

fn read_line(path: String) -> String {
  let assert Ok(stream) = io_streams.open_read(path)
  let assert Ok(line) = io_streams.read_line(stream)
  let assert Ok(_) = io_streams.close(stream)
  line
}

pub fn write_string_test() {
  let file = io_streams_test.path("write_string.txt")

  let assert Ok(stream) = io_streams.open_write(file, False)
  let assert Ok(_) = io_streams.write_string(stream, "Hello")
  let assert Ok(_) = io_streams.write_string(stream, " World")
  let assert Ok(_) = io_streams.close(stream)

  should.equal(read_line(file), "Hello World")
}

pub fn write_line_test() {
  let file = io_streams_test.path("write_line_twice.txt")

  let _ = write_lines(file, ["Hello", "World"])

  let assert Ok(stream) = io_streams.open_read(file)
  let assert Ok(first) = io_streams.read_line(stream)
  let assert Ok(second) = io_streams.read_line(stream)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(first, "Hello\n")
  should.equal(second, "World\n")
}

pub fn write_empty_line_test() {
  let file = io_streams_test.path("write_empty_line.txt")
  let _ = write_lines(file, [""])
  should.equal(read_line(file), "\n")
}

pub fn write_bytes_test() {
  let file = io_streams_test.path("write_bytes.bin")

  let assert Ok(stream) = io_streams.open_write_bin(file, False)
  let assert Ok(_) = io_streams.write_bytes(stream, <<1, 2>>)
  let assert Ok(_) = io_streams.write_bytes(stream, <<3, 4>>)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(io_streams_test.read_bin(file), <<1, 2, 3, 4>>)
}

pub fn append_test() {
  let file = io_streams_test.path("append.txt")

  let _ = write_text(file, "A")

  let assert Ok(stream) = io_streams.open_append(file, False)
  let assert Ok(_) = io_streams.write_string(stream, "B")
  let assert Ok(_) = io_streams.write_string(stream, "C")
  let assert Ok(_) = io_streams.close(stream)

  should.equal(read_line(file), "ABC")
}

pub fn append_bin_test() {
  let file = io_streams_test.path("append.bin")

  let _ = write_bin(file, <<1, 2>>)

  let assert Ok(stream) = io_streams.open_append_bin(file, False)
  let assert Ok(_) = io_streams.write_bytes(stream, <<3, 4>>)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(io_streams_test.read_bin(file), <<1, 2, 3, 4>>)
}

pub fn exclusive_append_test() {
  let file = io_streams_test.path("exclusive_append.txt")

  let assert Ok(stream) = io_streams.open_append(file, False)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(
    io_streams.open_append(file, True),
    Error(errors.FileAlreadyExists),
  )
}

pub fn exclusive_append_bin_test() {
  let file = io_streams_test.path("exclusive_append_bin.txt")

  let assert Ok(stream) = io_streams.open_append_bin(file, False)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(
    io_streams.open_append_bin(file, True),
    Error(errors.FileAlreadyExists),
  )
}
