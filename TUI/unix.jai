#scope_file

#import "Atomics";
#import "System";
#import "POSIX";

    // More info about the structs and enums at:
    // LINUX : https://sourceware.org/git/glibc.git
    // MACOS : https://github.com/apple/darwin-xnu

    #if OS == {
        case .LINUX;
        TCFLAG_T    :: u32;
        SPEED_T     :: u32;

        case .MACOS;
        TCFLAG_T    :: u64;
        SPEED_T     :: u64;
    }

    // Queue selector used in tcflush(...).
    Queue_Selector :: enum s32 {
        #if OS == {
            case .LINUX;
            TCIFLUSH    :: 0;   // Discard data received but not yet read.
            TCOFLUSH    :: 1;   // Discard data written but not yet sent.
            TCIOFLUSH   :: 2;   // Discard all pending data.

            case .MACOS;
            TCIFLUSH    :: 1;   // Discard data received but not yet read.
            TCOFLUSH    :: 2;   // Discard data written but not yet sent.
            TCIOFLUSH   :: 3;   // Discard all pending data.
        }
    }

    // Optional actions used in tcsetattr(...).
    Optional_Actions :: enum s32 {
        TCSANOW         :: 0;   // Change immediately.
        TCSADRAIN       :: 1;   // Change when pending output is written.
        TCSAFLUSH       :: 2;   // Flush pending input before changing.
    }

    // Terminal control (struct termios).
    Terminal_IO_Mode :: struct {

        #if OS == {
            case .LINUX;
            NCCS :: 32;

            case .MACOS;
            NCCS :: 20;
        }
    
        c_iflag     : Input_Modes;          // Input mode flags.
        c_oflag     : Output_Modes;         // Output mode flags.
        c_cflag     : Control_Modes;        // Control modes flags.
        c_lflag     : Local_Modes;          // Local modes flags.
        #if OS == .LINUX {
            c_line      : u8;                   // Line discipline.
        }
        c_cc        : [NCCS]Control_Chars;  // Control characters.
        c_ispeed    : SPEED_T;              // Input speed (baud rates).
        c_ospeed    : SPEED_T;              // Output speed (baud rates).
    }
    
    // Input modes.
    Input_Modes :: enum_flags TCFLAG_T {
        IGNBRK          :: 0x00000001;     // Ignore break condition.
        BRKINT          :: 0x00000002;     // Signal interrupt on break.
        IGNPAR          :: 0x00000004;     // Ignore characters with parity errors.
        PARMRK          :: 0x00000008;     // Mark parity and framing errors.
        INPCK           :: 0x00000010;     // Enable input parity check.
        ISTRIP          :: 0x00000020;     // Strip 8th bit off characters.
        INLCR           :: 0x00000040;     // Map NL to CR on input.
        IGNCR           :: 0x00000080;     // Ignore CR.
        ICRNL           :: 0x00000100;     // Map CR to NL on input.

        #if OS == {
        
            case .LINUX;
            IXON        :: 0x00000400;     // Enable start/stop output control.
            IXANY       :: 0x00000800;     // Any character will restart after stop.
            IXOFF       :: 0x00001000;     // Enable start/stop input control.

            case .MACOS;
            IXON        :: 0x00000200;     // Enable start/stop output control.
            IXANY       :: 0x00000400;     // Any character will restart after stop.
            IXOFF       :: 0x00000800;     // Enable start/stop input control.
        }
    }
    
    // Output modes.
    Output_Modes :: enum_flags TCFLAG_T {
        #if OS == {
        
            case .LINUX;
            OPOST       :: 0x00000001;     // Perform output processing.
            ONLCR       :: 0x00000004;     // Map NL to CR-NL on output.
            OCRNL       :: 0x00000008;     // Map CR to NL.
            ONOCR       :: 0x00000010;     // Discard CR's when on column 0.
            ONLRET      :: 0x00000020;     // Move to column 0 on NL.
            OFILL       :: 0x00000040;     // Send fill characters for delays.

            case .MACOS;
            OPOST       :: 0x00000001;     // Perform output processing.
            ONLCR       :: 0x00000002;     // Map NL to CR-NL on output.
            OCRNL       :: 0x00000010;     // Map CR to NL.
            ONOCR       :: 0x00000020;     // Discard CR's when on column 0.
            ONLRET      :: 0x00000040;     // Move to column 0 on NL.
            OFILL       :: 0x00000080;     // Send fill characters for delays.
        }
    }
    
    // Control modes.
    Control_Modes :: enum TCFLAG_T {
        #if OS == {

            case .LINUX;
            CS5         :: 0x00000000;     // 5 bits per byte.
            CS6         :: 0x00000010;     // 6 bits per byte.
            CS7         :: 0x00000020;     // 7 bits per byte.
            CS8         :: 0x00000030;     // 8 bits per byte.
            CSIZE       :: 0x00000030;     // Number of bits per byte (mask).
            CSTOPB      :: 0x00000040;     // Two stop bits instead of one.
            CREAD       :: 0x00000080;     // Enable receiver.
            PARENB      :: 0x00000100;     // Parity enable.
            PARODD      :: 0x00000200;     // Odd parity instead of even.
            HUPCL       :: 0x00000400;     // Hang up on last close.
            CLOCAL      :: 0x00000800;

            case .MACOS;
            CS5         :: 0x00000000;     // 5 bits per byte.
            CS6         :: 0x00000100;     // 6 bits per byte.
            CS7         :: 0x00000200;     // 7 bits per byte.
            CS8         :: 0x00000300;     // 8 bits per byte.
            CSIZE       :: 0x00000300;     // Number of bits per byte (mask).
            CSTOPB      :: 0x00000400;     // Two stop bits instead of one.
            CREAD       :: 0x00000800;     // Enable receiver.
            PARENB      :: 0x00001000;     // Parity enable.
            PARODD      :: 0x00002000;     // Odd parity instead of even.
            HUPCL       :: 0x00004000;     // Hang up on last close.
            CLOCAL      :: 0x00008000;
        }
    }
    
    // Local modes.
    Local_Modes :: enum_flags TCFLAG_T {
        #if OS == {

            case .LINUX;
            ISIG        :: 0x00000001;     // Enable signals.
            ICANON      :: 0x00000002;     // Canonical input (erase and kill processing).
            ECHO        :: 0x00000008;     // Enable echo.
            ECHOE       :: 0x00000010;     // Visual erase for ERASE.
            ECHOK       :: 0x00000020;     // Echo NL after KILL.
            ECHONL      :: 0x00000040;     // Echo NL even if ECHO is off.
            NOFLSH      :: 0x00000080;     // Disable flush after interrupt or quit.
            TOSTOP      :: 0x00000100;     // Send SIGTTOU for background output.
            IEXTEN      :: 0x00008000;     // Enable DISCARD and LNEXT.

            case .MACOS;
            ISIG        :: 0x00000080;     // Enable signals INTR, QUIT, [D]SUSP.
            ICANON      :: 0x00000100;     // Canonicalize input lines.
            ECHO        :: 0x00000008;     // Enable echo.
            ECHOE       :: 0x00000002;     // Visual erase for ERASE.
            ECHOK       :: 0x00000004;     // Echo NL after KILL.
            ECHONL      :: 0x00000010;     // Echo NL even if ECHO is off.
            NOFLSH      :: 0x80000000;     // Disable flush after interrupt.
            TOSTOP      :: 0x00400000;     // Stop background jobs from output.
            IEXTEN      :: 0x00000400;     // Enable DISCARD and LNEXT.
        }
    }

    // Control Characters
    Control_Chars :: enum u8 {
        // Unused consts:
        // VINTR, VQUIT, VERASE, VKILL, VEOF, VSWTC, VSTART, VSTOP, VSUSP, VEOL, VREPRINT, VDISCARD, VWERASE, VLNEXT, VEOL2
        
        #if OS == {

            case .LINUX;
            VTIME       :: 5;               // Time-out value (tenths of a second) [!ICANON].
            VMIN        :: 6;               // Minimum number of bytes read at once [!ICANON].

            case .MACOS;
            VTIME       :: 17;              // Time-out value (tenths of a second) [!ICANON].
            VMIN        :: 16;              // Minimum number of bytes read at once [!ICANON].
        }
    }
    
    // https://codebrowser.dev/glibc/glibc/sysdeps/unix/sysv/linux/tcsetattr.c.html
    tcsetattr :: (fd: s32, optional_actions: s32, termios_p : *Terminal_IO_Mode) -> s32 #foreign libc;

    // https://codebrowser.dev/glibc/glibc/sysdeps/unix/sysv/linux/tcgetattr.c.html
    tcgetattr :: (fd: s32, termios_p: *Terminal_IO_Mode) -> s32 #foreign libc;

    // https://codebrowser.dev/glibc/glibc/sysdeps/unix/sysv/linux/tcflush.c.html
    tcflush :: (fd: s32, queue_selector: s32) -> s32 #foreign libc;

