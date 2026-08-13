import {
    Result$Ok,
    Result$Ok$0,
    Result$Error,
    Result$Error$0,
    Result$isError,
    BitArray$BitArray,
    BitArray$BitArray$data,
} from "../gleam.mjs";
import fs from "fs";

const utf8Decoder = new TextDecoder("utf-8", { fatal: true });
const utf8Encoder = new TextEncoder();

class Handle {
    #fd;
    #position;

    constructor(fd) {
        this.#fd = fd;
        this.#position = 0;
    }

    read(count) {
        const buffer = Buffer.allocUnsafe(count);
        const bytesRead = fs.readSync(
            this.#fd,
            buffer,
            0,
            count,
            this.#position,
        );

        this.#position += bytesRead;

        return buffer.subarray(0, bytesRead);
    }

    write(buffer) {
        const bytesWritten = fs.writeSync(
            this.#fd,
            buffer,
            0,
            buffer.byteLength,
            this.#position,
        );

        this.#position += bytesWritten;
    }

    seek(position) {
        this.#position = position;
    }

    sync() {
        fs.fsyncSync(this.#fd);
    }

    close() {
        fs.closeSync(this.#fd);
    }
}

// Open operations

export function open(path, modes) {
    const flags = translateModes(modes);

    try {
        const fd = fs.openSync(path, flags);
        return Result$Ok(new Handle(fd));
    } catch (error) {
        return errorWithDesc(error);
    }
}

function translateModes(modes) {
    const has = (mode) => {
        let list = modes;
        while (list && list.head) {
            let curr = list.head.constructor.name;
            if (curr == mode) return true;
            list = list.tail;
        }
        return false;
    };

    const read = has("Read");
    const write = has("Write");
    const append = has("Append");
    const exclusive = has("Exclusive");
    const truncate = has("Truncate");

    let flag;

    if (read && write) {
        if (truncate) {
            // w+ : read/write, truncate, create
            flag = "w+";
        } else {
            // r+ : read/write, preserve
            flag = "r+";
        }
    } else if (append) {
        // a = append + create
        flag = "a";

        if (exclusive) {
            flag = "ax";
        }
    } else if (write) {
        // w = write + create + truncate
        flag = "w";

        if (exclusive) {
            flag = "wx";
        }
    } else if (read) {
        // r = read existing
        flag = "r";
    } else {
        throw new Error("Invalid open mode");
    }

    if (has("Binary")) {
        // Node has no binary flag.
        // Buffers are returned by default when encoding is not specified.
    }

    return flag;
}

// Read operations

export function next_byte(handle) {
    try {
        const buffer = handle.read(1);

        if (buffer.byteLength === 0) {
            return endOfFileError();
        }

        return Result$Ok(buffer[0]);
    } catch (error) {
        return errorWithDesc(error);
    }
}


export function read_bytes(handle, count) {
    try {
        const buffer = handle.read(count);

        if (buffer.byteLength === 0) {
            return endOfFileError();
        }

        return Result$Ok(BitArray$BitArray(buffer));
    } catch (error) {
        return errorWithDesc(error);
    }
}

export function next_char(handle) {
    const buffer = handle.read(1);

    if (buffer.byteLength == 0) {
        return endOfFileError();
    }

    const b0 = buffer[0];

    let len;

    if ((b0 & 0x80) === 0x00) {
        len = 1;
    } else if ((b0 & 0xe0) === 0xc0) {
        len = 2;
    } else if ((b0 & 0xf0) === 0xe0) {
        len = 3;
    } else if ((b0 & 0xf8) === 0xf0) {
        len = 4;
    } else {
        return errorWithDesc({
            code: "INVALID_UTF8",
            message: "Invalid UTF-8 leading byte"
        })
    }

    // Read remaining bytes
    if (len > 1) {
        const rest = handle.read(len - 1)
        if (rest.byteLength !== len - 1) {
            return errorWithDesc({
                code: "INVALID_UTF8",
                message: "Unexpected EOF while reading UTF-8 character"
            })
        }
        buffer = Buffer.concat([buffer, rest])
    }

    try {
        let char = utf8Decoder.decode(buffer);
        return Result$Ok(char);
    }
    catch (err) {
        return errorWithDesc({
            code: "INVALID_UTF8",
            message: err.message
        })
    }
}


export function read_line(handle) {
    try {
        let output = "";

        while (true) {
            const char = next_char(handle);

            if (Result$isError(char)) {
                if (Result$Error$0(char)[0] === "EOF") {
                    return Result$Ok(output);
                }
                return char;
            }

            output += Result$Ok$0(char);

            if (output.charAt(output.length - 1) == "\n") {
                return Result$Ok(output);
            }
        }
    } catch (error) {
        return errorWithDesc(error);
    }
}


// Write operations

export function write_bytes(handle, bytes) {
    let data = BitArray$BitArray$data(bytes);

    try {
        handle.write(data);
        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}


export function write_string(handle, string) {
    let data = utf8Encoder.encode(string)
    try {
        handle.write(data);
        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}


export function write_line(handle, string) {
    let data = utf8Encoder.encode(string + "\n")
    try {
        handle.write(data);
        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}


// Generic operations

export function close(handle) {
    try {
        handle.close();

        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}


export function seek(handle, position) {
    try {
        handle.seek(position, 0);

        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}

export function sync(handle) {
    try {
        if (handle.sync) {
            handle.sync();
        }

        return Result$Ok(undefined);
    } catch (error) {
        return errorWithDesc(error);
    }
}

// Standard streams

export function stdin() {
    return new Handle(process.stdin.fd);
}

export function stdin_bin() {
    return new Handle(process.stdin.fd);
}


export function stdout() {
    return new Handle(process.stdout.fd);
}


export function stdout_bin() {
    return new Handle(process.stdout.fd);
}


export function stderr() {
    return new Handle(process.stderr.fd);
}


export function stderr_bin() {
    return new Handle(process.stderr.fd);
}

// Error helper functions

function errorWithDesc(e) {
    return Result$Error([e.code ?? "UNKNOWN", e.message ?? "Unknown error"]);
}

function endOfFileError() {
    return errorWithDesc({ code: "EOF", message: "End of file reached" });
}