#scope_file

#import "Basic";
#import "System";
#import "Windows";
#import "Windows_Utf8";

    // Code page identifiers.
    CP_UTF8 :: 65001;

    // https://learn.microsoft.com/windows/win32/winprog/windows-data-types
    LPVOID          :: *void;
    BOOL            :: bool;
    CHAR            :: s8;
    WCHAR           :: s16;
    SHORT           :: s16;
    WORD            :: u16;
    DWORD           :: u32;
    LPDWORD         :: *u32;
    UINT            :: u32;
    PINPUT_RECORD   :: *INPUT_RECORD;

    // https://learn.microsoft.com/en-us/windows/console/setconsolemode
    // https://learn.microsoft.com/en-us/windows/console/high-level-console-modes
    Console_Input_Mode :: enum_flags u32 {
        ENABLE_PROCESSED_INPUT;             // If set, control sequences are processed by the system.
        ENABLE_LINE_INPUT;                  // If set, ReadFile and ReadConsole function return on CR; otherwise return when characters are available.
        ENABLE_ECHO_INPUT;                  // If set, Echoes input on screen. Only available if ENABLE_LINE_INPUT is set.
        ENABLE_WINDOW_INPUT;
        ENABLE_MOUSE_INPUT;
        ENABLE_INSERT_MODE;
        _UNUSED_0040_;
        _UNUSED_0080_;
        _UNUSED_0100_;
        ENABLE_VIRTUAL_TERMINAL_INPUT;      // If set, makes user input available to the ReadConsole function.
        _UNUSED_0400_;
        _UNUSED_0800_;
    }
    
    // https://learn.microsoft.com/en-us/windows/console/setconsolemode
    // https://learn.microsoft.com/en-us/windows/console/high-level-console-modes
    Console_Output_Mode :: enum_flags u32 {
        ENABLE_PROCESSED_OUTPUT;            // If set, ASCII control sequences are processed by the system.
        ENABLE_WRAP_AT_EOL_OUTPUT;          // If set, the cursor moves to the beginning of the next row when it reaches the end of the current row.
        ENABLE_VIRTUAL_TERMINAL_PROCESSING; // If set, VT100 control sequences are processed by the system.
        DISABLE_NEWLINE_AUTO_RETURN;
        ENABLE_LVB_GRID_WORLDWIDE;
        _UNUSED_0020_;
        _UNUSED_0040_;
        _UNUSED_0080_;
    }

    COORD :: struct {
        X       : SHORT;
        Y       : SHORT;
    }

    INPUT_RECORD_EVENT_TYPE :: enum u16 {
        KEY_EVENT           :: 0x0001;
        MOUSE_EVENT         :: 0x0002;
        WINDOW_BUFFER_SIZE_EVENT :: 0x0004;
        MENU_EVENT          :: 0x0008;
        FOCUS_EVENT         :: 0x0010;
    }

    INPUT_RECORD :: struct {
        EventType           : INPUT_RECORD_EVENT_TYPE;
        union {
            KeyEvent        : KEY_EVENT_RECORD;
            MouseEvent      : MOUSE_EVENT_RECORD;
            WindowBufferSizeEvent : WINDOW_BUFFER_SIZE_RECORD;
            // These events are used internally and should be ignored.
            MenuEvent       : MENU_EVENT_RECORD;
            FocusEvent      : FOCUS_EVENT_RECORD;
        }
    }

    KEY_EVENT_RECORD :: struct {
        bKeyDown            : BOOL;
        wRepeatCount        : WORD #align 4;
        wVirtualKeyCode     : WORD;
        wVirtualScanCode    : WORD;
        union {
            UnicodeChar     : WCHAR;
            AsciiChar       : CHAR;
        }
        dwControlKeyState   : DWORD;
    }

    MOUSE_EVENT_RECORD :: struct {
        dwMousePosition     : COORD;
        dwButtonState       : DWORD;
        dwControlKeyState   : DWORD;
        dwEventFlags        : DWORD;
    }

    WINDOW_BUFFER_SIZE_RECORD :: struct {
        dwSize              : COORD;
    }

    MENU_EVENT_RECORD :: struct {
        dwCommandId         : UINT;
    }

    FOCUS_EVENT_RECORD :: struct {
        bSetFocus           : BOOL;
    }

    // https://learn.microsoft.com/en-us/windows/console/readconsoleinput
    ReadConsoleInputW :: (hConsoleInput: HANDLE, lpBuffer: PINPUT_RECORD, nLength: DWORD, lpNumberOfEventsRead: LPDWORD) -> success: bool #foreign kernel32;

    // https://learn.microsoft.com/windows/console/readconsole
    ReadConsoleW :: (hConsoleInput: HANDLE, lpBuffer: LPVOID, nNumberOfchars_to_read: DWORD, lpNumberOfchars_read: LPVOID, pInputControl: LPVOID) -> success: bool #foreign kernel32;
    
    // https://learn.microsoft.com/windows/console/flushconsoleinputbuffer
    FlushConsoleInputBuffer :: (hConsoleInput: HANDLE) -> bool #foreign kernel32;

    // https://learn.microsoft.com/windows/console/getnumberofconsoleinputevents
    GetNumberOfConsoleInputEvents :: (hConsoleInput: HANDLE, lpcNumberOfEvents: LPDWORD) -> bool #foreign kernel32;

    // https://learn.microsoft.com/en-us/windows/console/peekconsoleinput
    PeekConsoleInputW :: (hConsoleInput: HANDLE, lpBuffer: PINPUT_RECORD, nLength: DWORD, lpNumberOfEventsRead: LPDWORD) -> bool #foreign kernel32;

