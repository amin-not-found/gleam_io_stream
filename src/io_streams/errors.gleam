import gleam/string

pub type SystemError {
  PermissionDenied
  FileNotFound
  FileAlreadyExists
  BadFileDescriptor
  NotADirectory
  IsADirectory
  DirectoryNotEmpty
  NameTooLong
  TooManyOpenFiles
  FileTooLarge
  NoSpaceLeft
  ReadOnlyFileSystem
  CrossDeviceLink
  ResourceBusy
  ResourceTemporarilyUnavailable
  Interrupted
  InvalidArgument
  BrokenPipe
  OperationNotPermitted
  SymbolicLinkLoop
  NoSuchDevice
  DeviceOrResourceBusy
  FunctionNotSupported
  TimedOut
  ConnectionReset
  ConnectionAborted
  ConnectionRefused
  HostUnreachable
  NetworkDown
  NetworkUnreachable
  AddressInUse
  AddressNotAvailable
  MessageTooLarge
  ProcessLimitReached
  SystemLimitReached
  Deadlock
  QuotaExceeded
  StaleFileHandle
  Other(code: String, message: String)
}

pub type StreamError {
  EndOfFile
  InvalidUtf8
  System(SystemError)
}

pub fn map_system_error(error: #(String, String)) -> SystemError {
  let #(code, message) = error
  let code = string.uppercase(code)

  case code {
    "EACCES" -> PermissionDenied
    "EPERM" -> OperationNotPermitted
    "ENOENT" -> FileNotFound
    "EEXIST" -> FileAlreadyExists
    "EBADF" -> BadFileDescriptor
    "ENOTDIR" -> NotADirectory
    "EISDIR" -> IsADirectory
    "ENOTEMPTY" -> DirectoryNotEmpty
    "ENAMETOOLONG" -> NameTooLong
    "EMFILE" -> TooManyOpenFiles
    "ENFILE" -> SystemLimitReached
    "ENOSPC" -> NoSpaceLeft
    "EROFS" -> ReadOnlyFileSystem
    "EBUSY" -> ResourceBusy
    "EAGAIN" -> ResourceTemporarilyUnavailable
    "EINTR" -> Interrupted
    "EINVAL" -> InvalidArgument
    "EPIPE" -> BrokenPipe
    "EXDEV" -> CrossDeviceLink
    "ENODEV" -> NoSuchDevice
    "ENOTSUP" -> FunctionNotSupported
    "EOPNOTSUPP" -> FunctionNotSupported
    "EFBIG" -> FileTooLarge
    "ELOOP" -> SymbolicLinkLoop
    "EDQUOT" -> QuotaExceeded
    "ESTALE" -> StaleFileHandle
    "ETIMEDOUT" -> TimedOut
    "ECONNRESET" -> ConnectionReset
    "ECONNABORTED" -> ConnectionAborted
    "ECONNREFUSED" -> ConnectionRefused
    "EHOSTUNREACH" -> HostUnreachable
    "ENETDOWN" -> NetworkDown
    "ENETUNREACH" -> NetworkUnreachable
    "EADDRINUSE" -> AddressInUse
    "EADDRNOTAVAIL" -> AddressNotAvailable
    "EMSGSIZE" -> MessageTooLarge
    _ -> Other(code: code, message: message)
  }
}

pub fn map_stream_error(error: #(String, String)) -> StreamError {
  let #(code, _) = error
  let code = string.uppercase(code)

  case code {
    "EOF" -> EndOfFile
    "INVALID_UTF8" -> InvalidUtf8
    _ -> System(map_system_error(error))
  }
}
