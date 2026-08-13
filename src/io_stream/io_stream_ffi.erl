-module(io_stream_ffi).

-export([
    open/2,

    next_byte/1,
    read_bytes/2,
    next_char/1,
    read_line/1,

    write_bytes/2,
    write_string/2,
    write_line/2,

    close/1,
    seek/2,
    sync/1,

    stdin/0,
    stdin_bin/0,
    stdout/0,
    stdout_bin/0,
    stderr/0,
    stderr_bin/0
]).

open(Path, Modes) ->
    ErlangModes = translate_modes(Modes),
    case file:open(Path, ErlangModes) of
        {ok, IoDevice} ->
            {ok, IoDevice};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

%% Mode translation

translate_modes(Modes) ->
    lists:reverse(
        lists:foldl(fun translate_mode/2, [], Modes)
    ).

translate_mode('read', Acc) ->
    [read | Acc];

translate_mode('write', Acc) ->
    [write | Acc];

translate_mode('append', Acc) ->
    [append | Acc];

translate_mode('binary', Acc) ->
    [binary | Acc];

translate_mode('truncate', Acc) ->
    [truncate | Acc];

translate_mode('exclusive', Acc) ->
    [exclusive | Acc].

%% Read operations

next_byte(IoDevice) ->
    case file:read(IoDevice, 1) of
        {ok, <<Byte>>} ->
            {ok, Byte};

        eof ->
            {error, {<<"EOF">>, "Reached End of file"}};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

read_bytes(IoDevice, Count) ->
    case file:read(IoDevice, Count) of
        {ok, Bytes} ->
            {ok, Bytes};

        eof ->
            {error, {<<"EOF">>, "Reached End of file"}};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

next_char(IoDevice) ->
    case io:get_chars(IoDevice, "", 1) of
        eof ->
            {error, {<<"EOF">>, "Reached End of file"}};

        {error, Reason} ->
            {error, error_with_desc(Reason)};

        Chars when is_list(Chars) ->
            {ok, unicode:characters_to_binary(Chars)}
    end.

read_line(IoDevice) ->
    case io:get_line(IoDevice, "") of
        eof ->
            {error, {<<"EOF">>, "Reached End of file"}};

        {error, Reason} ->
            {error, error_with_desc(Reason)};

        Line when is_list(Line) ->
            {ok, unicode:characters_to_binary(Line)};

        Line when is_binary(Line) ->
            {ok, Line}
    end.

%% Write operations

write_bytes(IoDevice, Bytes) ->
    case file:write(IoDevice, Bytes) of
        ok ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

write_string(IoDevice, String) ->
    case file:write(IoDevice, unicode:characters_to_binary(String)) of
        ok ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

write_line(IoDevice, String) ->
    case file:write(
        IoDevice,
        [unicode:characters_to_binary(String), <<"\n">>]
    ) of
        ok ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

%% Generic operations

close(IoDevice) ->
    case file:close(IoDevice) of
        ok ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

seek(IoDevice, Position) ->
    case file:position(IoDevice, Position) of
        {ok, _} ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.


sync(IoDevice) ->
    case file:sync(IoDevice) of
        ok ->
            {ok, nil};

        {error, Reason} ->
            {error, error_with_desc(Reason)}
    end.

%% Standard streams

stdin() ->
    standard_io.

stdin_bin() ->
    standard_io.

stdout() ->
    standard_io.

stdout_bin() ->
    standard_io.

stderr() ->
    standard_error.

stderr_bin() ->
    standard_error.

%% Helper function for errors
error_with_desc(Reason) when is_atom(Reason) ->
    {
        unicode:characters_to_binary(atom_to_list(Reason)),
        unicode:characters_to_binary(file:format_error(Reason))
    }.