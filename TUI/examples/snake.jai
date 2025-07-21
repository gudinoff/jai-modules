#import "Basic";
#import "Math";
#import "Random";
TUI :: #import "TUI"(COLOR_MODE_BITS = 4);

screen_size_x: int = ---;
screen_size_y: int = ---;
player_name: string = ---;

main :: () {
    // Randomize initial random state.
    seed: u64 = xx to_milliseconds(current_time_monotonic()) | 0x01; // Seed must be odd.
    random_seed(seed);
    
    assert(TUI.setup_terminal(), "Failed to setup TUI.");
    
    // Ask for the player name, and keep it limited to 64 bytes.
    TUI.set_cursor_position(1, 1);
    write_string("Please enter player name: ");
    player_name = TUI.read_input_line(64);

    while true {
        
        game_loop();

        // Draw the game over screen.
        BOX_SIZE_X          :: 20;
        BOX_SIZE_Y          :: 4;
        GAME_OVER_TEXT      :: "~ game over ~"; #assert(GAME_OVER_TEXT.count < BOX_SIZE_X-2);
        INSTRUCTIONS_TEXT   :: "(esc to exit)"; #assert(INSTRUCTIONS_TEXT.count < BOX_SIZE_X-2);
        
        TUI.draw_box((screen_size_x-BOX_SIZE_X)/2, (screen_size_y-BOX_SIZE_Y)/2, BOX_SIZE_X, BOX_SIZE_Y, true);
        TUI.set_cursor_position((screen_size_x-GAME_OVER_TEXT.count)/2, (screen_size_y-BOX_SIZE_Y)/2 + 1);
        write_string(GAME_OVER_TEXT);
        TUI.set_cursor_position((screen_size_x-INSTRUCTIONS_TEXT.count)/2, (screen_size_y-BOX_SIZE_Y)/2 + 2);
        write_string(INSTRUCTIONS_TEXT);
        sleep_milliseconds(100); // Avoid any sudden player input.
        
        // Wait for user input, and exit if the user presses Escape.
        TUI.flush_input();
        if TUI.get_key() == TUI.Keys.Escape then break;
    }

    assert(TUI.reset_terminal(), "Failed to reset TUI.");
}

game_loop :: () {

    Vec2D :: struct {
        x: int;
        y: int;
    }

    operator == :: (a: Vec2D, b: Vec2D) -> bool {
        return a.x == b.x && a.y == b.y;
    }

    LOOP_PERIOD_MS :: 66;

    // Setup game state.
    score := 0;
    dir := Vec2D.{1, 0};
    food := Vec2D.{5, 5};
    snake_parts: [..] Vec2D;
    for 0..13 array_add(*snake_parts, Vec2D.{3, 3});
    snake_parts[0].x += 1;
    
    // Use the default foreground and background colors.
    TUI.set_style(.{ use_default_background_color = true, use_default_foreground_color = true });
    
    // Force to draw the game UI by simulating a terminal resize.
    TUI.flush_input();
    TUI.set_next_key(TUI.Keys.Resize);
        
    while main_loop := true {

        // Setup the module's context string builder to buffer the output on temporary memory and print everything at once.
        auto_release_temp();
        temp_builder := String_Builder.{ allocator = temporary_allocator };
        TUI.using_builder_as_output(*temp_builder);
        defer write_builder(*temp_builder);
        
        // Redirect text output to TUI functions to make use of module's context string builder.
        print :: TUI.tui_print;
        write_string :: TUI.tui_write_string;

        timestamp := current_time_monotonic();
        key := TUI.get_key(LOOP_PERIOD_MS);

        if key == {
            case TUI.Keys.Resize;
                // Draw game UI.
                TUI.clear_terminal();
                screen_size_x, screen_size_y = TUI.get_terminal_size();
                TUI.draw_box(1, 1, screen_size_x, screen_size_y);
                TUI.set_cursor_position(3, screen_size_y);
                print(" % ", player_name);

            case TUI.Keys.Escape;
                break main_loop;

            case TUI.Keys.Up;
                if dir != .{0, 1} then dir = .{0, -1};

            case TUI.Keys.Down;
                if dir != .{0, -1} then dir = .{0, 1};
                
            case TUI.Keys.Left;
                if dir != .{1, 0} then dir = .{-1, 0};

            case TUI.Keys.Right;
                if dir != .{-1, 0} then dir = .{1, 0};
        }

        // Pause game if screen is too small.
        if screen_size_x < 15 || screen_size_y < 15 {
            TUI.clear_terminal();
            TUI.set_cursor_position(1,1);
            write_string("~ paused : increase window size ~");
            continue;
        }

        // Keep snake's last position so we can clear it from screen.
        last_pos := snake_parts[snake_parts.count-1];

        // Update snake position.
        for < snake_parts.count-1..1 {
            if snake_parts[it] != snake_parts[it-1] {
                snake_parts[it] = snake_parts[it-1];
            }
        }
        snake_parts[0].x += dir.x;
        snake_parts[0].y += dir.y;

        // Teleport on borders.
        if snake_parts[0].x < 2                 then snake_parts[0].x = screen_size_x - 1;
        if snake_parts[0].x >= screen_size_x    then snake_parts[0].x = 2;
        if snake_parts[0].y < 2                 then snake_parts[0].y = screen_size_y - 1;
        if snake_parts[0].y >= screen_size_y    then snake_parts[0].y = 2;
        food.x = clamp(food.x, 2, screen_size_x-1);
        food.y = clamp(food.y, 2, screen_size_y-1);

        // Check for game-over.
        for 1..snake_parts.count-1 {
            if snake_parts[it] == snake_parts[0] {
                break main_loop;
            }
        }

        // Check for food.
        if snake_parts[0] == food {
            score += 1;
            array_add(*snake_parts, snake_parts[snake_parts.count-1]);
            food = Vec2D.{
                cast(int)(random_get_zero_to_one_open() * (screen_size_x-3) + 2),
                cast(int)(random_get_zero_to_one_open() * (screen_size_y-3) + 2)
                };
        }
        
        // Wait to match game loop time.
        delta := to_milliseconds(current_time_monotonic() - timestamp);
        if delta < LOOP_PERIOD_MS {
            sleep_milliseconds(xx (LOOP_PERIOD_MS - delta));
        }

        // Draw snake.
        {
            write_string(TUI.Commands.DrawingMode);
            TUI.set_cursor_position(last_pos.x, last_pos.y);
            write_string(TUI.Drawings.Blank);
            for snake_parts {
                TUI.set_cursor_position(it.x, it.y);
                write_string(TUI.Drawings.Checkerboard);
            }
        }
        // Draw food.
        {
            TUI.using_style(TUI.Style.{ foreground = TUI.Palette.RED, bold = true, use_default_background_color = true });
            TUI.set_cursor_position(food.x, food.y);
            write_string(TUI.Drawings.Diamond);
        }
        write_string(TUI.Commands.TextMode);

        // Draw score.
        TUI.set_cursor_position(3, 1);
        print(" % ", score);
    }
}
