jai-modules
===========

Modules for the language being developed by Thekla, Inc.

Available at https://github.com/gudinoff/jai-modules

# Saturation

This module provides basic integer [saturation arithmetic](https://en.wikipedia.org/wiki/Saturation_arithmetic) procedures: `add`, `sub`, `mul`, and `div`.  
These procedures accept any of the built-in integer types and adjust the output accordingly, e.g., adding an `u8` with an `s16` results in an `s16`;  
All procedures return a flag signaling if the result is saturated and, additionally, the division procedure returns the remainder;  
Branch-free procedures are included for the x64 architecture. These may be used by setting the `PREFER_BRANCH_FREE_CODE` module argument, or by setting `prefer_branch_free_code` on each function call. These should speed things up, specially when using signed values. Some benchmarks are included on the tests file.  

# TUI

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

# UTF8

Basic operations over UTF8 encoded strings.

# License

Licensed under MIT or ISC.

SPDX-License-Identifier: MIT OR ISC
