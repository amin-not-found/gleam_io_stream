import gleeunit/should
import io_streams
import io_streams/errors
import io_streams_test

pub fn seek_beginning_test() {
  let file = io_streams_test.path("seek_beginning.txt")

  let _ = io_streams_test.create_rw_text(file, "abcdef")

  let assert Ok(stream) = io_streams.open_rw(file, False)
  let assert Ok(_) = io_streams.seek(stream, 0)
  let assert Ok(char) = io_streams.next_char(stream)
  let assert Ok(_) = io_streams.close(stream)

  should.equal(char, "a")
}

pub fn seek_middle_test() {
  let file = io_streams_test.path("seek_middle.txt")

  let _ = io_streams_test.create_rw_text(file, "abcdef")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.seek(stream, 3)

  let assert Ok(char) = io_streams.next_char(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(char, "d")
}

pub fn seek_end_test() {
  let file = io_streams_test.path("seek_end.txt")

  let _ = io_streams_test.create_rw_text(file, "abcdef")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.seek(stream, 6)

  should.equal(io_streams.next_char(stream), Error(errors.EndOfFile))

  let assert Ok(_) = io_streams.close(stream)
}

pub fn seek_twice_test() {
  let file = io_streams_test.path("seek_twice.txt")

  let _ = io_streams_test.create_rw_text(file, "abcdef")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.seek(stream, 4)

  let assert Ok(first) = io_streams.next_char(stream)

  let assert Ok(_) = io_streams.seek(stream, 1)

  let assert Ok(second) = io_streams.next_char(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(first, "e")
  should.equal(second, "b")
}

pub fn seek_then_read_test() {
  let file = io_streams_test.path("seek_then_read.txt")

  let _ = io_streams_test.create_rw_text(file, "hello world")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.seek(stream, 6)

  let assert Ok(line) = io_streams.read_line(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(line, "world")
}

pub fn seek_binary_test() {
  let file = io_streams_test.path("seek_binary.bin")

  let _ = io_streams_test.create_rw_binary(file, <<1, 2, 3, 4, 5>>)

  let assert Ok(stream) = io_streams.open_rw_bin(file, False)

  let assert Ok(_) = io_streams.seek(stream, 2)

  let assert Ok(byte) = io_streams.next_byte(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(byte, 3)
}

pub fn seek_binary_twice_test() {
  let file = io_streams_test.path("seek_binary_twice.bin")
  let _ = io_streams_test.create_rw_binary(file, <<10, 20, 30, 40>>)

  let assert Ok(stream) = io_streams.open_rw_bin(file, False)

  let assert Ok(_) = io_streams.seek(stream, 3)

  let assert Ok(last) = io_streams.next_byte(stream)

  let assert Ok(_) = io_streams.seek(stream, 0)

  let assert Ok(first) = io_streams.next_byte(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(last, 40)
  should.equal(first, 10)
}

pub fn seek_then_write_test() {
  let file = io_streams_test.path("seek_then_write_test.txt")

  let _ = io_streams_test.create_rw_text(file, "abcdef")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.seek(stream, 2)

  let assert Ok(_) = io_streams.write_string(stream, "XYZ")

  let assert Ok(_) = io_streams.close(stream)

  should.equal(io_streams_test.read_line(file), "abXYZf")
}

pub fn close_test() {
  let file = io_streams_test.path("close.txt")

  let _ = io_streams_test.create_rw_text(file, "hello")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.close(stream)
}

pub fn close_twice_test() {
  let file = io_streams_test.path("close_twice.txt")

  let _ = io_streams_test.create_rw_text(file, "hello")

  let assert Ok(stream) = io_streams.open_rw(file, False)

  let assert Ok(_) = io_streams.close(stream)

  case io_streams.close(stream) {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

pub fn flush_test() {
  let file = io_streams_test.path("flush.txt")

  let assert Ok(stream) = io_streams.open_rw(file, True)
  let assert Ok(_) = io_streams.write_string(stream, "abc")

  let assert Ok(_) = io_streams.flush(stream)
  let assert Ok(_) = io_streams.seek(stream, 0)
  let assert Ok(line) = io_streams.read_line(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(line, "abc")
}

pub fn flush_bin_test() {
  let file = io_streams_test.path("flush.bin")

  let assert Ok(stream) = io_streams.open_rw_bin(file, True)
  let assert Ok(_) = io_streams.write_bytes(stream, <<1, 2, 3>>)

  let assert Ok(_) = io_streams.flush(stream)
  let assert Ok(_) = io_streams.seek(stream, 0)
  let assert Ok(line) = io_streams.read_bytes(stream, 3)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(line, <<1, 2, 3>>)
}

// only a smoke test
pub fn stdout_test() {
  let stream = io_streams.stdout()
  let assert Ok(_) = io_streams.write_string(stream, "\nstdout_test\n")
}

// only a smoke test
pub fn stdout_bin_test() {
  let stream = io_streams.stdout_bin()
  let assert Ok(_) = io_streams.write_bytes(stream, <<1, 2, 3>>)
}

// only a smoke test
pub fn stderr_test() {
  let stream = io_streams.stderr()
  let assert Ok(_) = io_streams.write_string(stream, "\nstderr_test\n")
}

// only a smoke test
pub fn stderr_bin_test() {
  let stream = io_streams.stderr_bin()
  let assert Ok(_) = io_streams.write_bytes(stream, <<4, 5, 6>>)
}

pub fn seek_flush_read_test() {
  let file = io_streams_test.path("seek_flush_read.txt")

  let assert Ok(stream) = io_streams.open_rw(file, True)
  let assert Ok(_) = io_streams.write_string(stream, "abcdef")
  let assert Ok(_) = io_streams.flush(stream)

  let assert Ok(_) = io_streams.seek(stream, 2)
  let assert Ok(char) = io_streams.next_char(stream)

  let assert Ok(_) = io_streams.close(stream)

  should.equal(char, "c")
}

pub fn multiple_seek_write_test() {
  let file = io_streams_test.path("multiple_seek_write.txt")

  let assert Ok(stream) = io_streams.open_rw(file, True)

  let assert Ok(_) = io_streams.write_string(stream, "abcdef")

  let assert Ok(_) = io_streams.seek(stream, 0)
  let assert Ok(_) = io_streams.write_string(stream, "X")

  let assert Ok(_) = io_streams.seek(stream, 3)
  let assert Ok(_) = io_streams.write_string(stream, "YZ")

  let assert Ok(_) = io_streams.close(stream)
  should.equal(io_streams_test.read_line(file), "XbcYZf")
}

pub fn multiple_seek_write_bin_test() {
  let file = io_streams_test.path("multiple_seek_write.bin")

  let assert Ok(stream) = io_streams.open_rw_bin(file, True)

  let assert Ok(_) = io_streams.write_bytes(stream, <<1, 2, 3, 4, 5, 6>>)

  let assert Ok(_) = io_streams.seek(stream, 0)
  let assert Ok(_) = io_streams.write_bytes(stream, <<7>>)

  let assert Ok(_) = io_streams.seek(stream, 3)
  let assert Ok(_) = io_streams.write_bytes(stream, <<8, 9>>)

  let assert Ok(_) = io_streams.close(stream)
  should.equal(io_streams_test.read_bin(file), <<7, 2, 3, 8, 9, 6>>)
}