////////////////////////////////////////////////////////////////////////////////

    stdin: HANDLE;
    initial_stdin_mode: u32;
    raw_stdin_mode: Console_Input_Mode;

    stdout: HANDLE;
    initial_stdout_mode: u32;
    raw_stdout_mode: Console_Output_Mode;

    was_resized: bool;

    widechar_buffer: [512] u16;

////////////////////////////////////////////////////////////////////////////////

peek_input :: () -> INPUT_RECORD, success := true {
    record: INPUT_RECORD;
    records_read: u32;
    if PeekConsoleInputW(stdin, *record, 1, *records_read) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to peek input: code %, %", error_code, error_string);
        return record, false;
    }
    return record;
}

read_input :: () -> INPUT_RECORD, success := true {
    record: INPUT_RECORD;
    records_read: u32;
    if ReadConsoleInputW(stdin, *record, 1, *records_read) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to read input: code %, %", error_code, error_string);
        return record, false;
    }
    return record;
}

count_input :: () -> u32, success := true {
    count: u32;
    if GetNumberOfConsoleInputEvents(stdin, *count) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to count input: code %, %", error_code, error_string);
        return 0, false;
    }
    return count;
}

////////////////////////////////////////////////////////////////////////////////

#scope_module

OS_prepare_terminal :: () -> success := true {
    
    // stdin
    stdin = GetStdHandle(STD_INPUT_HANDLE);
    if stdin == INVALID_HANDLE_VALUE {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Invalid input handler: code %, %", error_code, error_string);
        return false;
    }
    if xx GetConsoleMode(stdin, *initial_stdin_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to get input mode: code %, %", error_code, error_string);
        return false;
    }
    raw_stdin_mode = (cast(Console_Input_Mode) initial_stdin_mode);
    raw_stdin_mode |= (.ENABLE_VIRTUAL_TERMINAL_INPUT);
    raw_stdin_mode &= ~(.ENABLE_LINE_INPUT | .ENABLE_PROCESSED_INPUT | .ENABLE_ECHO_INPUT);

    if xx SetConsoleMode(stdin, xx raw_stdin_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to set input mode: code %, %", error_code, error_string);
        return false;
    }

    // stdout
    stdout = GetStdHandle(STD_OUTPUT_HANDLE);
    if stdout == INVALID_HANDLE_VALUE {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Invalid output handler: code %, %", error_code, error_string);
        return false;
    }
    if xx GetConsoleMode(stdout, *initial_stdout_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to get output mode: code %, %", error_code, error_string);
        return false;
    }
    raw_stdout_mode = (cast(Console_Output_Mode) initial_stdout_mode);
    raw_stdout_mode |= (.ENABLE_VIRTUAL_TERMINAL_PROCESSING | .ENABLE_PROCESSED_OUTPUT | .ENABLE_WRAP_AT_EOL_OUTPUT);

    if xx SetConsoleMode(stdout, xx raw_stdout_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to set output mode: code %, %", error_code, error_string);
        return false;
    }

    // Acording to [documentation](https://learn.microsoft.com/en-us/windows/win32/intl/code-pages)
    // only the ANSI functions (ending in A) use the Code Page info. The Unicode functions (ending in W)
    // already handle Unicode text.
    // As long we use the Unicode functions, we shouldn't need to set the code page to UTF8.
    // SetConsoleCP(CP_UTF8);
    // SetConsoleOutputCP(CP_UTF8);

    return;
}

OS_reset_terminal :: () -> success := true {
    if xx SetConsoleMode(stdin, initial_stdin_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to reset input mode: code %, %", error_code, error_string);
        return false;
    }
    if xx SetConsoleMode(stdout, initial_stdout_mode) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to reset output mode: code %, %", error_code, error_string);
        return false;
    }
    return;
}

