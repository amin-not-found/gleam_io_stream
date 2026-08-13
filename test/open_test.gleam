import gleam/io
import gleeunit/should
import io_stream
import io_stream/error
import io_stream_test

pub fn open_missing_file_test() {
  let path = io_stream_test.path("does_not_exist.txt")
  let result = io_stream.open_read(path)
  should.equal(result, Error(error.FileNotFound))
}

pub fn open_write_creates_file_test() {
  let path = io_stream_test.path("open_write_create.txt")

  let assert Ok(stream) = io_stream.open_write(path, False)
  let assert Ok(_) = io_stream.close(stream)
  let result = io_stream.open_read(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Expected file to exist, got:: ")
      echo e
      panic
    }
  }
}

pub fn open_write_bin_creates_file_test() {
  let path = io_stream_test.path("open_write_bin_create.bin")

  let assert Ok(stream) = io_stream.open_write_bin(path, False)
  let assert Ok(_) = io_stream.close(stream)
  let result = io_stream.open_read_bin(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Expected file to exist, got:: ")
      echo e
      panic
    }
  }
}

pub fn open_write_existing_exclusive_test() {
  let path = io_stream_test.path("exclusive.txt")

  let assert Ok(writer) = io_stream.open_write(path, False)
  let assert Ok(_) = io_stream.close(writer)

  let result = io_stream.open_write(path, True)

  should.equal(result, Error(error.FileAlreadyExists))
}

pub fn open_write_bin_existing_exclusive_test() {
  let path = io_stream_test.path("exclusive.bin")

  let assert Ok(writer) = io_stream.open_write_bin(path, False)
  let assert Ok(_) = io_stream.close(writer)

  let result = io_stream.open_write_bin(path, True)

  should.equal(result, Error(error.FileAlreadyExists))
}

pub fn open_append_creates_file_test() {
  let path = io_stream_test.path("append_create.txt")

  let assert Ok(stream) = io_stream.open_append(path, False)
  let assert Ok(_) = io_stream.close(stream)

  let result = io_stream.open_read(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Unexpected error: ")
      echo e
      panic
    }
  }
}

pub fn open_append_bin_creates_file_test() {
  let path = io_stream_test.path("append_bin_create.bin")

  let assert Ok(stream) = io_stream.open_append_bin(path, False)
  let assert Ok(_) = io_stream.close(stream)

  let result = io_stream.open_read_bin(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Unexpected error: ")
      echo e
      panic
    }
  }
}

pub fn open_rw_creates_file_test() {
  let path = io_stream_test.path("rw_create.txt")

  let assert Ok(stream) = io_stream.open_rw(path, True)
  let assert Ok(_) = io_stream.close(stream)

  let result = io_stream.open_read(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Unexpected error: ")
      echo e
      panic
    }
  }
}

pub fn open_rw_bin_creates_file_test() {
  let path = io_stream_test.path("rw_bin_create.bin")

  let assert Ok(stream) = io_stream.open_rw_bin(path, True)
  let assert Ok(_) = io_stream.close(stream)

  let result = io_stream.open_read_bin(path)

  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error("Unexpected error: ")
      echo e
      panic
    }
  }
}
