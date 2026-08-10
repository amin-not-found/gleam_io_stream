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
