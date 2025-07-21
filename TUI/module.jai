/*
    A simple terminal user interface module that provides basic functionalities similar to the [ncurses library](https://en.wikipedia.org/wiki/Ncurses).
    Usefull for creating simple terminal-based apps that require user input.
    View `snake.jai` for an example.
    It has been tested on the following terminal emulators:
    - [GNOME Terminal](https://en.wikipedia.org/wiki/GNOME_Terminal)
    - [kitty](https://en.wikipedia.org/wiki/Kitty_(terminal_emulator))
    - [Konsole](https://en.wikipedia.org/wiki/Konsole)
    - [Linux console](https://en.wikipedia.org/wiki/Linux_console)
    - [xterm](https://en.wikipedia.org/wiki/Xterm)
    - [Windows Terminal](https://en.wikipedia.org/wiki/Windows_Terminal)
*/

#module_parameters(COLOR_MODE_BITS := 24);


#scope_file


#if OS == {
    case .LINUX;
        #load "unix.jai";
    case .MACOS;
        #load "unix.jai";
    case .WINDOWS;
        #load "windows.jai";
    case;
        #assert(false, "Unsupported OS.");
}

#if COLOR_MODE_BITS == {
    case 4;
        #load "palette_4b.jai";
    case 8;
        #load "palette_8b.jai";
    case 24;
        #load "palette_24b.jai";
    case;
        assert(false, "Invalid COLOR_MODE_BITS. Valid values are 4, 8, or 24 (default).");
}

#import "Basic";
#import "String";
#import "Thread";
#import "UTF8";
#load "key_map.jai";

#add_context tui_style  : Style;                    // This contains the last style applied by the module.
#add_context tui_output_builder : *String_Builder;  // If set, this will serve as an output buffer for this module procedures.

KEY_SIZE :: #run type_info(Key).runtime_size;
#assert(input_buffer.count >= KEY_SIZE);            // The input buffer size must be capable to hold an entire Key.

active          := false;
input_override  : Key;
input_string    : string;
input_buffer    : [1024] u8;
temp_builder    := String_Builder.{ allocator = temporary_allocator };


#scope_module


assert_is_active :: inline () {
    assert(active, "Please call setup_terminal() to start using this module.");
}

log_tui_error :: (format_string: string, args: .. Any) {
    write_strings(Commands.SaveCursorPosition, Commands.MainScreenBuffer);
    log_error(format_string, ..args);
    write_strings(Commands.AlternateScreenBuffer, Commands.RestoreCursorPosition);
}


#scope_export;


// Special Graphics Characters.
Drawings :: struct #type_info_none {
    Blank                   :: "\x5F";
    Diamond                 :: "\x60";
    Checkerboard            :: "\x61";
    HorizontalTab           :: "\x62";
    FormFeed                :: "\x63";
    CarriageReturn          :: "\x64";
    LineFeed                :: "\x65";
    DegreeSymbol            :: "\x66";
    PlusMinus               :: "\x67";
    NewLine                 :: "\x68";
    VerticalTab             :: "\x69";
    CornerBR                :: "\x6A";
    CornerTR                :: "\x6B";
    CornerTL                :: "\x6C";
    CornerBL                :: "\x6D";
    Cross                   :: "\x6E";
    LineHT                  :: "\x6F";
    LineHt                  :: "\x70";
    LineH                   :: "\x71";
    LineHb                  :: "\x72";
    LineHB                  :: "\x73";
    TeeL                    :: "\x74";
    TeeR                    :: "\x75";
    TeeB                    :: "\x76";
    TeeT                    :: "\x77";
    LineV                   :: "\x78";
    LessThanOrEqual         :: "\x79";
    GreaterThanOrEqual      :: "\x7A";
    Pi                      :: "\x7B";
    NotEqual                :: "\x7C";
    PoundSign               :: "\x7D";
    CenteredDot             :: "\x7E";
}

