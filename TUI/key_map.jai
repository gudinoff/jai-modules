#import "Hash_Table";

key_map: Table(string, Key);

reset_key_map :: () {
    table_reset(*key_map);
    deinit(*key_map);
}

setup_key_map :: () {

    if key_map.count > 0 then return;

    init(*key_map);

    /*
        This table was created/tested using the following terminals:
        - g: gnome terminal
        - i: kitty
        - k: konsole
        - l: linux console
        - w: windows terminal
        - x: xterm
        
        To signal modifier keys, a letter is appended after a + (plus sign):
            "#f1"   -> F1
            "#f1+$" -> F1 + Shift
            "#f1+a" -> F1 + Alt
            "#f1+A" -> F1 + Shift + Alt
            "#f1+c" -> F1 + Ctrl
            "#f1+C" -> F1 + Shift + Ctrl
            "#f1+w" -> F1 + Alt + Ctrl
            "#f1+W" -> F1 + Shift + Alt + Ctrl
            "#f1+s" -> F1 + Super
            "#f1+S" -> F1 + Shift + Super
            "#f1+x" -> F1 + Alt + Super
            "#f1+X" -> F1 + Shift + Alt + Super
            "#f1+y" -> F1 + Ctrl + Super
            "#f1+Y" -> F1 + Shift + Ctrl + Super
            "#f1+z" -> F1 + Alt + Ctrl + Super
            "#f1+Z" -> F1 + Shift + Alt + Ctrl + Super
    */

    // Up                                                   // g i k l w x
    table_set(*key_map, "\e[A",     to_key("#up"));         // + + + + + +
    table_set(*key_map, "\e[1;1A",  to_key("#up"));         //
    table_set(*key_map, "\e[1;2A",  to_key("#up+$"));       // + + +   + +
    table_set(*key_map, "\e[1;3A",  to_key("#up+a"));       // + + +   + +
    table_set(*key_map, "\e[1;4A",  to_key("#up+A"));       // + + +     +
    table_set(*key_map, "\e[1;5A",  to_key("#up+c"));       // + + +   + +
    table_set(*key_map, "\e[1;6A",  to_key("#up+C"));       // + + +     +
    table_set(*key_map, "\e[1;7A",  to_key("#up+w"));       // + + +   + +
    table_set(*key_map, "\e[1;8A",  to_key("#up+W"));       // + + +   + +
    table_set(*key_map, "\e[1;9A",  to_key("#up+s"));       //   +
    table_set(*key_map, "\e[1;10A", to_key("#up+S"));       //   +
    table_set(*key_map, "\e[1;11A", to_key("#up+x"));       //   +
    table_set(*key_map, "\e[1;12A", to_key("#up+X"));       //   +
    table_set(*key_map, "\e[1;13A", to_key("#up+y"));       //   +
    table_set(*key_map, "\e[1;14A", to_key("#up+Y"));       //   +
    table_set(*key_map, "\e[1;15A", to_key("#up+z"));       //   +
    table_set(*key_map, "\e[1;16A", to_key("#up+Z"));       //   +

    // Down                                                 // g i k l w x
    table_set(*key_map, "\e[B",     to_key("#down"));       // + + + + + +
    table_set(*key_map, "\e[1;1B",  to_key("#down"));       //
    table_set(*key_map, "\e[1;2B",  to_key("#down+$"));     // + + +   + +
    table_set(*key_map, "\e[1;3B",  to_key("#down+a"));     // + + +   + +
    table_set(*key_map, "\e[1;4B",  to_key("#down+A"));     // + + +     +
    table_set(*key_map, "\e[1;5B",  to_key("#down+c"));     // + + +   + +
    table_set(*key_map, "\e[1;6B",  to_key("#down+C"));     // + + +     +
    table_set(*key_map, "\e[1;7B",  to_key("#down+w"));     // + + +   + +
    table_set(*key_map, "\e[1;8B",  to_key("#down+W"));     // + + +   + +
    table_set(*key_map, "\e[1;9B",  to_key("#down+s"));     //   +
    table_set(*key_map, "\e[1;10B", to_key("#down+S"));     //   +
    table_set(*key_map, "\e[1;11B", to_key("#down+x"));     //   +
    table_set(*key_map, "\e[1;12B", to_key("#down+X"));     //   +
    table_set(*key_map, "\e[1;13B", to_key("#down+y"));     //   +
    table_set(*key_map, "\e[1;14B", to_key("#down+Y"));     //   +
    table_set(*key_map, "\e[1;15B", to_key("#down+z"));     //   +
    table_set(*key_map, "\e[1;16B", to_key("#down+Z"));     //   +

    // Right                                                // g i k l w x
    table_set(*key_map, "\e[C",     to_key("#right"));      // + + + + + +
    table_set(*key_map, "\e[1;1C",  to_key("#right"));      //
    table_set(*key_map, "\e[1;2C",  to_key("#right+$"));    // + + +   + +
    table_set(*key_map, "\e[1;3C",  to_key("#right+a"));    // + + +   + +
    table_set(*key_map, "\e[1;4C",  to_key("#right+A"));    // + + +     +
    table_set(*key_map, "\e[1;5C",  to_key("#right+c"));    // + + +   + +
    table_set(*key_map, "\e[1;6C",  to_key("#right+C"));    // + + +   + +
    table_set(*key_map, "\e[1;7C",  to_key("#right+w"));    // + + +   + +
    table_set(*key_map, "\e[1;8C",  to_key("#right+W"));    // + + +   + +
    table_set(*key_map, "\e[1;9C",  to_key("#right+s"));    //   +
    table_set(*key_map, "\e[1;10C", to_key("#right+S"));    //   +
    table_set(*key_map, "\e[1;11C", to_key("#right+x"));    //   +
    table_set(*key_map, "\e[1;12C", to_key("#right+X"));    //   +
    table_set(*key_map, "\e[1;13C", to_key("#right+y"));    //   +
    table_set(*key_map, "\e[1;14C", to_key("#right+Y"));    //   +
    table_set(*key_map, "\e[1;15C", to_key("#right+z"));    //   +
    table_set(*key_map, "\e[1;16C", to_key("#right+Z"));    //   +

    // Left                                                 // g i k l w x
    table_set(*key_map, "\e[D",     to_key("#left"));       // + + + + + +
    table_set(*key_map, "\e[1;1D",  to_key("#left"));       //
    table_set(*key_map, "\e[1;2D",  to_key("#left+$"));     // + + +   + +
    table_set(*key_map, "\e[1;3D",  to_key("#left+a"));     // + + +   + +
    table_set(*key_map, "\e[1;4D",  to_key("#left+A"));     // + + +   + +
    table_set(*key_map, "\e[1;5D",  to_key("#left+c"));     // + + +   + +
    table_set(*key_map, "\e[1;6D",  to_key("#left+C"));     // + + +   + +
    table_set(*key_map, "\e[1;7D",  to_key("#left+w"));     // + + +   + +
    table_set(*key_map, "\e[1;8D",  to_key("#left+W"));     // + + +   + +
    table_set(*key_map, "\e[1;9D",  to_key("#left+s"));     //   +
    table_set(*key_map, "\e[1;10D", to_key("#left+S"));     //   +
    table_set(*key_map, "\e[1;11D", to_key("#left+x"));     //   +
    table_set(*key_map, "\e[1;12D", to_key("#left+X"));     //   +
    table_set(*key_map, "\e[1;13D", to_key("#left+y"));     //   +
    table_set(*key_map, "\e[1;14D", to_key("#left+Y"));     //   +
    table_set(*key_map, "\e[1;15D", to_key("#left+z"));     //   +
    table_set(*key_map, "\e[1;16D", to_key("#left+Z"));     //   +

    // Home                                                 // g i k l w x
    table_set(*key_map, "\e[1~",    to_key("#home"));       //       +
    table_set(*key_map, "\e[H",     to_key("#home"));       // + + +   + +
    table_set(*key_map, "\e[1;1H",  to_key("#home"));       //
    table_set(*key_map, "\e[1;2H",  to_key("#home+$"));     // + + +   + +
    table_set(*key_map, "\e[1;3H",  to_key("#home+a"));     // + + +   + +
    table_set(*key_map, "\e[1;4H",  to_key("#home+A"));     // + + +   + +
    table_set(*key_map, "\e[1;5H",  to_key("#home+c"));     // + + +   + +
    table_set(*key_map, "\e[1;6H",  to_key("#home+C"));     // + + +     +
    table_set(*key_map, "\e[1;7H",  to_key("#home+w"));     // + + +   + +
    table_set(*key_map, "\e[1;8H",  to_key("#home+W"));     // + + +   + +
    table_set(*key_map, "\e[1;9H",  to_key("#home+s"));     //   +
    table_set(*key_map, "\e[1;10H", to_key("#home+S"));     //   +
    table_set(*key_map, "\e[1;11H", to_key("#home+x"));     //   +
    table_set(*key_map, "\e[1;12H", to_key("#home+X"));     //   +
    table_set(*key_map, "\e[1;13H", to_key("#home+y"));     //   +
    table_set(*key_map, "\e[1;14H", to_key("#home+Y"));     //   +
    table_set(*key_map, "\e[1;15H", to_key("#home+z"));     //   +
    table_set(*key_map, "\e[1;16H", to_key("#home+Z"));     //   +

    // End                                                  // g i k l w x
    table_set(*key_map, "\e[4~",    to_key("#end"));        //       +
    table_set(*key_map, "\e[F",     to_key("#end"));        // + + +   + +
    table_set(*key_map, "\e[1;1F",  to_key("#end"));        //
    table_set(*key_map, "\e[1;2F",  to_key("#end+$"));      // + + +   + +
    table_set(*key_map, "\e[1;3F",  to_key("#end+a"));      // + + +   + +
    table_set(*key_map, "\e[1;4F",  to_key("#end+A"));      // + + +   + +
    table_set(*key_map, "\e[1;5F",  to_key("#end+c"));      // + + +     +
    table_set(*key_map, "\e[1;6F",  to_key("#end+C"));      // + + +     +
    table_set(*key_map, "\e[1;7F",  to_key("#end+w"));      // + + +   + +
    table_set(*key_map, "\e[1;8F",  to_key("#end+W"));      // + + +   + +
    table_set(*key_map, "\e[1;9F",  to_key("#end+s"));      //   +
    table_set(*key_map, "\e[1;10F", to_key("#end+S"));      //   +
    table_set(*key_map, "\e[1;11F", to_key("#end+x"));      //   +
    table_set(*key_map, "\e[1;12F", to_key("#end+X"));      //   +
    table_set(*key_map, "\e[1;13F", to_key("#end+y"));      //   +
    table_set(*key_map, "\e[1;14F", to_key("#end+Y"));      //   +
    table_set(*key_map, "\e[1;15F", to_key("#end+z"));      //   +
    table_set(*key_map, "\e[1;16F", to_key("#end+Z"));      //   +

    // Insert                                               // g i k l w x
    table_set(*key_map, "\e[2~",    to_key("#ins"));        // + + + + + +
    table_set(*key_map, "\e[2;1~",  to_key("#ins"));        //
    table_set(*key_map, "\e[2;2~",  to_key("#ins+$"));      // + + +   + +
    table_set(*key_map, "\e[2;3~",  to_key("#ins+a"));      // + + +   + +
    table_set(*key_map, "\e[2;4~",  to_key("#ins+A"));      // + + +   + +
    table_set(*key_map, "\e[2;5~",  to_key("#ins+c"));      // + + +   + +
    table_set(*key_map, "\e[2;6~",  to_key("#ins+C"));      // + + +   + +
    table_set(*key_map, "\e[2;7~",  to_key("#ins+w"));      // + + +   + +
    table_set(*key_map, "\e[2;8~",  to_key("#ins+W"));      // + + +   + +
    table_set(*key_map, "\e[2;9~",  to_key("#ins+s"));      //   +
    table_set(*key_map, "\e[2;10~", to_key("#ins+S"));      //   +
    table_set(*key_map, "\e[2;11~", to_key("#ins+x"));      //   +
    table_set(*key_map, "\e[2;12~", to_key("#ins+X"));      //   +
    table_set(*key_map, "\e[2;13~", to_key("#ins+y"));      //   +
    table_set(*key_map, "\e[2;14~", to_key("#ins+Y"));      //   +
    table_set(*key_map, "\e[2;15~", to_key("#ins+z"));      //   +
    table_set(*key_map, "\e[2;16~", to_key("#ins+Z"));      //   +

    // Delete                                               // g i k l w x
    table_set(*key_map, "\e[3~",    to_key("#del"));        // + + + + + +
    table_set(*key_map, "\e[3;1~",  to_key("#del"));        //
    table_set(*key_map, "\e[3;2~",  to_key("#del+$"));      // + + +   + +
    table_set(*key_map, "\e[3;3~",  to_key("#del+a"));      // + + +   + +
    table_set(*key_map, "\e[3;4~",  to_key("#del+A"));      // + + +   + +
    table_set(*key_map, "\e[3;5~",  to_key("#del+c"));      // + + +   + +
    table_set(*key_map, "\e[3;6~",  to_key("#del+C"));      // + + +   + +
    table_set(*key_map, "\e[3;7~",  to_key("#del+w"));      // + + +   + +
    table_set(*key_map, "\e[3;8~",  to_key("#del+W"));      // + + +   + +
    table_set(*key_map, "\e[3;9~",  to_key("#del+s"));      //   +
    table_set(*key_map, "\e[3;10~", to_key("#del+S"));      //   +
    table_set(*key_map, "\e[3;11~", to_key("#del+x"));      //   +
    table_set(*key_map, "\e[3;12~", to_key("#del+X"));      //   +
    table_set(*key_map, "\e[3;13~", to_key("#del+y"));      //   +
    table_set(*key_map, "\e[3;14~", to_key("#del+Y"));      //   +
    table_set(*key_map, "\e[3;15~", to_key("#del+z"));      //   +
    table_set(*key_map, "\e[3;16~", to_key("#del+Z"));      //   +

    // Page Up                                              // g i k l w x
    table_set(*key_map, "\e[5~",    to_key("#pup"));        // + + + + + +
    table_set(*key_map, "\e[5;1~",  to_key("#pup"));        //
    table_set(*key_map, "\e[5;2~",  to_key("#pup+$"));      // + + +   + +
    table_set(*key_map, "\e[5;3~",  to_key("#pup+a"));      // + + +   + +
    table_set(*key_map, "\e[5;4~",  to_key("#pup+A"));      // + + +   + +
    table_set(*key_map, "\e[5;5~",  to_key("#pup+c"));      // + + +   + +
    table_set(*key_map, "\e[5;6~",  to_key("#pup+C"));      // + + +     +
    table_set(*key_map, "\e[5;7~",  to_key("#pup+w"));      // + + +   + +
    table_set(*key_map, "\e[5;8~",  to_key("#pup+W"));      // + + +   + +
    table_set(*key_map, "\e[5;9~",  to_key("#pup+s"));      //   +
    table_set(*key_map, "\e[5;10~", to_key("#pup+S"));      //   +
    table_set(*key_map, "\e[5;11~", to_key("#pup+x"));      //   +
    table_set(*key_map, "\e[5;12~", to_key("#pup+X"));      //   +
    table_set(*key_map, "\e[5;13~", to_key("#pup+y"));      //   +
    table_set(*key_map, "\e[5;14~", to_key("#pup+Y"));      //   +
    table_set(*key_map, "\e[5;15~", to_key("#pup+z"));      //   +
    table_set(*key_map, "\e[5;16~", to_key("#pup+Z"));      //   +

    // Page Down                                            // g i k l w x
    table_set(*key_map, "\e[6~",    to_key("#pdown"));      // + + + + + +
    table_set(*key_map, "\e[6;1~",  to_key("#pdown"));      //
    table_set(*key_map, "\e[6;2~",  to_key("#pdown+$"));    // + + +   + +
    table_set(*key_map, "\e[6;3~",  to_key("#pdown+a"));    // + + +   + +
    table_set(*key_map, "\e[6;4~",  to_key("#pdown+A"));    // + + +   + +
    table_set(*key_map, "\e[6;5~",  to_key("#pdown+c"));    // + + +   + +
    table_set(*key_map, "\e[6;6~",  to_key("#pdown+C"));    // + + +     +
    table_set(*key_map, "\e[6;7~",  to_key("#pdown+w"));    // + + +   + +
    table_set(*key_map, "\e[6;8~",  to_key("#pdown+W"));    // + + +   + +
    table_set(*key_map, "\e[6;9~",  to_key("#pdown+s"));    //   +
    table_set(*key_map, "\e[6;10~", to_key("#pdown+S"));    //   +
    table_set(*key_map, "\e[6;11~", to_key("#pdown+x"));    //   +
    table_set(*key_map, "\e[6;12~", to_key("#pdown+X"));    //   +
    table_set(*key_map, "\e[6;13~", to_key("#pdown+y"));    //   +
    table_set(*key_map, "\e[6;14~", to_key("#pdown+Y"));    //   +
    table_set(*key_map, "\e[6;15~", to_key("#pdown+z"));    //   +
    table_set(*key_map, "\e[6;16~", to_key("#pdown+Z"));    //   +

    // F1                                                   // g i k l w x
    table_set(*key_map, "\e[[A",    to_key("#f1"));         //       +
    table_set(*key_map, "\e[25~",   to_key("#f1+$"));       //       +
    table_set(*key_map, "\eOP",     to_key("#f1"));         // + + +   + +
    table_set(*key_map, "\eO1P",    to_key("#f1+s"));       //     +
    table_set(*key_map, "\eO2P",    to_key("#f1+$"));       //     +
    table_set(*key_map, "\eO3P",    to_key("#f1+a"));       //     +
    table_set(*key_map, "\eO4P",    to_key("#f1+A"));       //     +
    table_set(*key_map, "\eO5P",    to_key("#f1+c"));       //     +
    table_set(*key_map, "\eO6P",    to_key("#f1+C"));       //     +
    table_set(*key_map, "\eO7P",    to_key("#f1+w"));       //     +
    table_set(*key_map, "\eO8P",    to_key("#f1+W"));       //     +
    table_set(*key_map, "\e[1P",    to_key("#f1"));         //
    table_set(*key_map, "\e[1;1P",  to_key("#f1"));         //
    table_set(*key_map, "\e[1;2P",  to_key("#f1+$"));       // + +     + +
    table_set(*key_map, "\e[1;3P",  to_key("#f1+a"));       // + +     + +
    table_set(*key_map, "\e[1;4P",  to_key("#f1+A"));       // + +     + +
    table_set(*key_map, "\e[1;5P",  to_key("#f1+c"));       // + +     + +
    table_set(*key_map, "\e[1;6P",  to_key("#f1+C"));       // + +     + +
    table_set(*key_map, "\e[1;7P",  to_key("#f1+w"));       // + +     + +
    table_set(*key_map, "\e[1;8P",  to_key("#f1+W"));       // + +     + +
    table_set(*key_map, "\e[1;9P",  to_key("#f1+s"));       //   +
    table_set(*key_map, "\e[1;10P", to_key("#f1+S"));       //   +
    table_set(*key_map, "\e[1;11P", to_key("#f1+x"));       //   +
    table_set(*key_map, "\e[1;12P", to_key("#f1+X"));       //   +
    table_set(*key_map, "\e[1;13P", to_key("#f1+y"));       //   +
    table_set(*key_map, "\e[1;14P", to_key("#f1+Y"));       //   +
    table_set(*key_map, "\e[1;15P", to_key("#f1+z"));       //   +
    table_set(*key_map, "\e[1;16P", to_key("#f1+Z"));       //   +

    // F2                                                   // g i k l w x
    table_set(*key_map, "\e[[B",    to_key("#f2"));         //       +
    table_set(*key_map, "\e[26~",   to_key("#f2+$"));       //       +
    table_set(*key_map, "\eOQ",     to_key("#f2"));         // + + +   + +
    table_set(*key_map, "\eO1Q",    to_key("#f2+s"));       //     +
    table_set(*key_map, "\eO2Q",    to_key("#f2+$"));       //     +
    table_set(*key_map, "\eO3Q",    to_key("#f2+a"));       //     +
    table_set(*key_map, "\eO4Q",    to_key("#f2+A"));       //     +
    table_set(*key_map, "\eO5Q",    to_key("#f2+c"));       //     +
    table_set(*key_map, "\eO6Q",    to_key("#f2+C"));       //     +
    table_set(*key_map, "\eO7Q",    to_key("#f2+w"));       //     +
    table_set(*key_map, "\eO8Q",    to_key("#f2+W"));       //     +
    table_set(*key_map, "\e[1Q",    to_key("#f2"));         //
    table_set(*key_map, "\e[1;1Q",  to_key("#f2"));         //
    table_set(*key_map, "\e[1;2Q",  to_key("#f2+$"));       // + +     + +
    table_set(*key_map, "\e[1;3Q",  to_key("#f2+a"));       // + +     + +
    table_set(*key_map, "\e[1;4Q",  to_key("#f2+A"));       // + +     + +
    table_set(*key_map, "\e[1;5Q",  to_key("#f2+c"));       // + +     + +
    table_set(*key_map, "\e[1;6Q",  to_key("#f2+C"));       // + +     + +
    table_set(*key_map, "\e[1;7Q",  to_key("#f2+w"));       // + +     + +
    table_set(*key_map, "\e[1;8Q",  to_key("#f2+W"));       // + +     + +
    table_set(*key_map, "\e[1;9Q",  to_key("#f2+s"));       //   +
    table_set(*key_map, "\e[1;10Q", to_key("#f2+S"));       //   +
    table_set(*key_map, "\e[1;11Q", to_key("#f2+x"));       //   +
    table_set(*key_map, "\e[1;12Q", to_key("#f2+X"));       //   +
    table_set(*key_map, "\e[1;13Q", to_key("#f2+y"));       //   +
    table_set(*key_map, "\e[1;14Q", to_key("#f2+Y"));       //   +
    table_set(*key_map, "\e[1;15Q", to_key("#f2+z"));       //   +
    table_set(*key_map, "\e[1;16Q", to_key("#f2+Z"));       //   +

    // F3                                                   // g i k l w x
    table_set(*key_map, "\e[[C",    to_key("#f3"));         //       +
    table_set(*key_map, "\e[28~",   to_key("#f3+$"));       //       +
    table_set(*key_map, "\eOR",     to_key("#f3"));         // + + +   + +
    table_set(*key_map, "\eO1R",    to_key("#f3+s"));       //     +
    table_set(*key_map, "\eO2R",    to_key("#f3+$"));       //     +
    table_set(*key_map, "\eO3R",    to_key("#f3+a"));       //     +
    table_set(*key_map, "\eO4R",    to_key("#f3+A"));       //     +
    table_set(*key_map, "\eO5R",    to_key("#f3+c"));       //     +
    table_set(*key_map, "\eO6R",    to_key("#f3+C"));       //     +
    table_set(*key_map, "\eO7R",    to_key("#f3+w"));       //     +
    table_set(*key_map, "\eO8R",    to_key("#f3+W"));       //     +
    table_set(*key_map, "\e[1R",    to_key("#f3"));         //
    table_set(*key_map, "\e[1;1R",  to_key("#f3"));         //
    table_set(*key_map, "\e[1;2R",  to_key("#f3+$"));       // + +     + +
    table_set(*key_map, "\e[1;3R",  to_key("#f3+a"));       // + +     + +
    table_set(*key_map, "\e[1;4R",  to_key("#f3+A"));       // + +     + +
    table_set(*key_map, "\e[1;5R",  to_key("#f3+c"));       // + +     + +
    table_set(*key_map, "\e[1;6R",  to_key("#f3+C"));       // + +     + +
    table_set(*key_map, "\e[1;7R",  to_key("#f3+w"));       // + +     + +
    table_set(*key_map, "\e[1;8R",  to_key("#f3+W"));       // + +     + +
    table_set(*key_map, "\e[1;9R",  to_key("#f3+s"));       //   +
    table_set(*key_map, "\e[1;10R", to_key("#f3+S"));       //   +
    table_set(*key_map, "\e[1;11R", to_key("#f3+x"));       //   +
    table_set(*key_map, "\e[1;12R", to_key("#f3+X"));       //   +
    table_set(*key_map, "\e[1;13R", to_key("#f3+y"));       //   +
    table_set(*key_map, "\e[1;14R", to_key("#f3+Y"));       //   +
    table_set(*key_map, "\e[1;15R", to_key("#f3+z"));       //   +
    table_set(*key_map, "\e[1;16R", to_key("#f3+Z"));       //   +

    // F4                                                   // g i k l w x
    table_set(*key_map, "\e[[D",    to_key("#f4"));         //       +
    table_set(*key_map, "\e[29~",   to_key("#f4+$"));       //       +
    table_set(*key_map, "\eOS",     to_key("#f4"));         // + + +   + +
    table_set(*key_map, "\eO1S",    to_key("#f4+s"));       //     +
    table_set(*key_map, "\eO2S",    to_key("#f4+$"));       //     +
    table_set(*key_map, "\eO3S",    to_key("#f4+a"));       //     +
    table_set(*key_map, "\eO4S",    to_key("#f4+A"));       //     +
    table_set(*key_map, "\eO5S",    to_key("#f4+c"));       //     +
    table_set(*key_map, "\eO6S",    to_key("#f4+C"));       //     +
    table_set(*key_map, "\eO7S",    to_key("#f4+w"));       //     +
    table_set(*key_map, "\eO8S",    to_key("#f4+W"));       //     +
    table_set(*key_map, "\e[1S",    to_key("#f4"));         //
    table_set(*key_map, "\e[1;1S",  to_key("#f4"));         //
    table_set(*key_map, "\e[1;2S",  to_key("#f4+$"));       // + +     + +
    table_set(*key_map, "\e[1;3S",  to_key("#f4+a"));       // + +     + +
    table_set(*key_map, "\e[1;4S",  to_key("#f4+A"));       // + +     + +
    table_set(*key_map, "\e[1;5S",  to_key("#f4+c"));       // + +     + +
    table_set(*key_map, "\e[1;6S",  to_key("#f4+C"));       // + +     + +
    table_set(*key_map, "\e[1;7S",  to_key("#f4+w"));       // + +     + +
    table_set(*key_map, "\e[1;8S",  to_key("#f4+W"));       // + +     + +
    table_set(*key_map, "\e[1;9S",  to_key("#f4+s"));       //   +
    table_set(*key_map, "\e[1;10S", to_key("#f4+S"));       //   +
    table_set(*key_map, "\e[1;11S", to_key("#f4+x"));       //   +
    table_set(*key_map, "\e[1;12S", to_key("#f4+X"));       //   +
    table_set(*key_map, "\e[1;13S", to_key("#f4+y"));       //   +
    table_set(*key_map, "\e[1;14S", to_key("#f4+Y"));       //   +
    table_set(*key_map, "\e[1;15S", to_key("#f4+z"));       //   +
    table_set(*key_map, "\e[1;16S", to_key("#f4+Z"));       //   +

    // F5                                                   // g i k l w x
    table_set(*key_map, "\e[[E",    to_key("#f5"));         //       +
    table_set(*key_map, "\e[31~",   to_key("#f5+$"));       //       +
    table_set(*key_map, "\e[15~",   to_key("#f5"));         // + + +   + +
    table_set(*key_map, "\e[15;1~", to_key("#f5"));         //
    table_set(*key_map, "\e[15;2~", to_key("#f5+$"));       // + + +   + +
    table_set(*key_map, "\e[15;3~", to_key("#f5+a"));       // + + +   + +
    table_set(*key_map, "\e[15;4~", to_key("#f5+A"));       // + + +   + +
    table_set(*key_map, "\e[15;5~", to_key("#f5+c"));       // + + +   + +
    table_set(*key_map, "\e[15;6~", to_key("#f5+C"));       // + + +   + +
    table_set(*key_map, "\e[15;7~", to_key("#f5+w"));       // + + +   + +
    table_set(*key_map, "\e[15;8~", to_key("#f5+W"));       // + + +   + +
    table_set(*key_map, "\e[15;9~", to_key("#f5+s"));       //   +
    table_set(*key_map, "\e[15;10~",to_key("#f5+S"));       //   +
    table_set(*key_map, "\e[15;11~",to_key("#f5+x"));       //   +
    table_set(*key_map, "\e[15;12~",to_key("#f5+X"));       //   +
    table_set(*key_map, "\e[15;13~",to_key("#f5+y"));       //   +
    table_set(*key_map, "\e[15;14~",to_key("#f5+Y"));       //   +
    table_set(*key_map, "\e[15;15~",to_key("#f5+z"));       //   +
    table_set(*key_map, "\e[15;16~",to_key("#f5+Z"));       //   +

    // F6                                                   // g i k l w x
    table_set(*key_map, "\e[32~",   to_key("#f6+$"));       //       +
    table_set(*key_map, "\e[17~",   to_key("#f6"));         // + + + + + +
    table_set(*key_map, "\e[17;1~", to_key("#f6"));         //
    table_set(*key_map, "\e[17;2~", to_key("#f6+$"));       // + + +   + +
    table_set(*key_map, "\e[17;3~", to_key("#f6+a"));       // + + +   + +
    table_set(*key_map, "\e[17;4~", to_key("#f6+A"));       // + + +   + +
    table_set(*key_map, "\e[17;5~", to_key("#f6+c"));       // + + +   + +
    table_set(*key_map, "\e[17;6~", to_key("#f6+C"));       // + + +   + +
    table_set(*key_map, "\e[17;7~", to_key("#f6+w"));       // + + +   + +
    table_set(*key_map, "\e[17;8~", to_key("#f6+W"));       // + + +   + +
    table_set(*key_map, "\e[17;9~", to_key("#f6+s"));       //   +
    table_set(*key_map, "\e[17;10~",to_key("#f6+S"));       //   +
    table_set(*key_map, "\e[17;11~",to_key("#f6+x"));       //   +
    table_set(*key_map, "\e[17;12~",to_key("#f6+X"));       //   +
    table_set(*key_map, "\e[17;13~",to_key("#f6+y"));       //   +
    table_set(*key_map, "\e[17;14~",to_key("#f6+Y"));       //   +
    table_set(*key_map, "\e[17;15~",to_key("#f6+z"));       //   +
    table_set(*key_map, "\e[17;16~",to_key("#f6+Z"));       //   +

    // F7                                                   // g i k l w x
    table_set(*key_map, "\e[33~",   to_key("#f7+$"));       //       +
    table_set(*key_map, "\e[18~",   to_key("#f7"));         // + + + + + +
    table_set(*key_map, "\e[18;1~", to_key("#f7"));         //
    table_set(*key_map, "\e[18;2~", to_key("#f7+$"));       // + + +   + +
    table_set(*key_map, "\e[18;3~", to_key("#f7+a"));       // + + +   + +
    table_set(*key_map, "\e[18;4~", to_key("#f7+A"));       // + + +   + +
    table_set(*key_map, "\e[18;5~", to_key("#f7+c"));       // + + +   + +
    table_set(*key_map, "\e[18;6~", to_key("#f7+C"));       // + + +   + +
    table_set(*key_map, "\e[18;7~", to_key("#f7+w"));       // + + +   + +
    table_set(*key_map, "\e[18;8~", to_key("#f7+W"));       // + + +   + +
    table_set(*key_map, "\e[18;9~", to_key("#f7+s"));       //   +
    table_set(*key_map, "\e[18;10~",to_key("#f7+S"));       //   +
    table_set(*key_map, "\e[18;11~",to_key("#f7+x"));       //   +
    table_set(*key_map, "\e[18;12~",to_key("#f7+X"));       //   +
    table_set(*key_map, "\e[18;13~",to_key("#f7+y"));       //   +
    table_set(*key_map, "\e[18;14~",to_key("#f7+Y"));       //   +
    table_set(*key_map, "\e[18;15~",to_key("#f7+z"));       //   +
    table_set(*key_map, "\e[18;16~",to_key("#f7+Z"));       //   +

    // F8                                                   // g i k l w x
    table_set(*key_map, "\e[34~",   to_key("#f8+$"));       //       +
    table_set(*key_map, "\e[19~",   to_key("#f8"));         // + + + + + +
    table_set(*key_map, "\e[19;1~", to_key("#f8"));         //
    table_set(*key_map, "\e[19;2~", to_key("#f8+$"));       // + + +   + +
    table_set(*key_map, "\e[19;3~", to_key("#f8+a"));       // + + +   + +
    table_set(*key_map, "\e[19;4~", to_key("#f8+A"));       // + + +   + +
    table_set(*key_map, "\e[19;5~", to_key("#f8+c"));       // + + +   + +
    table_set(*key_map, "\e[19;6~", to_key("#f8+C"));       // + + +   + +
    table_set(*key_map, "\e[19;7~", to_key("#f8+w"));       // + + +   + +
    table_set(*key_map, "\e[19;8~", to_key("#f8+W"));       // + + +   + +
    table_set(*key_map, "\e[19;9~", to_key("#f8+s"));       //   +
    table_set(*key_map, "\e[19;10~",to_key("#f8+S"));       //   +
    table_set(*key_map, "\e[19;11~",to_key("#f8+x"));       //   +
    table_set(*key_map, "\e[19;12~",to_key("#f8+X"));       //   +
    table_set(*key_map, "\e[19;13~",to_key("#f8+y"));       //   +
    table_set(*key_map, "\e[19;14~",to_key("#f8+Y"));       //   +
    table_set(*key_map, "\e[19;15~",to_key("#f8+z"));       //   +
    table_set(*key_map, "\e[19;16~",to_key("#f8+Z"));       //   +

    // F9                                                   // g i k l w x
    table_set(*key_map, "\e[20~",   to_key("#f9"));         // + + + + + +
    table_set(*key_map, "\e[20;1~", to_key("#f9"));         //
    table_set(*key_map, "\e[20;2~", to_key("#f9+$"));       // + + +   + +
    table_set(*key_map, "\e[20;3~", to_key("#f9+a"));       // + + +   + +
    table_set(*key_map, "\e[20;4~", to_key("#f9+A"));       // + + +   + +
    table_set(*key_map, "\e[20;5~", to_key("#f9+c"));       // + + +   + +
    table_set(*key_map, "\e[20;6~", to_key("#f9+C"));       // + + +   + +
    table_set(*key_map, "\e[20;7~", to_key("#f9+w"));       // + + +   + +
    table_set(*key_map, "\e[20;8~", to_key("#f9+W"));       // + + +   + +
    table_set(*key_map, "\e[20;9~", to_key("#f9+s"));       //   +
    table_set(*key_map, "\e[20;10~",to_key("#f9+S"));       //   +
    table_set(*key_map, "\e[20;11~",to_key("#f9+x"));       //   +
    table_set(*key_map, "\e[20;12~",to_key("#f9+X"));       //   +
    table_set(*key_map, "\e[20;13~",to_key("#f9+y"));       //   +
    table_set(*key_map, "\e[20;14~",to_key("#f9+Y"));       //   +
    table_set(*key_map, "\e[20;15~",to_key("#f9+z"));       //   +
    table_set(*key_map, "\e[20;16~",to_key("#f9+Z"));       //   +

    // F10                                                  // g i k l w x
    table_set(*key_map, "\e[21~",   to_key("#f10"));        // + + + + + +
    table_set(*key_map, "\e[21;1~", to_key("#f10"));        //
    table_set(*key_map, "\e[21;2~", to_key("#f10+$"));      // + + +   + +
    table_set(*key_map, "\e[21;3~", to_key("#f10+a"));      // + + +   + +
    table_set(*key_map, "\e[21;4~", to_key("#f10+A"));      // + + +   + +
    table_set(*key_map, "\e[21;5~", to_key("#f10+c"));      // + + +   + +
    table_set(*key_map, "\e[21;6~", to_key("#f10+C"));      // + + +   + +
    table_set(*key_map, "\e[21;7~", to_key("#f10+w"));      // + + +   + +
    table_set(*key_map, "\e[21;8~", to_key("#f10+W"));      // + + +   + +
    table_set(*key_map, "\e[21;9~", to_key("#f10+s"));      //   +
    table_set(*key_map, "\e[21;10~",to_key("#f10+S"));      //   +
    table_set(*key_map, "\e[21;11~",to_key("#f10+x"));      //   +
    table_set(*key_map, "\e[21;12~",to_key("#f10+X"));      //   +
    table_set(*key_map, "\e[21;13~",to_key("#f10+y"));      //   +
    table_set(*key_map, "\e[21;14~",to_key("#f10+Y"));      //   +
    table_set(*key_map, "\e[21;15~",to_key("#f10+z"));      //   +
    table_set(*key_map, "\e[21;16~",to_key("#f10+Z"));      //   +

    // F11                                                  // g i k l w x
    table_set(*key_map, "\e[23~",   to_key("#f11"));        // + + + + + +
    table_set(*key_map, "\e[23;1~", to_key("#f11"));        //
    table_set(*key_map, "\e[23;2~", to_key("#f11+$"));      // + + +   + +
    table_set(*key_map, "\e[23;3~", to_key("#f11+a"));      // + + +   + +
    table_set(*key_map, "\e[23;4~", to_key("#f11+A"));      // + + +   + +
    table_set(*key_map, "\e[23;5~", to_key("#f11+c"));      // + + +   + +
    table_set(*key_map, "\e[23;6~", to_key("#f11+C"));      // + + +   + +
    table_set(*key_map, "\e[23;7~", to_key("#f11+w"));      // + + +   + +
    table_set(*key_map, "\e[23;8~", to_key("#f11+W"));      // + + +   + +
    table_set(*key_map, "\e[23;9~", to_key("#f11+s"));      //   +
    table_set(*key_map, "\e[23;10~",to_key("#f11+S"));      //   +
    table_set(*key_map, "\e[23;11~",to_key("#f11+x"));      //   +
    table_set(*key_map, "\e[23;12~",to_key("#f11+X"));      //   +
    table_set(*key_map, "\e[23;13~",to_key("#f11+y"));      //   +
    table_set(*key_map, "\e[23;14~",to_key("#f11+Y"));      //   +
    table_set(*key_map, "\e[23;15~",to_key("#f11+z"));      //   +
    table_set(*key_map, "\e[23;16~",to_key("#f11+Z"));      //   +

    // F12                                                  // g i k l w x
    table_set(*key_map, "\e[24~",   to_key("#f12"));        // + + + + + +
    table_set(*key_map, "\e[24;1~", to_key("#f12"));        //
    table_set(*key_map, "\e[24;2~", to_key("#f12+$"));      // + + +   + +
    table_set(*key_map, "\e[24;3~", to_key("#f12+a"));      // + + +   + +
    table_set(*key_map, "\e[24;4~", to_key("#f12+A"));      // + + +   + +
    table_set(*key_map, "\e[24;5~", to_key("#f12+c"));      // + + +   + +
    table_set(*key_map, "\e[24;6~", to_key("#f12+C"));      // + + +   + +
    table_set(*key_map, "\e[24;7~", to_key("#f12+w"));      // + + +   + +
    table_set(*key_map, "\e[24;8~", to_key("#f12+W"));      // + + +   + +
    table_set(*key_map, "\e[24;9~", to_key("#f12+s"));      //   +
    table_set(*key_map, "\e[24;10~",to_key("#f12+S"));      //   +
    table_set(*key_map, "\e[24;11~",to_key("#f12+x"));      //   +
    table_set(*key_map, "\e[24;12~",to_key("#f12+X"));      //   +
    table_set(*key_map, "\e[24;13~",to_key("#f12+y"));      //   +
    table_set(*key_map, "\e[24;14~",to_key("#f12+Y"));      //   +
    table_set(*key_map, "\e[24;15~",to_key("#f12+z"));      //   +
    table_set(*key_map, "\e[24;16~",to_key("#f12+Z"));      //   +
}
