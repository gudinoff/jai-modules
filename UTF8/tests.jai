#import "Basic";
#import "String";
#import "UTF8";

main :: () {
    write_strings(
        "#=======================#\n",
        "# Basic tests           #\n"
    );

    tmp_str: string;
    tmp_bool: bool;
    tmp_int: int;

    assert(is_continuation_byte("0€1"[0]) == false);
    assert(is_continuation_byte("0€1"[1]) == false);
    assert(is_continuation_byte("0€1"[2]) == true);
    assert(is_continuation_byte("0€1"[3]) == true);
    assert(is_continuation_byte("0€1"[4]) == false);


    write_strings("# count_character_bytes #\n");
    
    assert(count_character_bytes("0£€𐍈1"[0]) == 1);
    assert(count_character_bytes("0£€𐍈1"[1]) == 2);
    assert(count_character_bytes("0£€𐍈1"[2]) == 1);
    assert(count_character_bytes("0£€𐍈1"[3]) == 3);
    assert(count_character_bytes("0£€𐍈1"[4]) == 1);
    assert(count_character_bytes("0£€𐍈1"[5]) == 1);
    assert(count_character_bytes("0£€𐍈1"[6]) == 4);
    assert(count_character_bytes("0£€𐍈1"[7]) == 1);
    assert(count_character_bytes("0£€𐍈1"[8]) == 1);
    assert(count_character_bytes("0£€𐍈1"[9]) == 1);
    assert(count_character_bytes("0£€𐍈1"[10]) == 1);


    write_strings("# truncate              #\n");
    
    assert(compare(truncate("0£€𐍈1", 0), "") == 0);
    assert(compare(truncate("0£€𐍈1", 1), "0") == 0);
    assert(compare(truncate("0£€𐍈1", 2), "0") == 0);
    assert(compare(truncate("0£€𐍈1", 3), "0£") == 0);
    assert(compare(truncate("0£€𐍈1", 4), "0£") == 0);
    assert(compare(truncate("0£€𐍈1", 5), "0£") == 0);
    assert(compare(truncate("0£€𐍈1", 6), "0£€") == 0);
    assert(compare(truncate("0£€𐍈1", 7), "0£€") == 0);
    assert(compare(truncate("0£€𐍈1", 8), "0£€") == 0);
    assert(compare(truncate("0£€𐍈1", 9), "0£€") == 0);
    assert(compare(truncate("0£€𐍈1", 10), "0£€𐍈") == 0);
    assert(compare(truncate("0£€𐍈1", 11), "0£€𐍈1") == 0);
    assert(compare(truncate("0£€𐍈1", 12), "0£€𐍈1") == 0);


    write_strings("# is_empty              #\n");
    
    assert(is_empty(""));
    assert(is_empty("\0"));
    assert(is_empty("\0\t"));
    assert(is_empty("\0\t\n"));
    assert(is_empty("\0\t\n\x0B"));
    assert(is_empty("\0\t\n\x0B\x0C"));
    assert(is_empty("\0\t\n\x0B\x0C\r"));
    assert(is_empty("\0\t\n\x0B\x0C\r "));
    assert(is_empty("\0\t\n\x0B\x0C\r .") == false);
    assert(is_empty("| B A Z € N G A  |") == false);


    write_strings("# delete_character      #\n");

    tmp_str = copy_string("",, temporary_allocator);
    assert(delete_character(*tmp_str, 0) == false);
    
    tmp_str = copy_string("12£45€78𐍈",, temporary_allocator);
    assert(delete_character(*tmp_str, -1) == false);
    assert(delete_character(*tmp_str, 99999) == false);
    assert(delete_character(*tmp_str, 7) == true);
    assert(compare(tmp_str, "12£45€7𐍈") == 0);
    assert(delete_character(*tmp_str, 2) == true);
    assert(compare(tmp_str, "1245€7𐍈") == 0);
    assert(delete_character(*tmp_str, 4) == true);
    assert(compare(tmp_str, "12457𐍈") == 0);
    assert(delete_character(*tmp_str, 3) == true);
    assert(compare(tmp_str, "1247𐍈") == 0);
    
    
    write_strings("# get_byte_index        #\n");

    tmp_str = copy_string("12£45€78𐍈X",, temporary_allocator);
    
    tmp_int, tmp_bool = get_byte_index("", 0);
    assert(tmp_int == -1 && tmp_bool == false, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, -1);
    assert(tmp_int == -1 && tmp_bool == false, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, -99999);
    assert(tmp_int == -1 && tmp_bool == false, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 99999);
    assert(tmp_int == -1 && tmp_bool == false, "(%, %)", tmp_int, tmp_bool);
    
    tmp_int, tmp_bool = get_byte_index(tmp_str, 0);
    assert(tmp_int == 0 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 1);
    assert(tmp_int == 1 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 2);
    assert(tmp_int == 2 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 3);
    assert(tmp_int == 4 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 4);
    assert(tmp_int == 5 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 5);
    assert(tmp_int == 6 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 6);
    assert(tmp_int == 9 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 7);
    assert(tmp_int == 10 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 8);
    assert(tmp_int == 11 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    tmp_int, tmp_bool = get_byte_index(tmp_str, 9);
    assert(tmp_int == 15 && tmp_bool == true, "(%, %)", tmp_int, tmp_bool);
    
    
    write_strings("# count_characters      #\n");
    
    assert(count_characters("") == 0);
    assert(count_characters("0") == 1);
    assert(count_characters("0£") == 2);
    assert(count_characters("0£€") == 3);
    assert(count_characters("0£€𐍈") == 4);
    assert(count_characters("0£€𐍈1") == 5);
    
    tmp_str = copy_string("123€DELETE",, temporary_allocator);
    tmp_str[6] = 0;
    assert(count_characters(tmp_str) == 10);
    assert(count_characters(tmp_str, true) == 4);


    write_strings("# is_valid              #\n");

    assert(is_valid(""));

    tmp_str = copy_string("123€DELETE",, temporary_allocator);
    tmp_str[6] = 0;
    tmp_bool, tmp_int = is_valid(tmp_str);
    assert(tmp_bool == true && tmp_int == -1, "(%, %)", tmp_bool, tmp_int);

    tmp_str = copy_string("123€DELETE",, temporary_allocator);
    tmp_str[3] = 0; // Cut € at start.
    tmp_bool, tmp_int = is_valid(tmp_str);
    assert(tmp_bool == false && tmp_int == 4, "(%, %)", tmp_bool, tmp_int);
    
    tmp_str = copy_string("123€DELETE",, temporary_allocator);
    tmp_str[4] = 0; // Cut € at middle.
    tmp_bool, tmp_int = is_valid(tmp_str);
    assert(tmp_bool == false && tmp_int == 4, "(%, %)", tmp_bool, tmp_int);

    tmp_str = copy_string("123€DELETE",, temporary_allocator);
    tmp_str[5] = 0; // Cut € at end.
    tmp_bool, tmp_int = is_valid(tmp_str);
    assert(tmp_bool == false && tmp_int == 5, "(%, %)", tmp_bool, tmp_int);

    
    write_strings("  No errors found.\n");
}
