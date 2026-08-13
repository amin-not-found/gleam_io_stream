import gleeunit
import io_stream

pub const base_path = ""

pub fn main() {
  gleeunit.main()
}

pub fn path(name: String) -> String {
  "build/test/" <> name
}

pub fn create_rw_text(path: String, text: String) {
  let assert Ok(stream) = io_stream.open_rw(path, True)
  let assert Ok(_) = io_stream.write_string(stream, text)
  let assert Ok(_) = io_stream.close(stream)
}

pub fn create_rw_binary(path: String, bytes: BitArray) {
  let assert Ok(stream) = io_stream.open_rw_bin(path, True)
  let assert Ok(_) = io_stream.write_bytes(stream, bytes)
  let assert Ok(_) = io_stream.close(stream)
}

pub fn read_line(path: String) -> String {
  let assert Ok(stream) = io_stream.open_read(path)
  let assert Ok(line) = io_stream.read_line(stream)
  let assert Ok(_) = io_stream.close(stream)
  line
}

pub fn read_bin(path: String) -> BitArray {
  let assert Ok(stream) = io_stream.open_read_bin(path)
  let assert Ok(bytes) = io_stream.read_bytes(stream, 1_000_000)
  let assert Ok(_) = io_stream.close(stream)
  bytes
}
