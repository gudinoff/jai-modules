// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
Palette :: enum u8 {
    BLACK           :: 0;
    MAROON          :: 1;
    GREEN           :: 2;
    OLIVE           :: 3;
    NAVY            :: 4;
    PURPLE          :: 5;
    TEAL            :: 6;
    SILVER          :: 7;
    GRAY            :: 8;
    RED             :: 9;
    LIME            :: 10;
    YELLOW          :: 11;
    BLUE            :: 12;
    MAGENTA         :: 13;
    CYAN            :: 14;
    WHITE           :: 15;


    x000000         :: 16;
    x00005F         :: 17;
    x000087         :: 18;
    x0000AF         :: 19;
    x0000D7         :: 20;
    x0000FF         :: 21;

    x005F00         :: 22;
    x005F5F         :: 23;
    x005F87         :: 24;
    x005FAF         :: 25;
    x005FD7         :: 26;
    x005FFF         :: 27;

    x008700         :: 28;
    x00875F         :: 29;
    x008787         :: 30;
    x0087AF         :: 31;
    x0087D7         :: 32;
    x0087FF         :: 33;

    x00AF00         :: 34;
    x00AF5F         :: 35;
    x00AF87         :: 36;
    x00AFAF         :: 37;
    x00AFD7         :: 38;
    x00AFFF         :: 39;

    x00D700         :: 40;
    x00D75F         :: 41;
    x00D787         :: 42;
    x00D7AF         :: 43;
    x00D7D7         :: 44;
    x00D7FF         :: 45;

    x00FF00         :: 46;
    x00FF5F         :: 47;
    x00FF87         :: 48;
    x00FFAF         :: 49;
    x00FFD7         :: 50;
    x00FFFF         :: 51;


    x5F0000         :: 52;
    x5F005F         :: 53;
    x5F0087         :: 54;
    x5F00AF         :: 55;
    x5F00D7         :: 56;
    x5F00FF         :: 57;

    x5F5F00         :: 58;
    x5F5F5F         :: 59;
    x5F5F87         :: 60;
    x5F5FAF         :: 61;
    x5F5FD7         :: 62;
    x5F5FFF         :: 63;

    x5F8700         :: 64;
    x5F875F         :: 65;
    x5F8787         :: 66;
    x5F87AF         :: 67;
    x5F87D7         :: 68;
    x5F87FF         :: 69;

    x5FAF00         :: 70;
    x5FAF5F         :: 71;
    x5FAF87         :: 72;
    x5FAFAF         :: 73;
    x5FAFD7         :: 74;
    x5FAFFF         :: 75;

    x5FD700         :: 76;
    x5FD75F         :: 77;
    x5FD787         :: 78;
    x5FD7AF         :: 79;
    x5FD7D7         :: 80;
    x5FD7FF         :: 81;

    x5FFF00         :: 82;
    x5FFF5F         :: 83;
    x5FFF87         :: 84;
    x5FFFAF         :: 85;
    x5FFFD7         :: 86;
    x5FFFFF         :: 87;


    x870000         :: 88;
    x87005F         :: 89;
    x870087         :: 90;
    x8700AF         :: 91;
    x8700D7         :: 92;
    x8700FF         :: 93;

    x875F00         :: 94;
    x875F5F         :: 95;
    x875F87         :: 96;
    x875FAF         :: 97;
    x875FD7         :: 98;
    x875FFF         :: 99;

    x878700         :: 100;
    x87875F         :: 101;
    x878787         :: 102;
    x8787AF         :: 103;
    x8787D7         :: 104;
    x8787FF         :: 105;

    x87AF00         :: 106;
    x87AF5F         :: 107;
    x87AF87         :: 108;
    x87AFAF         :: 109;
    x87AFD7         :: 110;
    x87AFFF         :: 111;
    
    x87D700         :: 112;
    x87D75F         :: 113;
    x87D787         :: 114;
    x87D7AF         :: 115;
    x87D7D7         :: 116;
    x87D7FF         :: 117;

    x87FF00         :: 118;
    x87FF5F         :: 119;
    x87FF87         :: 120;
    x87FFAF         :: 121;
    x87FFD7         :: 122;
    x87FFFF         :: 123;

    
    xAF0000         :: 124;
    xAF005F         :: 125;
    xAF0087         :: 126;
    xAF00AF         :: 127;
    xAF00D7         :: 128;
    xAF00FF         :: 129;

    xAF5F00         :: 130;
    xAF5F5F         :: 131;
    xAF5F87         :: 132;
    xAF5FAF         :: 133;
    xAF5FD7         :: 134;
    xAF5FFF         :: 135;

    xAF8700         :: 136;
    xAF875F         :: 137;
    xAF8787         :: 138;
    xAF87AF         :: 139;
    xAF87D7         :: 140;
    xAF87FF         :: 141;

    xAFAF00         :: 142;
    xAFAF5F         :: 143;
    xAFAF87         :: 144;
    xAFAFAF         :: 145;
    xAFAFD7         :: 146;
    xAFAFFF         :: 147;
    
    xAFD700         :: 148;
    xAFD75F         :: 149;
    xAFD787         :: 150;
    xAFD7AF         :: 151;
    xAFD7D7         :: 152;
    xAFD7FF         :: 153;

    xAFFF00         :: 154;
    xAFFF5F         :: 155;
    xAFFF87         :: 156;
    xAFFFAF         :: 157;
    xAFFFD7         :: 158;
    xAFFFFF         :: 159;


    xD70000         :: 160;
    xD7005F         :: 161;
    xD70087         :: 162;
    xD700AF         :: 163;
    xD700D7         :: 164;
    xD700FF         :: 165;

    xD75F00         :: 166;
    xD75F5F         :: 167;
    xD75F87         :: 168;
    xD75FAF         :: 169;
    xD75FD7         :: 170;
    xD75FFF         :: 171;

    xD78700         :: 172;
    xD7875F         :: 173;
    xD78787         :: 174;
    xD787AF         :: 175;
    xD787D7         :: 176;
    xD787FF         :: 177;

    xD7AF00         :: 178;
    xD7AF5F         :: 179;
    xD7AF87         :: 180;
    xD7AFAF         :: 181;
    xD7AFD7         :: 182;
    xD7AFFF         :: 183;
    
    xD7D700         :: 184;
    xD7D75F         :: 185;
    xD7D787         :: 186;
    xD7D7AF         :: 187;
    xD7D7D7         :: 188;
    xD7D7FF         :: 189;

    xD7FF00         :: 190;
    xD7FF5F         :: 191;
    xD7FF87         :: 192;
    xD7FFAF         :: 193;
    xD7FFD7         :: 194;
    xD7FFFF         :: 195;


    xFF0000         :: 196;
    xFF005F         :: 197;
    xFF0087         :: 198;
    xFF00AF         :: 199;
    xFF00D7         :: 200;
    xFF00FF         :: 201;

    xFF5F00         :: 202;
    xFF5F5F         :: 203;
    xFF5F87         :: 204;
    xFF5FAF         :: 205;
    xFF5FD7         :: 206;
    xFF5FFF         :: 207;

    xFF8700         :: 208;
    xFF875F         :: 209;
    xFF8787         :: 210;
    xFF87AF         :: 211;
    xFF87D7         :: 212;
    xFF87FF         :: 213;

    xFFAF00         :: 214;
    xFFAF5F         :: 215;
    xFFAF87         :: 216;
    xFFAFAF         :: 217;
    xFFAFD7         :: 218;
    xFFAFFF         :: 219;
    
    xFFD700         :: 220;
    xFFD75F         :: 221;
    xFFD787         :: 222;
    xFFD7AF         :: 223;
    xFFD7D7         :: 224;
    xFFD7FF         :: 225;

    xFFFF00         :: 226;
    xFFFF5F         :: 227;
    xFFFF87         :: 228;
    xFFFFAF         :: 229;
    xFFFFD7         :: 230;
    xFFFFFF         :: 231;


    // Grayscale
    x080808         :: 232;
    x121212         :: 233;
    x1C1C1C         :: 234;
    x262626         :: 235;
    x303030         :: 236;
    x3A3A3A         :: 237;

    x444444         :: 238;
    x4E4E4E         :: 239;
    x585858         :: 240;
    x636363         :: 241;
    x6C6C6C         :: 242;
    x767676         :: 243;

    x808080         :: 244;
    x8A8A8A         :: 245;
    x949494         :: 246;
    x9E9E9E         :: 247;
    xA8A8A8         :: 248;
    xB2B2B2         :: 249;

    xBCBCBC         :: 250;
    xC6C6C6         :: 251;
    xD0D0D0         :: 252;
    xDADADA         :: 253;
    xE4E4E4         :: 254;
    xEEEEEE         :: 255;
}
