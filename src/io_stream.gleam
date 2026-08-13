import gleam/result
import internal/mode
import io_stream/error
import io_stream/internal

pub type TextReader =
  Stream(mode.Read, mode.NoWrite, mode.Text, mode.Seek)

pub type BinaryReader =
  Stream(mode.Read, mode.NoWrite, mode.Binary, mode.Seek)

pub type TextWriter =
  Stream(mode.NoRead, mode.Write, mode.Text, mode.Seek)

pub type BinaryWriter =
  Stream(mode.NoRead, mode.Write, mode.Binary, mode.Seek)

pub type TextAppender =
  Stream(mode.NoRead, mode.Write, mode.Text, mode.NoSeek)

pub type BinaryAppender =
  Stream(mode.NoRead, mode.Write, mode.Binary, mode.NoSeek)

pub type TextChannel =
  Stream(mode.Read, mode.Write, mode.Text, mode.Seek)

pub type BinaryChannel =
  Stream(mode.Read, mode.Write, mode.Binary, mode.Seek)

/// The type that represents io streams.
///
/// capability to read, write and seek and binary/text format is marked using phantom types.
pub opaque type Stream(read_cap, write_cap, enc_cap, seek_cap) {
  Stream(internal.Handle)
}

/// Open file in textual read mode
pub fn open_read(path: String) -> Result(TextReader, error.SystemError) {
  internal.open_read(path)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Open file in binary read mode
pub fn open_read_bin(path: String) -> Result(BinaryReader, error.SystemError) {
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
) -> Result(TextWriter, error.SystemError) {
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
) -> Result(BinaryWriter, error.SystemError) {
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
) -> Result(TextAppender, error.SystemError) {
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
) -> Result(BinaryAppender, error.SystemError) {
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
) -> Result(TextChannel, error.SystemError) {
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
) -> Result(BinaryChannel, error.SystemError) {
  internal.open_rw_bin(path, truncate)
  |> result.map_error(internal.map_system_error)
  |> result.map(Stream)
}

/// Get the next byte in the stream.
///
/// The given stream must have binary format and read capability.
pub fn next_byte(
  stream: Stream(mode.Read, _, mode.Binary, _),
) -> Result(Int, error.StreamError) {
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
  stream: Stream(mode.Read, _, mode.Binary, _),
  count: Int,
) -> Result(BitArray, error.StreamError) {
  let Stream(handle) = stream
  internal.read_bytes(handle, count)
  |> result.map_error(internal.map_stream_error)
}

/// Get the next unicode character in the stream. This uses UTF-8 encoding.
///
/// The given stream must have textual format and read capability.
pub fn next_char(
  stream: Stream(mode.Read, _, mode.Text, _),
) -> Result(String, error.StreamError) {
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
  stream: Stream(mode.Read, _, mode.Text, _),
) -> Result(String, error.StreamError) {
  let Stream(handle) = stream
  internal.read_line(handle)
  |> result.map_error(internal.map_stream_error)
}

// Writing

/// Writes given bytes into the stream.
///
/// The given stream must have binary format and write capability.
pub fn write_bytes(
  stream: Stream(_, mode.Write, mode.Binary, _),
  bytes: BitArray,
) -> Result(Nil, error.StreamError) {
  let Stream(handle) = stream
  internal.write_bytes(handle, bytes)
  |> result.map_error(internal.map_stream_error)
}

/// Writes given string into the stream.
///
/// The given stream must have textual format and write capability.
pub fn write_string(
  stream: Stream(_, mode.Write, mode.Text, _),
  string: String,
) -> Result(Nil, error.StreamError) {
  let Stream(handle) = stream
  internal.write_string(handle, string)
  |> result.map_error(internal.map_stream_error)
}

/// Writes given string into the stream and then adds a line break.
///
/// The given stream must have textual format and write capability.
pub fn write_line(
  stream: Stream(_, mode.Write, mode.Text, _),
  string: String,
) -> Result(Nil, error.StreamError) {
  let Stream(handle) = stream
  internal.write_line(handle, string)
  |> result.map_error(internal.map_stream_error)
}

// Generic operations

/// Closes given stream.
pub fn close(stream: Stream(_, _, _, _)) -> Result(Nil, error.StreamError) {
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
  stream: Stream(mode.Read, mode.Write, _, mode.Seek),
  position: Int,
) -> Result(Nil, error.StreamError) {
  let Stream(handle) = stream
  internal.seek(handle, position)
  |> result.map_error(internal.map_stream_error)
}

/// Synchronies write calls for given.
///
/// *Note*: stdout/stderr actually can't be synced.
pub fn sync(
  stream: Stream(_, mode.Write, _, _),
) -> Result(Nil, error.StreamError) {
  let Stream(handle) = stream
  internal.sync(handle)
  |> result.map_error(internal.map_stream_error)
}

// Standard streams

/// Returns standard input stream in text format.
pub fn stdin() -> TextReader {
  Stream(internal.stdin())
}

/// Returns standard input stream in binary format.
pub fn stdin_bin() -> BinaryReader {
  Stream(internal.stdin_bin())
}

/// Returns standard output stream in text format.
pub fn stdout() -> TextAppender {
  Stream(internal.stdout())
}

/// Returns standard output stream in binary format.
pub fn stdout_bin() -> BinaryAppender {
  Stream(internal.stdout_bin())
}

/// Returns error output stream in text format.
pub fn stderr() -> TextAppender {
  Stream(internal.stderr())
}

/// Returns error output stream in binary format.
pub fn stderr_bin() -> BinaryAppender {
  Stream(internal.stderr_bin())
}