// Terminal Escape Codes.
Commands :: struct #type_info_none {

    // Screen buffers
    AlternateScreenBuffer   :: "\e[?1049h";
    MainScreenBuffer        :: "\e[?1049l";

    // Device.
    Bell                    :: "\x07";
    QueryDeviceAttributes   :: "\e[0c";
    
    // Draw/text.
    DrawingMode             :: "\e(0";
    TextMode                :: "\e(B";
    ClearToEndOfScreen      :: "\e[0J";     // From current cursor position (inclusive) to end of screen.
    ClearFromStartOfScreen  :: "\e[1J";     // From start of screen to current cursor position.
    ClearScreen             :: "\e[2J";     // Leaves cursor in top left corner position.
    ClearScrollBack         :: "\e[3J";
    ClearToEndOfLine        :: "\e[0K";     // From current cursor position (inclusive) to end of line.
    ClearFromStartOfLine    :: "\e[1K";     // From start of line to current cursor position.
    ClearLine               :: "\e[2K";
    SetGraphicsRendition    :: "\e[%m";

    // Text Modification.
    InsertCharacters        :: "\e[%@";     // Insert % spaces at curret cursor position (shifts existing text to the right).
    DeleteCharacters        :: "\e[%P";     // Delete % characters at the current cursor position (inserts space characters from the right).
    EraseCharacters         :: "\e[%X";     // Erase % characters from the current cursor position by overwriting them with space characters.
    InsertLines             :: "\e[%L";     // Insert % lines into the buffer at the current cursor position.
    DeleteLines             :: "\e[%M";     // Deletes % lines from the buffer, starting with the row the cursor is on.
    
    // Character encoding.
    EncodingIEC2022         :: "\e%@";
    EncodingUTF8            :: "\e%G";
    
    // Window.
    SetWindowTitle          :: "\e]0;%\e\\";
    RefreshWindow           :: "\e[7t";
    QueryWindowSizeInChars  :: "\e[18t";
    
    // Cursor position.
    SaveCursorPosition      :: "\e7";
    RestoreCursorPosition   :: "\e8";
    SetCursorPosition       :: "\e[%;%H";
    QueryCursorPosition     :: "\e[6n";
    
    // Cursor visibility.
    ShowCursor              :: "\e[?25h";
    HideCursor              :: "\e[?25l";
    StartBlinking           :: "\e[?12h";
    StopBlinking            :: "\e[?12l";
    
    // Cursor shape
    DefaultShape            :: "\e[0 q";
    BlinkingBlockShape      :: "\e[1 q";
    SteadyBlockShape        :: "\e[2 q";
    BlinkingUnderlineShape  :: "\e[3 q";
    SteadyUnderlineShape    :: "\e[4 q";
    BlinkingBarShape        :: "\e[5 q";
    SteadyBarShape          :: "\e[6 q";
    
    // Input mode.
    KeypadAppMode           :: "\e=";
    KeypadNumMode           :: "\e>";
    CursorAppMode           :: "\e[?1h";
    CursorNormalMode        :: "\e[?1l";
}

Style :: struct {
    #if COLOR_MODE_BITS == 4 || COLOR_MODE_BITS == 8 {
        background: Palette;
        foreground: Palette;
    } else {
        background: Color_24b;
        foreground: Color_24b;
    }
    
    background = Palette.BLACK;
    foreground = Palette.WHITE;

    use_default_background_color := false;
    use_default_foreground_color := false;
    
    bold: bool;
    underline: bool;
    strike_through: bool;
    negative: bool;
}

