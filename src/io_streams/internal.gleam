pub type Handle

import gleam/string
import io_streams/errors

type Mode {
  Read
  Write
  Append
  Binary
  Truncate
  Exclusive
}

@external(erlang, "io_streams_ffi", "open")
@external(javascript, "./io_streams_ffi.mjs", "open")
fn ffi_open(
  path: String,
  modes: List(Mode),
) -> Result(Handle, #(String, String))

@external(erlang, "io_streams_ffi", "next_byte")
@external(javascript, "./io_streams_ffi.mjs", "next_byte")
pub fn next_byte(handle: Handle) -> Result(Int, #(String, String))

@external(erlang, "io_streams_ffi", "read_bytes")
@external(javascript, "./io_streams_ffi.mjs", "read_bytes")
pub fn read_bytes(
  handle: Handle,
  count: Int,
) -> Result(BitArray, #(String, String))

@external(erlang, "io_streams_ffi", "next_char")
@external(javascript, "./io_streams_ffi.mjs", "next_char")
pub fn next_char(handle: Handle) -> Result(String, #(String, String))

@external(erlang, "io_streams_ffi", "read_line")
@external(javascript, "./io_streams_ffi.mjs", "read_line")
pub fn read_line(handle: Handle) -> Result(String, #(String, String))

@external(erlang, "io_streams_ffi", "write_bytes")
@external(javascript, "./io_streams_ffi.mjs", "write_bytes")
pub fn write_bytes(
  handle: Handle,
  bytes: BitArray,
) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "write_string")
@external(javascript, "./io_streams_ffi.mjs", "write_string")
pub fn write_string(
  handle: Handle,
  string: String,
) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "write_line")
@external(javascript, "./io_streams_ffi.mjs", "write_line")
pub fn write_line(
  handle: Handle,
  string: String,
) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "close")
@external(javascript, "./io_streams_ffi.mjs", "close")
pub fn close(handle: Handle) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "seek")
@external(javascript, "./io_streams_ffi.mjs", "seek")
pub fn seek(handle: Handle, position: Int) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "sync")
@external(javascript, "./io_streams_ffi.mjs", "sync")
pub fn sync(handle: Handle) -> Result(Nil, #(String, String))

@external(erlang, "io_streams_ffi", "stdin")
@external(javascript, "./io_streams_ffi.mjs", "stdin")
pub fn stdin() -> Handle

@external(erlang, "io_streams_ffi", "stdin_bin")
@external(javascript, "./io_streams_ffi.mjs", "stdin_bin")
pub fn stdin_bin() -> Handle

@external(erlang, "io_streams_ffi", "stdout")
@external(javascript, "./io_streams_ffi.mjs", "stdout")
pub fn stdout() -> Handle

@external(erlang, "io_streams_ffi", "stdout_bin")
@external(javascript, "./io_streams_ffi.mjs", "stdout_bin")
pub fn stdout_bin() -> Handle

@external(erlang, "io_streams_ffi", "stderr")
@external(javascript, "./io_streams_ffi.mjs", "stderr")
pub fn stderr() -> Handle

@external(erlang, "io_streams_ffi", "stderr_bin")
@external(javascript, "./io_streams_ffi.mjs", "stderr_bin")
pub fn stderr_bin() -> Handle

pub fn open_read(path: String) -> Result(Handle, #(String, String)) {
  ffi_open(path, [Read])
}

pub fn open_read_bin(path: String) -> Result(Handle, #(String, String)) {
  ffi_open(path, [Binary, Read])
}

pub fn open_write(
  path: String,
  exclusive: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, write_modes(exclusive))
}

pub fn open_write_bin(
  path: String,
  exclusive: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, [Binary, ..write_modes(exclusive)])
}

pub fn open_append(
  path: String,
  exclusive: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, append_modes(exclusive))
}

pub fn open_append_bin(
  path: String,
  exclusive: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, [Binary, ..append_modes(exclusive)])
}

pub fn open_rw(
  path: String,
  truncate: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, rw_modes(truncate))
}

pub fn open_rw_bin(
  path: String,
  truncate: Bool,
) -> Result(Handle, #(String, String)) {
  ffi_open(path, [Binary, ..rw_modes(truncate)])
}

fn write_modes(exclusive: Bool) -> List(Mode) {
  let modes = [Write]

  case exclusive {
    True -> [Exclusive, ..modes]
    False -> modes
  }
}

fn append_modes(exclusive: Bool) -> List(Mode) {
  let modes = [Append]

  case exclusive {
    True -> [Exclusive, ..modes]
    False -> modes
  }
}

fn rw_modes(truncate: Bool) -> List(Mode) {
  let modes = [Read, Write]

  case truncate {
    True -> [Truncate, ..modes]
    False -> modes
  }
}

pub fn map_system_error(error: #(String, String)) -> errors.SystemError {
  let #(code, message) = error
  let code = string.uppercase(code)

  case code {
    "EACCES" -> errors.PermissionDenied
    "EPERM" -> errors.OperationNotPermitted
    "ENOENT" -> errors.FileNotFound
    "EEXIST" -> errors.FileAlreadyExists
    "EBADF" -> errors.BadFileDescriptor
    "ENOTDIR" -> errors.NotADirectory
    "EISDIR" -> errors.IsADirectory
    "ENOTEMPTY" -> errors.DirectoryNotEmpty
    "ENAMETOOLONG" -> errors.NameTooLong
    "EMFILE" -> errors.TooManyOpenFiles
    "ENFILE" -> errors.SystemLimitReached
    "ENOSPC" -> errors.NoSpaceLeft
    "EROFS" -> errors.ReadOnlyFileSystem
    "EBUSY" -> errors.ResourceBusy
    "EAGAIN" -> errors.ResourceTemporarilyUnavailable
    "EINTR" -> errors.Interrupted
    "EINVAL" -> errors.InvalidArgument
    "EPIPE" -> errors.BrokenPipe
    "EXDEV" -> errors.CrossDeviceLink
    "ENODEV" -> errors.NoSuchDevice
    "ENOTSUP" -> errors.FunctionNotSupported
    "EOPNOTSUPP" -> errors.FunctionNotSupported
    "EFBIG" -> errors.FileTooLarge
    "ELOOP" -> errors.SymbolicLinkLoop
    "EDQUOT" -> errors.QuotaExceeded
    "ESTALE" -> errors.StaleFileHandle
    "ETIMEDOUT" -> errors.TimedOut
    "ECONNRESET" -> errors.ConnectionReset
    "ECONNABORTED" -> errors.ConnectionAborted
    "ECONNREFUSED" -> errors.ConnectionRefused
    "EHOSTUNREACH" -> errors.HostUnreachable
    "ENETDOWN" -> errors.NetworkDown
    "ENETUNREACH" -> errors.NetworkUnreachable
    "EADDRINUSE" -> errors.AddressInUse
    "EADDRNOTAVAIL" -> errors.AddressNotAvailable
    "EMSGSIZE" -> errors.MessageTooLarge
    _ -> errors.Other(code: code, message: message)
  }
}

pub fn map_stream_error(error: #(String, String)) -> errors.StreamError {
  let #(code, _) = error
  let code = string.uppercase(code)

  case code {
    "EOF" -> errors.EndOfFile
    "INVALID_UTF8" -> errors.InvalidUtf8
    _ -> errors.System(map_system_error(error))
  }
}