////////////////////////////////////////////////////////////////////////////////

    initial_tio_mode: Terminal_IO_Mode;
    raw_tio_mode: Terminal_IO_Mode;

    was_resized     : bool;

////////////////////////////////////////////////////////////////////////////////

resize_handler :: (signal_code : s32) #c_call {
	push_context {
	    if signal_code != SIGWINCH then return;
	    atomic_swap(*was_resized, true);
    }
}

prepare_resize_handler :: () {
	sa : sigaction_t;
	sa.sa_handler = resize_handler;
	sigemptyset(*(sa.sa_mask));
	sa.sa_flags = SA_RESTART;
	sigaction(SIGWINCH, *sa, null);
}

restore_resize_handler :: () {
	sa : sigaction_t;
	sa.sa_handler = SIG_DFL;
	sigaction(SIGWINCH, null, *sa);
}

////////////////////////////////////////////////////////////////////////////////

#scope_module

OS_prepare_terminal :: () -> success := true {
    error: int = ---;
    
    error = tcgetattr(STDIN_FILENO, *initial_tio_mode);
    if error {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to get initial_tio_mode: code %, %", error_code, error_string);
        return false;
    }
    
    raw_tio_mode = initial_tio_mode;
    raw_tio_mode.c_iflag &= ~(.IGNBRK | .BRKINT | .PARMRK | .ISTRIP | .INLCR | .IGNCR | .ICRNL | .IXON);
    raw_tio_mode.c_oflag &= ~(.OPOST);
    raw_tio_mode.c_lflag &= ~(.ECHO | .ECHONL | .ICANON | .ISIG | .IEXTEN);
    raw_tio_mode.c_cflag &= ~(.CSIZE | .PARENB);
    raw_tio_mode.c_cflag |= .CS8;
    raw_tio_mode.c_cc[Control_Chars.VMIN] = 1;
    raw_tio_mode.c_cc[Control_Chars.VTIME] = 0;
    
    error = tcsetattr(STDIN_FILENO, xx Optional_Actions.TCSANOW, *raw_tio_mode);
    if error {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to set raw_tio_mode: code %, %", error_code, error_string);
        return false;
    }
    
    was_resized = false;
    prepare_resize_handler();
    return;
}

