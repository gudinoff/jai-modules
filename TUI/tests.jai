// build: jai -import_dir ../ tests.jai
#import "Basic";
TUI :: #import "TUI";

main :: () {

    assert_result :: (result: bool, error_message: string) {
        if result == true {
            print("- success\n", to_standard_error = true);
        }
        else {
            assert(TUI.reset_terminal(), "Failed to reset TUI.");
            print("- ERROR: %\n", error_message, to_standard_error = true);
            exit(1);
        }
    }

    next_line :: inline () {
        x, y := TUI.get_cursor_position();
        TUI.set_cursor_position(1, y+1);
    }
    
    if 1 {
        print("TEST : set and get cursor position\n", to_standard_error = true);
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        X :: 2;
        Y :: 3;
        TUI.set_cursor_position(X, Y);
        x, y := TUI.get_cursor_position();
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(x == X && y == Y, "Failed set/get cursor position.\n");
    }
    
    if 1 {
        print("TEST : test key input\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        TUI.clear_terminal();
        TUI.set_cursor_position(1, 1);
        write_string("Press q to exit, other key to print it to screen, wait 1s to see animation.");
        next_line();
        key: TUI.Key;
        while(key != #char "q") {
            key = TUI.get_key(1000);
            if key == TUI.Keys.None {
                write_string("-");
            }
            else if key == TUI.Keys.Resize {
                write_string("#");
            }
            else {
            // else if key >= 32 && key <= 128 then print_character(cast,force(u8)key)
                write_string(TUI.to_string(key));
            }
        }
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        print("- success\n", to_standard_error = true);
    }
    
    if 1 {
        print("TEST : draw box\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        TUI.flush_input();
        TUI.clear_terminal();
        TUI.draw_box(1, 2, 5, 3);
        TUI.set_cursor_position(1, 1);
        print("Can you see the box below? (y/n)");
        key := TUI.get_key();
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(key == #char "y", "Failed to draw box.\n");
    }
    
    if 1 {
        print("TEST : get terminal size\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        TUI.clear_terminal();
        width, height := TUI.get_terminal_size();
        TUI.set_cursor_position(1, 1);
        print("Is terminal size %x%? (y/n)", width, height);
        key: TUI.Key = xx TUI.Keys.None;
        while (key == xx TUI.Keys.None || key == xx TUI.Keys.Resize) {
            key = TUI.get_key();
        }
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(key == #char "y", "Failed to get terminal size.\n");
    }

    if 1 {
        print("TEST : set terminal title\n", to_standard_error = true);
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        title := "BAZINGA";
        TUI.set_terminal_title(title);
        TUI.set_cursor_position(1, 1);
        print("Is terminal title '%'? (y/n)", title);
        key: TUI.Key = xx TUI.Keys.None;
        while (key == xx TUI.Keys.None || key == xx TUI.Keys.Resize) {
            key = TUI.get_key();
        }
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(key == #char "y", "Failed to set terminal title.\n");
    }
    
    if 1 {
        print("TEST : print keys\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        key: TUI.Key = TUI.Keys.None;
        last_none_char := "X";
        
        width, height := TUI.get_terminal_size();
        TUI.clear_terminal();
        TUI.draw_box(1, 1, width, height);
        drop_down := 0;
        
        while(key != #char "q") {

            if key == {
                case TUI.Keys.None; {
                    TUI.set_cursor_position(2, 2);
                    last_none_char = ifx last_none_char == "X" then "+" else "X";
                    write_strings(last_none_char, " (press: q to exit, c to clear, and any other key to print it's value)");
                }

                case TUI.Keys.Resize; #through;
                case #char "c"; {
                    width, height = TUI.get_terminal_size();
                    TUI.clear_terminal();
                    TUI.draw_box(1, 1, width, height);
                    drop_down = 0;
                }
                
                case; {
                    TUI.set_cursor_position(2, 3+drop_down);
                    str := TUI.to_string(key);
                    array_to_print: [..] string;
                    write_string(": ");
                    for 0..str.count-1 {
                        print("% ", FormatInt.{value = cast(u8)str[it], base=16});
                    }
                    write_string(": ");
                    for 0..str.count-1 {
                        if str[it] == #char "\e" {
                            str[it] = #char "#";
                        }
                    }
                    write_string(str);
                    write_string(" :");
                    drop_down += 1;
                }
            }
            
            x := ifx width > 24 then width-24 else 1;
            y := ifx height > 1 then height-1 else 1;
            
            TUI.set_cursor_position(x, y);
            print("size = %x%\n", width, height);
            key = TUI.get_key(1000);
        }
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(true, "");
    }

    if 1 {
        print("TEST : user input\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        TUI.clear_terminal();
        TUI.set_cursor_position(1, 1);
        print("Enter some text (use Enter to finish, Esc to cancel, or resize to abort):");
        next_line();
        str, key := TUI.read_input_line(15);
        TUI.set_cursor_position(1, 3);
        error_message: string;
        if key == {
            case TUI.Keys.Escape; {
                print("Have you pressed Esc? (y/n)");
                error_message = "Failed to read line on Esc.";
            }

            case TUI.Keys.Resize; {
                print("Have you resized the terminal? (y/n)");
                error_message = "Failed to read line on resize.";
                
            }
            case; {
                print("Have you entered '%'? (y/n)", str);
                error_message = "Failed to read line.";
            }
        }
        answer := TUI.get_key();
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(answer == #char "y", error_message);
    }
    
    if 1 {
        print("TEST : hidden user input\n", to_standard_error = true);
        auto_release_temp();
        assert(TUI.setup_terminal(), "Failed to setup TUI.");
        TUI.clear_terminal();
        TUI.set_cursor_position(1, 1);
        print("Enter some secret (use Enter to finish, Esc to cancel, or resize to abort):");
        next_line();
        str, key := TUI.read_input_line(15, false);
        TUI.set_cursor_position(1, 3);
        error_message: string;
        if key == {
            case TUI.Keys.Escape; {
                print("Have you pressed Esc? (y/n)");
                error_message = "Failed to read line on Esc.";
            }

            case TUI.Keys.Resize; {
                print("Have you resized the terminal? (y/n)");
                error_message = "Failed to read line on resize.";
            }
            case; {
                print("Have you entered '%'? (y/n)", str);
                error_message = "Failed to read line.";
            }
        }
        answer := TUI.get_key();
        assert(TUI.reset_terminal(), "Failed to reset TUI.");
        assert_result(answer == #char "y", error_message);
    }

    // -- -- -- Testing TUI -- STOP
}
