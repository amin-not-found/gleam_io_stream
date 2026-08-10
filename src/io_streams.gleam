import gleam/result
import io_streams/errors
import io_streams/internal

// Phantom capability markers

/// Phantom type marking read capability
pub type Read {
  Read
}

/// Phantom type marking absence of read capability
pub type NoRead {
  NoRead
}

/// Phantom type marking write capability
pub type Write {
  Write
}

/// Phantom type marking absence of write capability
pub type NoWrite {
  NoWrite
}

/// Phantom type marking binary io format
pub type Binary {
  Binary
}

/// Phantom type marking textual io format
pub type Text {
  Text
}

/// Phantom type marking seek capability
pub type Seek {
  Seek
}

/// Phantom type marking absence of seek capability
pub type NoSeek {
  NoSeek
}

/// The type that represents io streams.
///
/// capability to read, write and seek and binary/text format is marked using phantom types.
pub opaque type Stream(read_cap, write_cap, enc_cap, seek_cap) {
  Stream(internal.Handle)
}

/// Open file in textual read mode
pub fn open_read(
  path: String,
) -> Result(Stream(Read, NoWrite, Text, Seek), errors.SystemError) {
  internal.open_read(path)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in binary read mode
pub fn open_read_bin(
  path: String,
) -> Result(Stream(Read, NoWrite, Binary, Seek), errors.SystemError) {
  internal.open_read_bin(path)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in textual write mode
///
/// `exclusive`: whether to fail if the file already exists
pub fn open_write(
  path: String,
  exclusive: Bool,
) -> Result(Stream(NoRead, Write, Text, Seek), errors.SystemError) {
  internal.open_write(path, exclusive)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in binary write mode
///
/// `exclusive`: whether to fail if the file already exists
pub fn open_write_bin(
  path: String,
  exclusive: Bool,
) -> Result(Stream(NoRead, Write, Binary, Seek), errors.SystemError) {
  internal.open_write_bin(path, exclusive)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in textual append mode
///
/// `exclusive`: whether to fail if the file already exists
pub fn open_append(
  path: String,
  exclusive: Bool,
) -> Result(Stream(NoRead, Write, Text, NoSeek), errors.SystemError) {
  internal.open_append(path, exclusive)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in binary append mode
///
/// `exclusive`: whether to fail if the file already exists
pub fn open_append_bin(
  path: String,
  exclusive: Bool,
) -> Result(Stream(NoRead, Write, Binary, NoSeek), errors.SystemError) {
  internal.open_append_bin(path, exclusive)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in textual read/write mode
///
/// `truncate`: whether to empty the file while opening it
///
/// *Note*: In NodeJS a file is created if it doesn't exist on "w+" mode(with truncate).
/// This doesn't happen in Erlang.
pub fn open_rw(
  path: String,
  truncate: Bool,
) -> Result(Stream(Read, Write, Text, Seek), errors.SystemError) {
  internal.open_rw(path, truncate)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in binary read/write mode
///
/// `truncate`: whether to empty the file while opening it
///
/// *Note*: In NodeJS a file is created if it doesn't exist on "w+" mode(with truncate).
/// This doesn't happen in Erlang.
pub fn open_rw_bin(
  path: String,
  truncate: Bool,
) -> Result(Stream(Read, Write, Binary, Seek), errors.SystemError) {
  internal.open_rw_bin(path, truncate)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Get the next byte in the stream.
///
/// The given stream must have binary format and read capability.
pub fn next_byte(
  stream: Stream(Read, _, Binary, _),
) -> Result(Int, errors.StreamError) {
  let Stream(handle) = stream
  internal.next_byte(handle)
  |> result.map_error(internal.map_stream_error)
}

/// Get the next bytes in the stream. The given stream must have binary format.
///
/// The given stream must have binary format and read capability.
///
/// `count`: number of bytes to reads
pub fn read_bytes(
  stream: Stream(Read, _, Binary, _),
  count: Int,
) -> Result(BitArray, errors.StreamError) {
  let Stream(handle) = stream
  internal.read_bytes(handle, count)
  |> result.map_error(internal.map_stream_error)
}

/// Get the next unicode character in the stream. This uses UTF-8 encoding.
///
/// The given stream must have textual format and read capability.
pub fn next_char(
  stream: Stream(Read, _, Text, _),
) -> Result(String, errors.StreamError) {
  let Stream(handle) = stream
  internal.next_char(handle)
  |> result.map_error(internal.map_stream_error)
}

/// Get the next unicode characters until a break line appears in the stream.
/// This uses UTF-8 encoding.
///
/// The given stream must have textual format and read capability.
///
/// *Note*: The line break character is also included in the returned string.
///
/// *Note*: If the stream ends before a break line is found,
/// this function returns characters up to end of file.
pub fn read_line(
  stream: Stream(Read, _, Text, _),
) -> Result(String, errors.StreamError) {
  let Stream(handle) = stream
  internal.read_line(handle)
  |> result.map_error(internal.map_stream_error)
}

// Writing

/// Writes given bytes into the stream.
///
/// The given stream must have binary format and write capability.
pub fn write_bytes(
  stream: Stream(_, Write, Binary, _),
  bytes: BitArray,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_bytes(handle, bytes)
  |> result.map_error(internal.map_stream_error)
}

/// Writes given string into the stream.
///
/// The given stream must have textual format and write capability.
pub fn write_string(
  stream: Stream(_, Write, Text, _),
  string: String,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_string(handle, string)
  |> result.map_error(internal.map_stream_error)
}

/// Writes given string into the stream and then adds a line break.
///
/// The given stream must have textual format and write capability.
pub fn write_line(
  stream: Stream(_, Write, Text, _),
  string: String,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.write_line(handle, string)
  |> result.map_error(internal.map_stream_error)
}

// Generic operations

/// Closes given stream.
pub fn close(stream: Stream(_, _, _, _)) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.close(handle)
  |> result.map_error(internal.map_stream_error)
}

/// Seeks given stream to a specific position.
///
/// The given stream must have both read and write capability.
///
/// *Note*: Seek behavior for files opened in append mode is harder
/// to get right in both Erlang ans Js and thus isn't implemented.
pub fn seek(
  stream: Stream(Read, Write, _, Seek),
  position: Int,
) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.seek(handle, position)
  |> result.map_error(internal.map_stream_error)
}

/// Synchronies write calls for given.
///
/// *Note*: stdout/stderr actually can't be synced.
pub fn sync(stream: Stream(_, Write, _, _)) -> Result(Nil, errors.StreamError) {
  let Stream(handle) = stream
  internal.sync(handle)
  |> result.map_error(internal.map_stream_error)
}

// Standard streams

/// Returns standard input stream in text format.
pub fn stdin() -> Stream(Read, _, Text, NoSeek) {
  Stream(internal.stdin())
}

/// Returns standard input stream in binary format.
pub fn stdin_bin() -> Stream(Read, _, Binary, NoSeek) {
  Stream(internal.stdin_bin())
}

/// Returns standard output stream in text format.
pub fn stdout() -> Stream(_, Write, Text, NoSeek) {
  Stream(internal.stdout())
}

/// Returns standard output stream in binary format.
pub fn stdout_bin() -> Stream(_, Write, Binary, NoSeek) {
  Stream(internal.stdout_bin())
}

/// Returns error output stream in text format.
pub fn stderr() -> Stream(_, Write, Text, NoSeek) {
  Stream(internal.stderr())
}

/// Returns error output stream in binary format.
pub fn stderr_bin() -> Stream(_, Write, Binary, NoSeek) {
  Stream(internal.stderr_bin())
}