OS_reset_terminal :: () -> success := true {
    restore_resize_handler();
    error := tcsetattr(STDIN_FILENO, xx Optional_Actions.TCSANOW, *initial_tio_mode);
    if error {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to set initial_tio_mode: code %, %", error_code, error_string);
        return false;
    }
    return;
}

OS_flush_input :: () -> success := true {
    error := tcflush(STDIN_FILENO, xx Queue_Selector.TCIFLUSH);
    if error {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to flush input: code %, %", error_code, error_string);
        return false;
    }
    return;
}

OS_read_input :: (buffer: *u8, bytes_to_read: s64) -> bytes_read: s64, success := true {
    bytes_read := read(STDIN_FILENO, buffer, xx bytes_to_read);
    if bytes_read < 0 {
        error_code, error_string := get_error_value_and_string();
        log_tui_error("Failed to read input: code %, %", error_code, error_string);
        return 0, false;
    }
    return bytes_read;
}

// timeout_milliseconds
//  0: do not wait
// -1: wait indefinitely
OS_wait_for_input :: (timeout_milliseconds: s32 = -1) -> is_input_available: bool, success := true {
    fds     := pollfd.[ .{ fd = STDIN_FILENO, events = POLLIN, revents = 0 } ];
    nfds    := fds.count;
    result  := poll(fds.data, xx nfds, xx timeout_milliseconds); // Returns '-1' with errno '4 | Interrupted system call' on window resize.
    
    if result == -1 {
        error_code, error_string := get_error_value_and_string();
        // Ignore window resize events (error_code 4).
        if error_code != 4 {
            log_tui_error("Unexpected error while waiting for input: code %, %", error_code, error_string);
            return false, false;
        }
    }
    
    return ifx result > 0 then true else false;
}

OS_was_terminal_resized :: inline () -> bool {
    return atomic_swap(*was_resized, false);
}
