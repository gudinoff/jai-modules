// Tests for integer saturating arighmetic procedures.

AVOID_INFINITE_FOR_LOOP :: true;

#import "Basic";
#import "Compiler";
#import "Math";
#import "String";
#import "Saturation";

main :: () {
    
    write_strings(
        "#=======================#\n",
        "# Basic tests           #\n"
        );
    
    
    test_op :: ($operation: string, x: $Tx, y: $Ty, result: $Tr, type: Type, saturated: bool, remainder: Tr = 0) -> errors_found: int #expand {

        #insert #run () -> string {
            // Build test call.
            builder: String_Builder;
            call := ifx operation == "div"
                then "t_result, t_remainder, t_saturated := %(cast(Tx)x, cast(Ty)y);"
                else "t_result, t_saturated := %(cast(Tx)x, cast(Ty)y);";
            
            print(*builder, call, operation);

            return builder_to_string(*builder);
        }();
        
        errors := 0;
        log: String_Builder;
        if result != t_result           { errors += 1; print(*log, " > incorrect result value: got % expected %\n", t_result, result); };
        if type != type_of(t_result)    { errors += 1; print(*log, " > incorrect result type: got % expected %\n", type_of(t_result), type); };
        if saturated != t_saturated     { errors += 1; print(*log, " > incorrect saturated flag: got % expected %\n", t_saturated, saturated); };
        #if operation == "div" {
            if remainder != t_remainder { errors += 1; print(*log, " > incorrect remainder value: got % expected %\n", t_remainder, remainder); };
        }

        if errors > 0 {
            #if operation == "div" {
                print("%_%(%, %) = % + %0%0\n", operation, type, x, y, result, remainder, ifx saturated then " : saturated");
            }
            else {
                print("%_%(%, %) = %0%0\n", operation, type, x, y, result, ifx saturated then " : saturated");
            }
            write_builder(*log);
        }
                
        return errors;
    }

    errors := 0;

    // Test signed add.
    errors += test_op("add", cast( s8) S8_MAX,  cast( s8)1,          S8_MAX,     s8, true);
    errors += test_op("add", cast(s16)S16_MAX,  cast( u8)1,         S16_MAX,    s16, true);
    errors += test_op("add", cast(s32)S32_MAX,  cast(s32)1,         S32_MAX,    s32, true);
    errors += test_op("add", cast(s64)S64_MAX,  cast(u32)1,         S64_MAX,    s64, true);

    errors += test_op("add", cast( s8) S8_MAX,  cast( s8) S8_MIN,   -1,          s8, false);
    errors += test_op("add", cast(s16)S16_MAX,  cast(s16)S16_MIN,   -1,         s16, false);
    errors += test_op("add", cast(s32)S32_MAX,  cast(s32)S32_MIN,   -1,         s32, false);
    errors += test_op("add", cast(s64)S64_MAX,  cast(s64)S64_MIN,   -1,         s64, false);

    // Test unsigned add.
    errors += test_op("add", cast( u8) U8_MAX,  cast( u8)1,          U8_MAX,     u8, true);
    errors += test_op("add", cast(u16)U16_MAX,  cast(u16)1,         U16_MAX,    u16, true);
    errors += test_op("add", cast(u32)U32_MAX,  cast(u32)1,         U32_MAX,    u32, true);
    errors += test_op("add", cast(u64)U64_MAX,  cast(u64)1,         U64_MAX,    u64, true);

    errors += test_op("add", cast( u8) U8_MAX,  cast( u8)0,          U8_MAX,     u8, false);
    errors += test_op("add", cast(u16)U16_MAX,  cast(u16)0,         U16_MAX,    u16, false);
    errors += test_op("add", cast(u32)U32_MAX,  cast(u32)0,         U32_MAX,    u32, false);
    errors += test_op("add", cast(u64)U64_MAX,  cast(u64)0,         U64_MAX,    u64, false);

    // Test signed sub.
    errors += test_op("sub", cast( s8) S8_MIN,  cast( s8)1,          S8_MIN,     s8, true);
    errors += test_op("sub", cast(s16)S16_MIN,  cast( u8)1,         S16_MIN,    s16, true);
    errors += test_op("sub", cast(s32)S32_MIN,  cast(s32)1,         S32_MIN,    s32, true);
    errors += test_op("sub", cast(s64)S64_MIN,  cast(u32)1,         S64_MIN,    s64, true);

    errors += test_op("sub", cast( s8)-1,       cast( s8) S8_MAX,    S8_MIN,     s8, false);
    errors += test_op("sub", cast(s16)-1,       cast(s16)S16_MAX,   S16_MIN,    s16, false);
    errors += test_op("sub", cast(s32)-1,       cast(s32)S32_MAX,   S32_MIN,    s32, false);
    errors += test_op("sub", cast(s64)-1,       cast(s64)S64_MAX,   S64_MIN,    s64, false);

    // Test unsigned sub.
    errors += test_op("sub", cast( u8)1,        cast( u8) U8_MAX,   0,           u8, true);
    errors += test_op("sub", cast( u8)1,        cast(u16)U16_MAX,   0,          u16, true);
    errors += test_op("sub", cast(u32)1,        cast(u32)U32_MAX,   0,          u32, true);
    errors += test_op("sub", cast(u32)1,        cast(u64)U64_MAX,   0,          u64, true);

    errors += test_op("sub", cast( u8) U8_MAX,  cast( u8)0,          U8_MAX,     u8, false);
    errors += test_op("sub", cast(u16)U16_MAX,  cast( u8)0,         U16_MAX,    u16, false);
    errors += test_op("sub", cast(u32)U32_MAX,  cast(u32)0,         U32_MAX,    u32, false);
    errors += test_op("sub", cast(u64)U64_MAX,  cast(u32)0,         U64_MAX,    u64, false);

    // Test signed mul.
    errors += test_op("mul", cast( s8) S8_MIN,  cast( s8)-1,         S8_MAX,     s8, true);
    errors += test_op("mul", cast(s16)S16_MIN,  cast( s8)-1,        S16_MAX,    s16, true);
    errors += test_op("mul", cast(s32)S32_MIN,  cast(s32)-1,        S32_MAX,    s32, true);
    errors += test_op("mul", cast(s64)S64_MIN,  cast(s32)-1,        S64_MAX,    s64, true);

    errors += test_op("mul", cast( s8) S8_MAX,  cast( s8)-2,         S8_MIN,     s8, true);
    errors += test_op("mul", cast(s16)S16_MAX,  cast( s8)-2,        S16_MIN,    s16, true);
    errors += test_op("mul", cast(s32)S32_MAX,  cast(s32)-2,        S32_MIN,    s32, true);
    errors += test_op("mul", cast(s64)S64_MAX,  cast(s32)-2,        S64_MIN,    s64, true);

    errors += test_op("mul", cast( s8)-2,       cast( s8) S8_MAX,   S8_MIN,     s8, true);
    errors += test_op("mul", cast( s8)-2,       cast(s16)S16_MAX,   S16_MIN,    s16, true);
    errors += test_op("mul", cast(s32)-2,       cast(s32)S32_MAX,   S32_MIN,    s32, true);
    errors += test_op("mul", cast(s32)-2,       cast(s64)S64_MAX,   S64_MIN,    s64, true);

    errors += test_op("mul", cast( s8) S8_MAX,  cast( s8)2,          S8_MAX,     s8, true);
    errors += test_op("mul", cast(s16)S16_MAX,  cast( s8)2,         S16_MAX,    s16, true);
    errors += test_op("mul", cast(s32)S32_MAX,  cast(s32)2,         S32_MAX,    s32, true);
    errors += test_op("mul", cast(s64)S64_MAX,  cast(s32)2,         S64_MAX,    s64, true);

    errors += test_op("mul", cast( s8) S8_MAX,  cast( s8)-1,         -S8_MAX,    s8, false);
    errors += test_op("mul", cast(s16)S16_MAX,  cast( s8)-1,        -S16_MAX,   s16, false);
    errors += test_op("mul", cast(s32)S32_MAX,  cast(s32)-1,        -S32_MAX,   s32, false);
    errors += test_op("mul", cast(s64)S64_MAX,  cast(s32)-1,        -S64_MAX,   s64, false);

    errors += test_op("mul", cast( s8) S8_MAX,  cast( s8)0,         0,           s8, false);
    errors += test_op("mul", cast(s16)S16_MAX,  cast( u8)0,         0,          s16, false);
    errors += test_op("mul", cast(s32)S32_MAX,  cast(s32)0,         0,          s32, false);
    errors += test_op("mul", cast(s64)S64_MAX,  cast(u32)0,         0,          s64, false);

    // Test unsigned mul.
    errors += test_op("mul", cast( u8) U8_MAX,  cast( u8)1,          U8_MAX,     u8, false);
    errors += test_op("mul", cast(u16)U16_MAX,  cast( u8)1,         U16_MAX,    u16, false);
    errors += test_op("mul", cast(u32)U32_MAX,  cast(u32)1,         U32_MAX,    u32, false);
    errors += test_op("mul", cast(u64)U64_MAX,  cast(u32)1,         U64_MAX,    u64, false);

    errors += test_op("mul", cast( u8) U8_MAX,  cast( u8)2,          U8_MAX,     u8, true);
    errors += test_op("mul", cast(u16)U16_MAX,  cast( u8)2,         U16_MAX,    u16, true);
    errors += test_op("mul", cast(u32)U32_MAX,  cast(u32)2,         U32_MAX,    u32, true);
    errors += test_op("mul", cast(u64)U64_MAX,  cast(u32)2,         U64_MAX,    u64, true);

    // Test signed div.
    errors += test_op("div", cast( s8) S8_MIN,  cast( s8)-1,         S8_MAX,     s8, true,  -1);
    errors += test_op("div", cast(s16)S16_MIN,  cast( s8)-1,        S16_MAX,    s16, true,  -1);
    errors += test_op("div", cast(s32)S32_MIN,  cast(s32)-1,        S32_MAX,    s32, true,  -1);
    errors += test_op("div", cast(s64)S64_MIN,  cast(s32)-1,        S64_MAX,    s64, true,  -1);

    errors += test_op("div", cast( s8) S8_MAX,  cast( s8)-2,        - S8_MAX/2,  s8, false, 1);
    errors += test_op("div", cast(s16)S16_MAX,  cast( s8)-2,        -S16_MAX/2, s16, false, 1);
    errors += test_op("div", cast(s32)S32_MAX,  cast(s32)-2,        -S32_MAX/2, s32, false, 1);
    errors += test_op("div", cast(s64)S64_MAX,  cast(s32)-2,        -S64_MAX/2, s64, false, 1);

    errors += test_op("div", cast( s8)15,       cast( s8)5,         3,          s8, false,  0);
    errors += test_op("div", cast( u8)15,       cast(s16)7,         2,          s16, false, 1);
    errors += test_op("div", cast(s16)15,       cast(s32)13,        1,          s32, false, 2);
    errors += test_op("div", cast(u16)100,      cast(s64)3,         33,         s64, false, 1);

    // Test unsigned div.
    errors += test_op("div", cast( u8) U8_MAX,  cast( u8)2,          U8_MAX/2,   u8, false, 1);
    errors += test_op("div", cast(u16)U16_MAX,  cast( u8)2,         U16_MAX/2,  u16, false, 1);
    errors += test_op("div", cast(u32)U32_MAX,  cast(u32)2,         U32_MAX/2,  u32, false, 1);
    errors += test_op("div", cast(u64)U64_MAX,  cast(u32)2,         U64_MAX/2,  u64, false, 1);

    if errors > 0 print("# Found % %!\n", errors, ifx errors == 1 then "error" else "errors"); else print("  No errors found.\n");


    // Test generic agains branch-free alternative.
    write_strings(
        "#=======================#\n",
        "# generic == x64 asm ?  #\n"
        );


    full_test :: ($type: Type, test: (a: type, b: type)) {
        #if type == {
            case u8;
                min :u8 = 0;
                max :u8 = U8_MAX;
                
            case u16;
                min :u16 = 0;
                max :u16 = U16_MAX;

            case s8;
                min :s8 = S8_MIN;
                max :s8 = S8_MAX;
            
            case s16;
                min :s16 = S16_MIN;
                max :s16 = S16_MAX;

            case;
                assert(false, "This will take way too long.");
        }

        #if !AVOID_INFINITE_FOR_LOOP {
            for a : min..max {
                for b : min..max {
                    test(a, b);
                }
            }
        }
        else {
            a :type = min;
            b :type = min;
            while loop_a := true {
                while loop_b := true {
                    test(a, b);
                    if b == max then break loop_b; else b += 1;
                }
                if a == max then break loop_a; else a += 1;
            }
        }
    }

    partial_test :: ($type: Type, test: (a: type, b: type)) {
        min, max: type;
        #if type == {
            case u8;
                min = 0;
                max = U8_MAX;
            
            case u16;
                min = 0;
                max = U16_MAX;

            case u32;
                min = 0;
                max = U32_MAX;
            
            case s8;
                min = S8_MIN;
                max = S8_MAX;
            
            case s16;
                min = S16_MIN;
                max = S16_MAX;

            case s32;
                min = S32_MIN;
                max = S32_MAX;
            
            case;
                assert(false, "This will take way too long.");
        }
    
        #if !AVOID_INFINITE_FOR_LOOP {
            for a: min..max {
                b := a;
                c := max - a + min;
                test(a, b);
                test(a, c);
            }
        }
        else {
            a := min;
            while loop := true {
                b := a;
                c := max - a + min;
                test(a, b);
                test(a, c);
                if a == max then break loop; else a += 1;
            }
        }
    }

    minimal_test :: ($type: Type, test: (a: type, b: type)) {
        #if type == {
            case u32;
                min     :u32 = 0;
                mid     :u32 = U32_MAX / 2;
                max     :u32 = U32_MAX;
                range   :u32 = cast(u32)U16_MAX * 2048;
            
            case u64;
                min     :u64 = 0;
                mid     :u64 = U64_MAX / 2;
                max     :u64 = U64_MAX;
                range   :u64 = cast(u64)U16_MAX * 2048;

            case s32;
                min     :s32 = S32_MIN;
                mid     :s32 = (S32_MIN / 2) + (S32_MAX / 2);
                max     :s32 = S32_MAX;
                range   :s32 = cast(s32)S16_MAX * 2048;

            case s64;
                min     :s64 = S64_MIN;
                mid     :s64 = (S64_MIN / 2) + (S64_MAX / 2);
                max     :s64 = S64_MAX;
                range   :s64 = cast(s64)S16_MAX  * 2048;
            
            case;
                assert(false, "Invalid type % given.", type);
        }

        #if !AVOID_INFINITE_FOR_LOOP {
            start, end : type;
            
            start   = min;
            end     = min+range;
            for a: start..end {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
            }

            start   = mid-range;
            end     = mid+range;
            for a: start..end {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
            }
            
            start   = max-range;
            end     = max;
            for a: start..end {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
            }
        }
        else {
            start, end, a : type;
            
            start   = min;
            end     = min + range;
            a       = start;
            while loop := true {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
                if a == end then break loop; else a += 1;
            }

            start   = mid - range;
            end     = mid + range;
            a       = start;
            while loop := true {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
                if a == end then break loop; else a += 1;
            }

            start   = max - range;
            end     = max;
            a       = start;
            while loop := true {
                b := a;
                c := end - a + start;
                test(a, b);
                test(a, c);
                if a == end then break loop; else a += 1;
            }
        }
    }

    
    // add

    ADD_TEST_TEMPLATE :: (a: $T, b: T) {
        rT, sT := add(a, b, true);
        rF, sF := add(a, b, false);
        assert(rT == rF && sT == sF, "> add(%1, %2, true) = %3,%4   !=   add(%1, %2, false) = %5,%6\n", a, b, rT, sT, rF, sF);
    }

    write_string("# testing add,u8        #\n");
    full_test(u8, ADD_TEST_TEMPLATE);

    write_string("# testing add,u16       #\n");
    full_test(u16, ADD_TEST_TEMPLATE);

    write_string("# testing add,u32       #\n");
    partial_test(u32, ADD_TEST_TEMPLATE);

    write_string("# testing add,u64       #\n");
    minimal_test(u64, ADD_TEST_TEMPLATE);

    write_string("# testing add,s8        #\n");
    full_test(s8, ADD_TEST_TEMPLATE);

    write_string("# testing add,s16       #\n");
    full_test(s16, ADD_TEST_TEMPLATE);

    write_string("# testing add,s32       #\n");
    partial_test(s32, ADD_TEST_TEMPLATE);

    write_string("# testing add,s64       #\n");
    minimal_test(s64, ADD_TEST_TEMPLATE);

    
    // sub

    SUB_TEST_TEMPLATE :: (a: $T, b: T) {
        rT, sT := sub(a, b, true);
        rF, sF := sub(a, b, false);
        assert(rT == rF && sT == sF, "> sub(%1, %2, true) = %3,%4   !=   sub(%1, %2, false) = %5,%6\n", a, b, rT, sT, rF, sF);
    }

    write_string("# testing sub,u8        #\n");
    full_test(u8, SUB_TEST_TEMPLATE);

    write_string("# testing sub,u16       #\n");
    full_test(u16, SUB_TEST_TEMPLATE);

    write_string("# testing sub,u32       #\n");
    partial_test(u32, SUB_TEST_TEMPLATE);

    write_string("# testing sub,u64       #\n");
    minimal_test(u64, SUB_TEST_TEMPLATE);

    write_string("# testing sub,s8        #\n");
    full_test(s8, SUB_TEST_TEMPLATE);

    write_string("# testing sub,s16       #\n");
    full_test(s16, SUB_TEST_TEMPLATE);

    write_string("# testing sub,s32       #\n");
    partial_test(s32, SUB_TEST_TEMPLATE);

    write_string("# testing sub,s64       #\n");
    minimal_test(s64, SUB_TEST_TEMPLATE);


    // mul

    MUL_TEST_TEMPLATE :: (a: $T, b: T) {
        rT, sT := mul(a, b, true);
        rF, sF := mul(a, b, false);
        assert(rT == rF && sT == sF, "> mul(%1, %2, true) = %3,%4   !=   mul(%1, %2, false) = %5,%6\n", a, b, rT, sT, rF, sF);
    }
    
    write_string("# testing mul,u8        #\n");
    full_test(u8, MUL_TEST_TEMPLATE);

    write_string("# testing mul,u16       #\n");
    full_test(u16, MUL_TEST_TEMPLATE);

    write_string("# testing mul,u32       #\n");
    partial_test(u32, MUL_TEST_TEMPLATE);

    write_string("# testing mul,u64       #\n");
    minimal_test(u64, MUL_TEST_TEMPLATE);

    write_string("# testing mul,s8        #\n");
    full_test(s8, MUL_TEST_TEMPLATE);

    write_string("# testing mul,s16       #\n");
    full_test(s16, MUL_TEST_TEMPLATE);

    write_string("# testing mul,s32       #\n");
    partial_test(s32, MUL_TEST_TEMPLATE);

    write_string("# testing mul,s64       #\n");
    minimal_test(s64, MUL_TEST_TEMPLATE);


    // div

    DIV_TEST_TEMPLATE :: (a: $T, b: T) {
        if b == 0 then return;
        rT, remT, sT := div(a, b, true);
        rF, remF, sF := div(a, b, false);
        assert(rT == rF && sT == sF, "> mul(%1, %2, true) = %3,%4,%5   !=   mul(%1, %2, false) = %6,%7,%8\n", a, b, rT, remT, sT, rF, remF, sF);
    }

    write_string("# testing div,u8        #\n");
    full_test(u8, DIV_TEST_TEMPLATE);

    write_string("# testing div,u16       #\n");
    full_test(u16, DIV_TEST_TEMPLATE);

    write_string("# testing div,u32       #\n");
    partial_test(u32, DIV_TEST_TEMPLATE);

    write_string("# testing div,u64       #\n");
    minimal_test(u64, DIV_TEST_TEMPLATE);

    write_string("# testing div,s8        #\n");
    full_test(s8, DIV_TEST_TEMPLATE);

    write_string("# testing div,s16       #\n");
    full_test(s16, DIV_TEST_TEMPLATE);

    write_string("# testing div,s32       #\n");
    partial_test(s32, DIV_TEST_TEMPLATE);

    write_string("# testing div,s64       #\n");
    minimal_test(s64, DIV_TEST_TEMPLATE);

    
    write_string("  No errors found.\n");
    

    write_strings(
        "#=======================#\n",
        "# Benchmarks            #\n"
        );
        
    #import "Random";
    
    performance_test :: ($operation: string, $type: Type, print_result: bool = true) -> ops_per_us_gen: float, ops_per_us_asm: float {
        
        #if type == u8  { MIN :: 0; MAX :: U8_MAX; }
        #if type == u16 { MIN :: 0; MAX :: U16_MAX; }
        #if type == u32 { MIN :: 0; MAX :: U32_MAX; }
        #if type == u64 { MIN :: 0; MAX :: U64_MAX; }
        #if type == s8  { MIN :: S8_MIN; MAX :: S8_MAX; }
        #if type == s16 { MIN :: S16_MIN; MAX :: S16_MAX; }
        #if type == s32 { MIN :: S32_MIN; MAX :: S32_MAX; }
        #if type == s64 { MIN :: S64_MIN; MAX :: S64_MAX; }
        
        NUM_TESTS :: 50000;
        DATA_SIZE_BITS :: 64*1024*8;
        #if type == s8 || type == u8 then
            DATA_SIZE :: DATA_SIZE_BITS/8;
        else #if type == s16 || type == u16 then
            DATA_SIZE :: DATA_SIZE_BITS/16;
        else #if type == s32 || type == u32 then
            DATA_SIZE :: DATA_SIZE_BITS/32;
        else #if type == s64 || type == u64 then
            DATA_SIZE :: DATA_SIZE_BITS/64;
        
        best_gen := 0.0;
        best_asm := 0.0;
        numbers_x: [..] type;
        numbers_y: [..] type;
        array_reserve(*numbers_x, DATA_SIZE);
        array_reserve(*numbers_y, DATA_SIZE);

        // Comment the line bellow to use the same "random" values.
        random_seed(cast(u64)to_nanoseconds(current_time_monotonic()));

        for 0..DATA_SIZE-1 {
            x := cast(type) random_get_within_range(xx MIN, xx MAX);
            y := cast(type) random_get_within_range(xx MIN, xx MAX);
            if y == 0 && operation == "div" {
                y = 1;
            }
            array_add(*numbers_x, x);
            array_add(*numbers_y, y);
        }

        for 0..NUM_TESTS-1 {
            
            r_gen: type = 0;
            r_asm: type = 0;
            
            time_gen := current_time_monotonic();
            for idx: 0..DATA_SIZE-1 #insert #run replace("r_gen ^= OP(numbers_x[idx], numbers_y[idx], false);", "OP", operation);
            time_gen = current_time_monotonic() - time_gen;
            
            time_asm := current_time_monotonic();
            for idx: 0..DATA_SIZE-1 #insert #run replace("r_asm ^= OP(numbers_x[idx], numbers_y[idx], true);", "OP", operation);
            time_asm = current_time_monotonic() - time_asm;

            assert(r_gen == r_asm);
            
            perf_gen    := cast(float)DATA_SIZE/cast(float)to_nanoseconds(time_gen);
            perf_asm    := cast(float)DATA_SIZE/cast(float)to_nanoseconds(time_asm);
            best_gen    = max(best_gen, perf_gen);
            best_asm    = max(best_asm, perf_asm);
        }

        tmp_context := context;
        push_context tmp_context {
            ff := *context.print_style.default_format_float;
            ff.zero_removal = .NO;
            ff.width = 7;
            ff.trailing_width = 2;

            fi := *context.print_style.default_format_int;
            fi.minimum_digits = 3;
            
            if print_result {
                if type == s8 || type == u8 write_string(" ");
                print("% | % | % | %\n", type, best_gen, best_asm, cast(int)(100*best_asm/best_gen));
            }
        }
        return best_gen, best_asm;
    }

    write_strings(
        "    |    (ops / nsec)   |\n",
        " T  | generic | x64 asm |  %\n"
    );

    write_strings(
        "--- | ----------------- | ---\n",
        "    |        add        |\n"
        );
    performance_test("add", u8);
    performance_test("add", u16);
    performance_test("add", u32);
    performance_test("add", u64);
    performance_test("add", s8);
    performance_test("add", s16);
    performance_test("add", s32);
    performance_test("add", s64);

    write_strings(
        "--- | ----------------- | ---\n",
        "    |        sub        |\n"
        );
    performance_test("sub", u8);
    performance_test("sub", u16);
    performance_test("sub", u32);
    performance_test("sub", u64);
    performance_test("sub", s8);
    performance_test("sub", s16);
    performance_test("sub", s32);
    performance_test("sub", s64);

    write_strings(
        "--- | ----------------- | ---\n",
        "    |        mul        |\n"
        );
    performance_test("mul", u8);
    performance_test("mul", u16);
    performance_test("mul", u32);
    performance_test("mul", u64);
    performance_test("mul", s8);
    performance_test("mul", s16);
    performance_test("mul", s32);
    performance_test("mul", s64);

    write_strings(
        "--- | ----------------- | ---\n",
        "    |        div        |\n"
        );
    performance_test("div", u8);
    performance_test("div", u16);
    performance_test("div", u32);
    performance_test("div", u64);
    performance_test("div", s8);
    performance_test("div", s16);
    performance_test("div", s32);
    performance_test("div", s64);
}