OS_flush_input :: () {
    // This API is not recommended and does not have a virtual terminal equivalent.
    // Attempting to empty the input queue all at once can destroy state in the queue in an unexpected manner.
    if FlushConsoleInputBuffer(stdin) == false {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to flush input: code %, %", error_code, error_string);
    }
}

OS_read_input :: (buffer: *u8, bytes_to_read: s64) -> bytes_read: s64, success := true {

    S32_MAX :: 0x7fff_ffff;
    if (bytes_to_read > S32_MAX) {
        log_tui_error("The Windows API only allows to read up to 2^32 bytes from the standard input. Clamping input argument.");
        bytes_to_read = S32_MAX;
    }

    success: bool;
    bytes_read: s64 = 0;
    available_inputs:, success = count_input();
    
    while bytes_to_read > 0 && available_inputs > 0 {

        record := peek_input();
        
        if record.EventType == {
            case .WINDOW_BUFFER_SIZE_EVENT;
                was_resized = true;
                read_input();
                available_inputs -= 1;

            case .KEY_EVENT;
                if record.KeyEvent.bKeyDown == false {
                    read_input();
                    available_inputs -= 1;
                }
                else {
                
                    widechar_view: [] u16;
                    widechar_view.data = widechar_buffer.data;
                    
                    chars_to_read := ifx available_inputs <= widechar_buffer.count then available_inputs else widechar_buffer.count;
                    
                    success = ReadConsoleW(stdin, widechar_view.data, chars_to_read, *widechar_view.count, null);
                    if success == false {
                        error_code, error_string := get_error_value_and_string();
                        log_tui_error("Failed to read console: code %, %", error_code, error_string);
                        return 0, false;
                    }
                    
                    result:, success = wide_to_utf8_new(widechar_view.data, xx widechar_view.count);
                    if success == false {
                        error_code, error_string := get_error_value_and_string();
                        log_tui_error("Failed to convert from wide to UTF8: code %, %", error_code, error_string);
                        return 0, false;
                    }
                    
                    memcpy(*buffer[bytes_read], result.data, result.count);

                    bytes_to_read -= xx result.count;
                    bytes_read += result.count;

                }

            // Discard other input events.
            case;
                read_input();
            
        }
        available_inputs = count_input();
    }
    return bytes_read;
}

// timeout_milliseconds
//  0: do not wait
// -1: wait indefinitely
OS_wait_for_input :: (timeout_milliseconds: s32 = -1) -> is_input_available: bool, success := true {
    // The Windows API provides all input events (keyboard, mouse, window resize) on a single input buffer.
    // To make it match this module's API, we need to do some pre-processing while waiting for input.
    // This means that OS_wait_for_input will peek at the input events, signal if a window resize is found,
    // and discard unwanted events (like button release events).
    // A similar logic is applied in OS_read_input.
    
    expiration := current_time_monotonic() + to_apollo(timeout_milliseconds / 1000.0);

    // Possible values for poll_return: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject
    WAIT_OBJECT_0       :: 0x00000000;  // Detected input.
    WAIT_TIMEOUT        :: 0x00000102;  // Reached timeout.
    WAIT_FAILED         :: 0xFFFFFFFF;  // Something went wrong.
    
    while true {
        wait_result := WaitForSingleObject(stdin, cast,no_check(u32)timeout_milliseconds);
        
        if wait_result == WAIT_FAILED {
            error_code, error_string := get_error_value_and_string();
            log_tui_error("Error while waiting for input: code %, %", error_code, error_string);
            return false, false;
        }
        
        if wait_result != WAIT_OBJECT_0 then return false;
        
        // Discard invalid input events.
        count := count_input();
        while count > 0 {
            record := peek_input();
            
            if record.EventType == .WINDOW_BUFFER_SIZE_EVENT {
                // Discard any additional resize event.
                while peek_input().EventType == .WINDOW_BUFFER_SIZE_EVENT {
                    read_input();
                }
                
                was_resized = true;
                return false;
            }

            if record.EventType == .KEY_EVENT && record.KeyEvent.bKeyDown == true {
                return true;
            }
            
            read_input();
            count -= 1;
        }
        
        // When waiting indefinitely... just continue.
        if timeout_milliseconds < 0 then continue;

        // Either break due to timeout, or update the remaining timeout.
        now := current_time_monotonic();
        if now >= expiration then break;
        timeout_milliseconds = xx to_milliseconds(expiration - now);
    }

    return false;
}

OS_was_terminal_resized :: inline () -> bool {
    while peek_input().EventType == .WINDOW_BUFFER_SIZE_EVENT {
        was_resized = true;
        read_input();
    }

    defer was_resized = false;
    return was_resized;
}
