// Some procedures to help working with UTF8 strings.
// https://en.wikipedia.org/wiki/UTF-8

// Returns true if argument is a continuation byte.
is_continuation_byte :: inline (byte: u8) -> bool {
    // BBBB BBBB & 1100 0000 == 10XX XXXX -> is continuation byte
   return (byte & 0xC0) == 0x80;
}

// Given a leading_byte, returns the number of bytes on the character.
count_character_bytes :: inline (character_leading_byte: u8) -> int {
    // BBBB BBBB & 1110 0000 == 110X XXXX -> 1 initial + 1 continuation byte
    if (character_leading_byte & 0xE0) == 0xC0 return 1+1;
    
    // BBBB BBBB & 1111 0000 == 1110 XXXX -> 1 initial + 2 continuation byte
    if (character_leading_byte & 0xF0) == 0xE0 return 1+2;
    
    // BBBB BBBB & 1111 1000 == 1111 0XXX -> 1 initial + 3 continuation byte
    if (character_leading_byte & 0xF8) == 0xF0 return 1+3;
    
    return 1;
}

// Returns the string (using same str.data) truncated to the provided length.
truncate :: (str: string, length: int) -> string {
    
    if str.data == null     then return "";

    if str.count < length   then return .{str.count, str.data};
    
    data    := str.data;
    count   := str.count;

    // Find index of first continuation byte.
    idx := length;
    while (idx > 0 && is_continuation_byte(data[idx - 1])) {
        idx -= 1;
    }
    continuation_bytes := length - idx;

    // If string starts with continuation bytes, it's an invalid UTF8 string.
    if (idx == 0 && continuation_bytes > 0) {
        length = 0;
    }
    // If length truncates some continuation bytes, remove incomplete UTF8 character.
    else if (idx > 0 // string is not empty
        // continuation bytes are not complete
        && !(continuation_bytes == 0 && (data[idx - 1] & 0x80) == 0x00)
        && !(continuation_bytes == 1 && (data[idx - 1] & 0xE0) == 0xC0)
        && !(continuation_bytes == 2 && (data[idx - 1] & 0xF0) == 0xE0)
        && !(continuation_bytes == 3 && (data[idx - 1] & 0xF8) == 0xF0)
    ) {
        length -= (continuation_bytes + 1); // Remove start byte, hence '+ 1'.
    }
    
    return .{length, str.data};
}

// Returns true when the string is empty or consists of space characters.
is_empty :: (str: string) -> bool {
    for 0..str.count-1 {
        if str[it] == {
            case #char "\0"; #through;
            case #char "\t"; #through;      // horizontal tab
            case #char "\n"; #through;      // line feed
            case #char "\x0B"; #through;    // vertical tabulation
            case #char "\x0C"; #through;    // form feed
            case #char "\r"; #through;      // carriage return
            case #char " ";
                continue;
            case;
                return false;
        }
    }
    return true;
}

// Counts the number of characters.
count_characters :: (str: string, $is_null_terminated := false) -> int {
    characters := 0;
    idx := 0;
    
    #if is_null_terminated {
        while idx < str.count && str[idx] != 0 {
            idx += count_character_bytes(str[idx]);
            characters += 1;
        }
    }
    else {
        while idx < str.count {
            idx += count_character_bytes(str[idx]);
            characters += 1;
        }
    }
    
    return characters;
}

// Deletes character by it's index, and moves tail data to take its place.
delete_character :: (str: *string, character_idx: int) -> success := true {
    buffer_idx := get_byte_index(str.*, character_idx);

    if buffer_idx < 0 return false;
    
    bytes_to_delete := count_character_bytes(str.data[buffer_idx]);
    
    for buffer_idx..str.count-1-bytes_to_delete {
        str.data[it] = str.data[it+bytes_to_delete];
    }
    for str.count-bytes_to_delete..str.count-1 {
        str.data[it] = 0;
    }
    
    str.count -= bytes_to_delete;
    return;
}

// Searches for the given character index and returns its byte index on the string.
get_byte_index :: (str: string, character_index: int) -> buffer_index: int, success := true {
    buff_idx := 0;
    char_idx := 0;
    while buff_idx < str.count {
        if char_idx == character_index return buff_idx;
        buff_idx += count_character_bytes(str[buff_idx]);
        char_idx += 1;
    }
    return -1, false;
}

// Scans the string for UTF8 encoding errors.
is_valid :: (str: string) -> is_valid := true, error_index: int = -1 {
    idx := 0;
    remainig_bytes := 0;
    while idx < str.count {
        defer idx += 1;
        
        is_continuation := is_continuation_byte(str[idx]);
        
        if (is_continuation && remainig_bytes == 0) || (!is_continuation && remainig_bytes > 0) then return false, idx;
        
        if is_continuation {
            remainig_bytes -= 1;
            continue;
        }
        
        remainig_bytes = count_character_bytes(str[idx]) - 1;
    }
    return;
}
