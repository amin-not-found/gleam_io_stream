import gleeunit/should
import io_stream
import io_stream/error
import io_stream_test

pub fn next_byte_reads_test() {
  let path = io_stream_test.path("byte2.bin")

  let _ = io_stream_test.create_rw_binary(path, <<10, 20>>)

  let assert Ok(reader) = io_stream.open_read_bin(path)
  let assert Ok(a) = io_stream.next_byte(reader)
  let assert Ok(b) = io_stream.next_byte(reader)

  should.equal(a, 10)
  should.equal(b, 20)
}

pub fn next_char_reads_test() {
  let path = io_stream_test.path("chars2.txt")

  let _ = io_stream_test.create_rw_text(path, "ab")

  let assert Ok(reader) = io_stream.open_read(path)
  let assert Ok(a) = io_stream.next_char(reader)
  let assert Ok(b) = io_stream.next_char(reader)

  should.equal(a, "a")
  should.equal(b, "b")
}

pub fn read_bytes_test() {
  let path = io_stream_test.path("read_bytes.bin")

  let _ = io_stream_test.create_rw_binary(path, <<1, 2, 3, 4>>)

  let assert Ok(reader) = io_stream.open_read_bin(path)
  let assert Ok(read) = io_stream.read_bytes(reader, 2)
  should.equal(read, <<1, 2>>)
}

pub fn read_lines_test() {
  let path = io_stream_test.path("lines.txt")

  let _ = io_stream_test.create_rw_text(path, "one\ntwo\n")

  let assert Ok(reader) = io_stream.open_read(path)
  let assert Ok(one) = io_stream.read_line(reader)
  let assert Ok(two) = io_stream.read_line(reader)

  should.equal(one, "one\n")
  should.equal(two, "two\n")
}

pub fn eof_after_last_byte_test() {
  let path = io_stream_test.path("eof_byte.bin")

  let _ = io_stream_test.create_rw_binary(path, <<7>>)

  let assert Ok(reader) = io_stream.open_read_bin(path)
  let _ = io_stream.next_byte(reader)

  should.equal(io_stream.next_byte(reader), Error(error.EndOfFile))
}

pub fn eof_after_last_char_test() {
  let path = io_stream_test.path("eof_char.txt")

  let _ = io_stream_test.create_rw_text(path, "x")

  let assert Ok(reader) = io_stream.open_read(path)
  let _ = io_stream.next_char(reader)

  should.equal(io_stream.next_char(reader), Error(error.EndOfFile))
}
