import gleeunit
import io_streams

pub const base_path = ""

pub fn main() {
  gleeunit.main()
}

pub fn path(name: String) -> String {
  "build/test/" <> name
}

pub fn create_rw_text(path: String, text: String) {
  let assert Ok(stream) = io_streams.open_rw(path, True)
  let assert Ok(_) = io_streams.write_string(stream, text)
  let assert Ok(_) = io_streams.close(stream)
}

pub fn create_rw_binary(path: String, bytes: BitArray) {
  let assert Ok(stream) = io_streams.open_rw_bin(path, True)
  let assert Ok(_) = io_streams.write_bytes(stream, bytes)
  let assert Ok(_) = io_streams.close(stream)
}

pub fn read_line(path: String) -> String {
  let assert Ok(stream) = io_streams.open_read(path)
  let assert Ok(line) = io_streams.read_line(stream)
  let assert Ok(_) = io_streams.close(stream)
  line
}

pub fn read_bin(path: String) -> BitArray {
  let assert Ok(stream) = io_streams.open_read_bin(path)
  let assert Ok(bytes) = io_streams.read_bytes(stream, 1_000_000)
  let assert Ok(_) = io_streams.close(stream)
  bytes
}