set_style :: (style: Style) {
    // If no tui_output_builder is provided, use a temporary one and discard it afterwards.
    builder := context.tui_output_builder;
    temp_mark: Temporary_Storage_State = ---;
    if context.tui_output_builder == null {
        builder = *temp_builder;
        temp_mark = get_temporary_storage_mark();
    }
    
    #if COLOR_MODE_BITS == {
        case 4;
            print_to_builder(builder,
                #run sprint("%0%0", Commands.SetGraphicsRendition, Commands.SetGraphicsRendition),
                cast(u8)style.foreground + 30, cast(u8)style.background + 40
            );
        
        case 8;
            print_to_builder(builder,
                #run sprint(Commands.SetGraphicsRendition, "38;5;%;48;5;%"),
                cast(u8)style.foreground, cast(u8)style.background
            );

        case 24;
            print_to_builder(builder,
                #run sprint(Commands.SetGraphicsRendition, "38;2;%;%;%;48;2;%;%;%"),
                style.foreground.r, style.foreground.g, style.foreground.b,
                style.background.r, style.background.g, style.background.b
            );
    }

    if style.use_default_foreground_color {
        append(builder, #run sprint(Commands.SetGraphicsRendition, "39"));
    }
    
    if style.use_default_background_color {
        append(builder, #run sprint(Commands.SetGraphicsRendition, "49"));
    }

    if context.tui_output_builder == null {
        write_builder(builder);
        set_temporary_storage_mark(temp_mark);
    }
    
    context.tui_style = style;
}

clear_style :: () {
    write_string(#run sprint(Commands.SetGraphicsRendition, "0"));
    context.tui_style = .{ };
}

using_style :: (style: Style) #expand {
    __style := context.tui_style;
    set_style(style);
    `defer set_style(__style);
}


////////////////////////////////////////////////////////////////////////////////

/*
    We wanted the Key type to represent either UTF-8 encoded characters and also keyboard keys.
    The UTF-8 only requires up to 4 bytes, but some keyboard keys return up to 6 bytes.
    Therefore, we rounded it up to 8 bytes to support all this and more (if needed).
    
    This has to be compatible with: (#char "a" == key) ... so "a" must be stored in the LSB of key
            |-|-|-|-|-|
    string  |a|b|c|0|0|
    key/u64 |0|0|c|b|a| -> that in memory lays as (BE:|0|0|c|b|a|) and (LE:|a|b|c|0|0|)
*/

Key :: u64;

Keys :: struct #type_info_none {
    None        : Key : #run to_key("#none");
    Resize      : Key : #run to_key("#resize");

    Space       : Key : #char " ";
    Enter       : Key : #char "\r";
    Tab         : Key : #char "\t";
    Escape      : Key : 0x00000000_0000001B;
    Backspace   : Key : 0x00000000_0000007F;
    Pause       : Key : 0x00000000_0000001A;
    
    Up          : Key : #run to_key("#up");
    Down        : Key : #run to_key("#down");
    Right       : Key : #run to_key("#right");
    Left        : Key : #run to_key("#left");

    Home        : Key : #run to_key("#home");
    End         : Key : #run to_key("#end");
    Insert      : Key : #run to_key("#ins");
    Delete      : Key : #run to_key("#del");
    PgUp        : Key : #run to_key("#pup");
    PgDown      : Key : #run to_key("#pdown");

    F1          : Key : #run to_key("#f1");
    F2          : Key : #run to_key("#f2");
    F3          : Key : #run to_key("#f3");
    F4          : Key : #run to_key("#f4");
    F5          : Key : #run to_key("#f5");
    F6          : Key : #run to_key("#f6");
    F7          : Key : #run to_key("#f7");
    F8          : Key : #run to_key("#f8");
    F9          : Key : #run to_key("#f9");
    F10         : Key : #run to_key("#f10");
    F11         : Key : #run to_key("#f11");
    F12         : Key : #run to_key("#f12");
}

to_key :: (str: $T) -> Key #modify { return T == ([]u8) || T == string; } {
    assert(str.count <= KEY_SIZE, "Invalid arguments passed to to_key(): 'str' has more than % bytes and cannot be stored as a Key.", KEY_SIZE);
    
    k: Key;
    for 0..str.count-1 {
        k |= ((cast(u64)str[it]) << (it*8));
    }
    return k;
}

to_string :: (key: Key) -> string {
    str := alloc_string(KEY_SIZE);
    str.count = 0;
    while key != 0 {
        str.count += 1;
        str[str.count-1] = xx key & 0xFF;
        key >>= 8;
    }
	return str;
}

is_escape_code :: (key: Key) -> bool {
    beginsWithEscape := ((key & 0xFF) ^ #char "#") == 0;
    hasSomethingElse := (key & (~0xFF)) != 0;
    return beginsWithEscape && hasSomethingElse;
}

////////////////////////////////////////////////////////////////////////////////

is_active :: inline () -> bool {
    return active;
}

// Prepares the terminal to be used by the module.
setup_terminal :: () -> success := true #must {
    if active == true return;

    input_string.data   = input_buffer.data;
    input_string.count  = 0;
    input_override      = xx Keys.None;

    setup_key_map();
    
    write_strings(
        Commands.HideCursor,
        Commands.SaveCursorPosition,
        Commands.AlternateScreenBuffer,
        Commands.EncodingUTF8,
        Commands.CursorNormalMode,
        Commands.KeypadNumMode
        );
    
    if !OS_prepare_terminal() then return false;
    
    active = true;

    return;
}

// Restores the initial terminal settings.
reset_terminal :: () -> success := true #must {
    if active == false return;
    
    active = false;

    clear_style();
    
    if !OS_reset_terminal() then return false;
    
    write_strings(
        Commands.MainScreenBuffer,
        Commands.RestoreCursorPosition,
        Commands.ShowCursor
        );

    reset_key_map();
    
    return;
}

set_next_key :: inline (key: Key) {
    assert_is_active();
    input_override = key;
}

// Returns, with the following priority:
// - last key passed to set_next_key;
// - Keys.Resize if terminal was resized;
// - key pressed by user;
// - Keys.None if everything else fails after the given timeout.
// If timeout is set to -1, it will wait indefinitely by the user input.
get_key :: (timeout_milliseconds: s32 = -1) -> Key {
    assert_is_active();
    
    if input_override != xx Keys.None {
        defer input_override = xx Keys.None;
        return input_override;
    }
    
    if OS_was_terminal_resized() return Keys.Resize;

    // If there's nothing on the input_string buffer, await for input to be available,
    // otherwise, if we have less than a complete Key, check if there's more to read.
    should_read_input := false;
    
    if input_string.count == 0 {
        should_read_input = OS_wait_for_input(timeout_milliseconds);
    }
    else if input_string.count < KEY_SIZE {
        should_read_input = OS_wait_for_input(0);
    }

    if should_read_input {
        // Copy data to the start of the input_string buffer.
        for 0..input_string.count-1 {
            input_buffer[it] = input_string[it];
        }

        // Read input into remaining part of buffer.
        bytes_read := OS_read_input(input_buffer.data + input_string.count, input_buffer.count - input_string.count);
        input_string.data = input_buffer.data;
        input_string.count += bytes_read;
    }

    // The terminal may have been resized while waiting for or reading the input; check it again.
    if OS_was_terminal_resized() return Keys.Resize;

    if input_string.count == 0 return Keys.None;

    // By default, parse a single UTF8 character (1 to 4 bytes).
    to_parse := input_string;
    to_parse.count = count_character_bytes(input_string[0]);
    defer advance(*input_string, to_parse.count); // Advance over parsed input.
    
    // Try to parse escape code.
    if input_string[0] == #char "\e" && input_string.count > 1 {

        // Limit number of chars to parse.
        to_parse.count = ifx input_string.count > KEY_SIZE then KEY_SIZE else input_string.count;

        // Search for the longest escape code.
        key, success := table_find(*key_map, to_parse);
        while success == false && to_parse.count > 1 {
            to_parse.count -= 1;
            key, success = table_find(*key_map, to_parse);
        }


        // If found, return the escape code, otherwise return a single escape character.
        if success {
            return key;
        }
        else {
            to_parse.count = 1;
        }
    }
    
    return to_key(to_parse);
}

// If count_limit has a non-negative value it will be used as the limit to the number of bytes on the returned string.
// If any ASCII characters are provided in the terminators list, they will be used to scan and interrupt the input, including
// the terminator as the last character.
// At least one of the arguments must be properly setup to avoid an infinite-loop reading the input.
read_input :: (count_limit: int = -1, terminators: .. u8) -> string {
    assert_is_active();
    assert(count_limit >= 0 || terminators.count > 0, "Invalid arguments passed to read_input(): when 'count_limit' is less-than 0 (ignored), you need to provide 'terminators' to avoid an infinite-loop.");
    
    // Read until one of the terminator characters is found. 
    // Since we don't know the resulting size of the returned string, we must keep the string builder growing.
    if count_limit < 0 {
        builder: String_Builder;
        init_string_builder(*builder);
        
        while read_loop := true {
            buffer := get_current_buffer(*builder);
            buffer_data := get_buffer_data(buffer);
            
            previous_count := buffer.count;
            buffer.count += OS_read_input(buffer_data + buffer.count, buffer.allocated - buffer.count);

            for previous_count..buffer.count-1 {
                for t: terminators {
                    if buffer_data[it] == t then break read_loop;
                }
            }

            if buffer.count == buffer.allocated then expand(*builder);
            OS_wait_for_input();
        }
        return builder_to_string(*builder);
    }
    // Do the same but limit the number of bytes in the returned string.
    else {
        buffer := alloc_string(count_limit);
        buffer.count = 0;
        
        while read_loop := true {
        
            previous_count := buffer.count;
            buffer.count += OS_read_input(buffer.data + buffer.count, count_limit - buffer.count);
            
            if buffer.count == count_limit then break;
            
            for previous_count..buffer.count-1 {
                for t: terminators {
                    if buffer[it] == t then break read_loop;
                }
            }
            
            OS_wait_for_input();
        }
        
        return buffer;
    }
}

// Uses the get_key to read user input and show it on screen.
// Allows to move the cursor left and right and to delete/backspace.
// Enter  ends the input, returning the input string and the Enter key.
// Escape discards the input returning an empty string and a Escape key.
// Resize discards the input returning an empty string and a Resize key.
read_input_line :: (count_limit: int, is_visible: bool = true) -> string, Key {
    assert_is_active();
    assert(count_limit >= 0, "Invalid arguments passed to read_input_line(): 'count_limit' must be greater-than or equal to 0.");

    // The returned memory must be allocated before we start to use temporary memory.
    // Otherwise, the returned memory would be invalid on calls of type (,, temporary_allocator).
    str := alloc_string(count_limit);
    str.count = 0;
    idx := 0;
    
    x, y := get_cursor_position();
    key := Keys.None;
    
    write_strings(Commands.ShowCursor, Commands.StartBlinking, Commands.BlinkingBarShape);
    
    while true {
        builder := temp_builder;
        
        auto_release_temp();

        chars_count := count_characters(str);

        // Preview input line.
        if is_visible {
            print_to_builder(*builder, Commands.SetCursorPosition, y, x);
            append(*builder, str);
            if count_limit > chars_count then print_to_builder(*builder, Commands.EraseCharacters, count_limit-chars_count);
        }
        else {
            print_to_builder(*builder, Commands.SetCursorPosition, y, x);
            for 1..chars_count append(*builder, "*");
            if count_limit > chars_count print_to_builder(*builder, Commands.EraseCharacters, count_limit-chars_count);
        }
        print_to_builder(*builder, Commands.SetCursorPosition, y, x+idx);
        write_builder(*builder);

        // Process input key.
        key = get_key();
        if key == {
            case Keys.Resize; #through;
            case Keys.Escape; #through;
            case Keys.Enter;
                break;

            case Keys.Left;
                if idx > 0 then idx -= 1;
                
            case Keys.Right;
                if idx < chars_count then idx += 1;
                
            case Keys.Home;
                idx = 0;

            case Keys.End;
                idx = chars_count;

            case Keys.Delete;
                if idx == chars_count continue;
                delete_character(*str, idx);
                
            case Keys.Backspace;
                if idx == 0 continue;
                idx -= 1;
                delete_character(*str, idx);
            
            case;
                if is_escape_code(key) continue;
                
                key_str := to_string(key,, allocator = temporary_allocator);

                // Get the buffer index to insert the next character.
                buff_idx, success := get_byte_index(str, idx);
                if success == false then buff_idx = str.count;

                // Make sure we have space to append the new character at the end (in case we're trying to do it).
                if buff_idx > count_limit - key_str.count then continue;

                // Move text to allow inserting new character.
                for < count_limit-1..buff_idx + key_str.count-1 {
                    str.data[it] = str.data[it-key_str.count];
                }
                
                memcpy(*str.data[buff_idx], key_str.data, key_str.count);
                
                if str.count < count_limit then str.count += key_str.count;
                idx += 1;

                // Truncate string to avoid incomplete utf8 codes on the string tail.
                str.count = truncate(str, count_limit).count;
        }
    }

    write_strings(Commands.StopBlinking, Commands.DefaultShape, Commands.HideCursor);
    
    result := ifx key == Keys.Enter then str else "";
    return result, key;
}

flush_input :: () {
    assert_is_active();
    OS_flush_input();
    input_string.data = input_buffer.data;
    input_string.count = 0;
}

draw_box :: (x: int, y: int, width: int, height: int, clear_inside := false) {
    assert_is_active();
    assert(x > 0 && y > 0 && width > 1 && height > 1, "Invalid arguments passed to draw_box(): 'x' and 'y' must be greater-than 0; 'width' and 'height' must be greater-than 1.");
    
    // If no tui_output_builder is provided, use a temporary one and discard it afterwards.
    builder := context.tui_output_builder;
    temp_mark: Temporary_Storage_State = ---;
    if context.tui_output_builder == null {
        builder = *temp_builder;
        temp_mark = get_temporary_storage_mark();
    }
    
    append(builder, Commands.DrawingMode);
    
    // Draw top line
    print_to_builder(builder, Commands.SetCursorPosition, y, x);
    append(builder, Drawings.CornerTL);
    for 1..width-2 {
        append(builder, Drawings.LineH);
    }
    append(builder, Drawings.CornerTR);

    // Draw left and right sides.
    for idx: y+1..y+height-2 {
        print_to_builder(builder, Commands.SetCursorPosition, idx, x);
        append(builder, Drawings.LineV);
        if clear_inside {
            print_to_builder(builder, Commands.EraseCharacters, width-2);
        }
        print_to_builder(builder, Commands.SetCursorPosition, idx, x+width-1);
        append(builder, Drawings.LineV);
    }
    
    // Draw bottom line.
    print_to_builder(builder, Commands.SetCursorPosition, y+height-1, x);
    append(builder, Drawings.CornerBL);
    for 1..width-2 {
        append(builder, Drawings.LineH);
    }
    append(builder, Drawings.CornerBR);

    append(builder, Commands.TextMode);
    
    if context.tui_output_builder == null {
        write_builder(builder);
        set_temporary_storage_mark(temp_mark);
    }
}

clear_terminal :: inline () {
    assert_is_active();
    write_string(Commands.ClearScreen);
}

get_terminal_size :: () -> width: int, height: int {
    assert_is_active();
    
    auto_release_temp();
    
    flush_input();
    write_string(Commands.QueryWindowSizeInChars);
    
    rows, columns: int = ---;
    if OS_wait_for_input(1) {

        // Expected response format: \e[8;<r>;<c>t
        // where <r> is the number of rows and <c> of columns.
        FORMAT :: "\e[8;<r>;<c>t";
        input := read_input(64, #char "t",, allocator = temporary_allocator);

        // Discard head noise.
        while input.count >= 3 && (input[0] != FORMAT[0] || input[1] != FORMAT[1] || input[2] != FORMAT[2]) {
            advance(*input);
        }

        // Discard tail noise.
        while input.count >= 3 && input[input.count-1] != FORMAT[FORMAT.count-1] {
            input.count -= 1;
        }
        
        assert(input.count >= 3 &&
            input[0] == FORMAT[0] && input[1] == FORMAT[1] && input[2] == FORMAT[2] && input[input.count-1] == FORMAT[FORMAT.count-1],
	        "Failed to query window size: invalid response.");

	    parts := split(input, ";",, allocator = temporary_allocator);
   	    rows = parse_int(*parts[1]);
   	    columns = parse_int(*parts[2]);
    }
    // Some systems don't allow to query the terminal size directly... or the answer takes too much time.
    // In such cases, measure it indirectly by the maximum possible cursor position.
    // (e.g.: allowWindowOps/disallowedWindowOps properties in xterm)
    else {
    	write_string(Commands.SaveCursorPosition);
    	defer write_string(Commands.RestoreCursorPosition);
        
        set_cursor_position(0xFFFF, 0xFFFF,, tui_output_builder = null);
        columns, rows = get_cursor_position();
    }
    
    return columns, rows;
}

// Range between 1 and terminal size.
set_cursor_position :: inline (x: int, y: int) {
    assert_is_active();
    if context.tui_output_builder == null {
        print(Commands.SetCursorPosition, y, x);
    }
    else {
        print_to_builder(context.tui_output_builder, Commands.SetCursorPosition, y, x);
    }
}

// Range between 1 and terminal size.
get_cursor_position :: () -> x: int, y: int {
    assert_is_active();
    
    auto_release_temp();

    flush_input();
    write_string(Commands.QueryCursorPosition);

    // Expected response format: \e[<r>;<c>R
    // where <r> is the number of rows and <c> of columns.
    FORMAT :: "\e[<r>;<c>R";
    input := read_input(64, #char "R",, allocator = temporary_allocator);
    
    // Discard head noise.
    while input.count >= 2 && (input[0] != FORMAT[0] || input[1] != FORMAT[1]) {
        advance(*input);
    }

    // Discard tail noise.
    while input.count >= 2 && input[input.count-1] != FORMAT[FORMAT.count-1] {
        input.count -= 1;
    }
    
    assert(input.count >= 2 &&
        input[0] == FORMAT[0] && input[1] == FORMAT[1] && input[input.count-1] == FORMAT[FORMAT.count-1],
        "Failed to query cursor position: invalid response.");
    
    advance(*input, 2);
    parts := split(input, ";",, allocator = temporary_allocator);
    row := parse_int(*parts[0]);
    column := parse_int(*parts[1]);
    return column, row;
}

set_terminal_title :: inline (title: string) {
    assert_is_active();
    print(Commands.SetWindowTitle, title);
}

// Set the module's context string builder in the current scope context.
using_builder_as_output :: (builder: *String_Builder) #expand {
    __builder := context.tui_output_builder;
    context.tui_output_builder = builder;
    `defer context.tui_output_builder = __builder;
}

// Helper to use the module's context string builder.
tui_print :: inline (format_string: string, args: .. Any) {
    if context.tui_output_builder == null {
        print(format_string, ..args, to_standard_error = false);
    }
    else {
        print_to_builder(context.tui_output_builder, format_string, ..args);
    }
}

// Helper to use the module's context string builder.
tui_write_string :: inline (s: string) {
    if context.tui_output_builder == null {
        write_string(s, to_standard_error = false);
    }
    else {
        append(context.tui_output_builder, s);
    }
}
