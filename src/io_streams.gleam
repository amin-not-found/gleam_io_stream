import gleam/result
import io_streams/errors
import io_streams/internal

// Phantom capability markers

pub type Read {
  Read
}

pub type NoRead {
  NoRead
}

pub type Write {
  Write
}

pub type NoWrite {
  NoWrite
}

pub type Binary {
  Binary
}

pub type Text {
  Text
}

pub type Seek {
  Seek
}

pub type NoSeek {
  NoSeek
}

pub opaque type Stream(read_cap, write_cap, enc_cap, seek_cap) {
  Stream(internal.Handle)
}

pub type ReadText =
  Stream(Read, NoWrite, Text, Seek)

pub type ReadBinary =
  Stream(Read, NoWrite, Binary, Seek)

pub type WriteText =
  Stream(NoRead, Write, Text, Seek)

pub type WriteBinary =
  Stream(NoRead, Write, Binary, Seek)

pub type AppendText =
  Stream(NoRead, Write, Text, NoSeek)

pub type AppendBinary =
  Stream(NoRead, Write, Binary, NoSeek)

pub type ReadWriteText =
  Stream(Read, Write, Text, Seek)

pub type ReadWriteBinary =
  Stream(Read, Write, Binary, Seek)

pub fn open_read(path: String) -> Result(ReadText, errors.SystemError) {
  internal.open_read(path)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn open_read_bin(path: String) -> Result(ReadBinary, errors.SystemError) {
  internal.open_read_bin(path)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn open_write(
  path: String,
  exclusive: Bool,
) -> Result(WriteText, errors.SystemError) {
  internal.open_write(path, exclusive)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn open_write_bin(
  path: String,
  exclusive: Bool,
) -> Result(WriteBinary, errors.SystemError) {
  internal.open_write_bin(path, exclusive)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn open_append(
  path: String,
  exclusive: Bool,
) -> Result(AppendText, errors.SystemError) {
  internal.open_append(path, exclusive)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn open_append_bin(
  path: String,
  exclusive: Bool,
) -> Result(AppendBinary, errors.SystemError) {
  internal.open_append_bin(path, exclusive)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

/// Note: In NodeJS a file is created if it doesn't exist on "w+" mode(with truncate)
/// This behavior doesn't happen in Erlang.
pub fn open_rw(
  path: String,
  truncate: Bool,
) -> Result(ReadWriteText, errors.SystemError) {
  internal.open_rw(path, truncate)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

/// Note: In NodeJS a file is created if it doesn't exist on "w+" mode(with truncate)
/// This behavior doesn't happen in Erlang.
pub fn open_rw_bin(
  path: String,
  truncate: Bool,
) -> Result(ReadWriteBinary, errors.SystemError) {
  internal.open_rw_bin(path, truncate)
  |> result.map_error(errors.map_system_error)
  |> result.map(Stream)
}

pub fn next_byte(
  stream: Stream(Read, _, Binary, _),
) -> Result(Int, errors.StreamError) {
  let Stream(handle) = stream
  internal.next_byte(handle)
  |> result.map_error(errors.map_stream_error)
}

pub fn read_bytes(
  stream: Stream(Read, _, Binary, _),
  count: Int,
) -> Result(BitArray, errors.StreamError) {
  let Stream(handle) = stream
  internal.read_bytes(handle, count)
  |> result.map_error(errors.map_stream_error)
}

pub fn next_char(
  stream: Stream(Read, _, Text, _),
) -> Result(String, errors.StreamError) {
  let Stream(handle) = stream
  internal.next_char(handle)
  |> result.map_error(errors.map_stream_error)
}

pub fn read_line(
  stream: Stream(Read, _, Text, _),
) -> Result(String, errors.StreamError) {
  let Stream(handle) = stream
  internal.read_line(handle)
  |> result.map_error(errors.map_stream_error)
}

// Writing

pub fn write_bytes(
  stream: Stream(_, Write, Binary, _),
  bytes: BitArray,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_bytes(handle, bytes)
  |> result.map_error(errors.map_stream_error)
}

pub fn write_string(
  stream: Stream(_, Write, Text, _),
  string: String,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_string(handle, string)
  |> result.map_error(errors.map_stream_error)
}

pub fn write_line(
  stream: Stream(_, Write, Text, _),
  string: String,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_line(handle, string)
  |> result.map_error(errors.map_stream_error)
}

// Generic operations

pub fn close(stream: Stream(_, _, _, _)) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.close(handle)
  |> result.map_error(errors.map_stream_error)
}

pub fn seek(
  stream: Stream(Read, Write, _, Seek),
  position: Int,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.seek(handle, position)
  |> result.map_error(errors.map_stream_error)
}

pub fn sync(stream: Stream(_, Write, _, _)) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.sync(handle)
  |> result.map_error(errors.map_stream_error)
}

// Standard streams

pub fn stdin() -> ReadText {
  Stream(internal.stdin())
}

pub fn stdin_bin() -> ReadBinary {
  Stream(internal.stdin_bin())
}

pub fn stdout() -> WriteText {
  Stream(internal.stdout())
}

pub fn stdout_bin() -> WriteBinary {
  Stream(internal.stdout_bin())
}

pub fn stderr() -> WriteText {
  Stream(internal.stderr())
}

pub fn stderr_bin() -> WriteBinary {
  Stream(internal.stderr_bin())
}
