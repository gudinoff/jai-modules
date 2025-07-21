// Integer saturating arighmetic (with assembly branch-free procedures for x64 - expecting signed values in two's complement).

#module_parameters(PREFER_BRANCH_FREE_CODE := false);

#import "Basic";
#import "Math";
#import "String";


INTEGER_ARITHMETIC_TYPES_CHECK :: #string DONE
    type_info_x := cast(*Type_Info)Tx;
    type_info_y := cast(*Type_Info)Ty;
    if type_info_x.type != .INTEGER || type_info_y.type != .INTEGER return false, "Non integers values passed.";
    tx := cast(*Type_Info_Integer)type_info_x;
    ty := cast(*Type_Info_Integer)type_info_y;

    largest_type :=
        ifx tx.runtime_size > ty.runtime_size then Tx else
        ifx ty.runtime_size > tx.runtime_size then Ty else
        ifx tx.signed == ty.signed then Tx else
        void;

    // Only allow to add different signedness values if largest type is the signed one (as in JAI).
    if tx.signed == ty.signed {
        Tx = largest_type;
        Ty = largest_type;
        Tr = largest_type;
    }
    else if tx.signed && Tx == largest_type {
        Ty = largest_type;
        Tr = largest_type;
    }
    else if ty.signed && Ty == largest_type {
        Tx = largest_type;
        Tr = largest_type;
    }
    else return false, "Number signedness mismatch.";

    return true;
DONE

add :: (x: $Tx, y: $Ty, $prefer_branch_free_code := PREFER_BRANCH_FREE_CODE) -> result: $Tr, saturated: bool #modify { #insert INTEGER_ARITHMETIC_TYPES_CHECK; }
{

    #if !(prefer_branch_free_code && CPU == .X64) {
    
        #if Tr == s8 || Tr == s16 || Tr == s32 || Tr == s64 {
            
            #if Tr ==  s8 { MAX ::  S8_MAX; MIN ::  S8_MIN; }
            #if Tr == s16 { MAX :: S16_MAX; MIN :: S16_MIN; }
            #if Tr == s32 { MAX :: S32_MAX; MIN :: S32_MIN; }
            #if Tr == s64 { MAX :: S64_MAX; MIN :: S64_MIN; }
            
            if (y > 0 && x > MAX - y) then return MAX, true;
            if (y < 0 && x < MIN - y) then return MIN, true;
            
        } else {
            
            #if Tr ==  u8 { MAX ::  U8_MAX; }
            #if Tr == u16 { MAX :: U16_MAX; }
            #if Tr == u32 { MAX :: U32_MAX; }
            #if Tr == u64 { MAX :: U64_MAX; }
            
            if (x > MAX - y) then return MAX, true;
            
        }
        
        return x + y, false;
        
    } else {
    
        result: Tr = ---;
        saturated: bool = ---;
        
        
        ADD_SIGNED_ASM :: #string DONE
        #asm {        
            mov         result, -1;             // Pre-set result with signed maximum (set all bits...
            shr.SIZE    result, 1;              // ...then, clear MSB).
            bt          x, SIGN_BIT;            // Test sign bit (affect CF).
            adc         result, 0;              // Overflow signed maximum to signed minimum if CF is set.
            
            add.SIZE    x, y;                   // Add values (affect OF).
            seto        saturated;              // Set saturated flag if OF.
            cmovno      result, x;              // Move add-result to result if NOT OF.
        }
        DONE
        
        #if Tr == s8
            #insert #run replace(replace(ADD_SIGNED_ASM, ".SIZE", ".b"), "SIGN_BIT", "7");
        #if Tr == s16
            #insert #run replace(replace(ADD_SIGNED_ASM, ".SIZE", ".w"), "SIGN_BIT", "15");
        #if Tr == s32
            #insert #run replace(replace(ADD_SIGNED_ASM, ".SIZE", ".d"), "SIGN_BIT", "31");
        #if Tr == s64
            #insert #run replace(replace(ADD_SIGNED_ASM, ".SIZE", ".q"), "SIGN_BIT", "63");
        
        
        ADD_UNSIGNED_ASM :: #string DONE
        #asm {
            mov         result, -1;             // Pre-set result with unsigned maximum.
            add.SIZE    x, y;                   // Add values (affect CF).
            setc        saturated;              // Set saturated flag if CF.
            cmovnc      result, x;              // Move add-result to result if NOT CF.
        }
        DONE
        
        #if Tr == u8
            #insert #run replace(ADD_UNSIGNED_ASM, ".SIZE", ".b");
        #if Tr == u16
            #insert #run replace(ADD_UNSIGNED_ASM, ".SIZE", ".w");
        #if Tr == u32
            #insert #run replace(ADD_UNSIGNED_ASM, ".SIZE", ".d");
        #if Tr == u64
            #insert #run replace(ADD_UNSIGNED_ASM, ".SIZE", ".q");
        
        
        return result, saturated;
        
    }
}

sub :: (x: $Tx, y: $Ty, $prefer_branch_free_code := PREFER_BRANCH_FREE_CODE) -> result: $Tr, saturated: bool #modify { #insert INTEGER_ARITHMETIC_TYPES_CHECK; }
{
    
    #if !(prefer_branch_free_code && CPU == .X64) {
        
        #if Tr == s8 || Tr == s16 || Tr == s32 || Tr == s64 {
            
            #if Tr ==  s8 { MAX ::  S8_MAX; MIN ::  S8_MIN; }
            #if Tr == s16 { MAX :: S16_MAX; MIN :: S16_MIN; }
            #if Tr == s32 { MAX :: S32_MAX; MIN :: S32_MIN; }
            #if Tr == s64 { MAX :: S64_MAX; MIN :: S64_MIN; }
            
            if (y < 0 && x > MAX + y) then return MAX, true;
            if (y > 0 && x < MIN + y) then return MIN, true;
            
        } else {
            
            if (y > x) then return 0, true;
            
        }
        
        return x - y, false;
        
    } else {
        
        result: Tr = ---;
        saturated: bool = ---;
        
        
        SUB_SIGNED_ASM :: #string DONE
        #asm {
            mov         result, -1;             // Pre-set result with signed maximum (set all bits...
            shr.SIZE    result, 1;              // ...then, clear MSB).
            bt          x, SIGN_BIT;            // Test signal bit (affect CF).
            adc         result, 0;              // Overflow signed maximum to signed minimum if CF is set.
            
            sub.SIZE    x, y;                   // Subtract values (affect OF).
            seto        saturated;              // Set saturated flag if OF.
            cmovno      result, x;              // Move subtract-result to result if NOT OF.
        }
        DONE

        #if Tr == s8
            #insert #run replace(replace(SUB_SIGNED_ASM, ".SIZE", ".b"), "SIGN_BIT", "7");
        #if Tr == s16
            #insert #run replace(replace(SUB_SIGNED_ASM, ".SIZE", ".w"), "SIGN_BIT", "15");
        #if Tr == s32
            #insert #run replace(replace(SUB_SIGNED_ASM, ".SIZE", ".d"), "SIGN_BIT", "31");
        #if Tr == s64
            #insert #run replace(replace(SUB_SIGNED_ASM, ".SIZE", ".q"), "SIGN_BIT", "63");


        SUB_UNSIGNED_ASM :: #string DONE
        #asm {
            xor         result, result;         // Pre-set result with usigned minimum (zero).
            sub.SIZE    x, y;                   // Subtract values (affect CF).
            setc        saturated;              // Set saturated flag if CF.
            cmovnc      result, x;              // Move subtract-result to result if NOT CF.
        }
        DONE

        #if Tr == u8
            #insert #run replace(SUB_UNSIGNED_ASM, ".SIZE", ".b");
        #if Tr == u16
            #insert #run replace(SUB_UNSIGNED_ASM, ".SIZE", ".w");
        #if Tr == u32
            #insert #run replace(SUB_UNSIGNED_ASM, ".SIZE", ".d");
        #if Tr == u64
            #insert #run replace(SUB_UNSIGNED_ASM, ".SIZE", ".q");


        return result, saturated;

    }

}

mul :: (x: $Tx, y: $Ty, $prefer_branch_free_code := PREFER_BRANCH_FREE_CODE) -> result: $Tr, saturated: bool #modify { #insert INTEGER_ARITHMETIC_TYPES_CHECK; }
{
    
    #if !(prefer_branch_free_code && CPU == .X64) {
        
        #if Tr == s8 || Tr == s16 || Tr == s32 || Tr == s64 {
            
            #if Tr ==  s8 { MAX ::  S8_MAX; MIN ::  S8_MIN; }
            #if Tr == s16 { MAX :: S16_MAX; MIN :: S16_MIN; }
            #if Tr == s32 { MAX :: S32_MAX; MIN :: S32_MIN; }
            #if Tr == s64 { MAX :: S64_MAX; MIN :: S64_MIN; }
            
            if x == 0 || y == 0 then return 0, false;
            if x > 0 && y > 0 && x > MAX / y then return MAX, true;
            if x < 0 && y < 0 && x < MAX / y then return MAX, true;
            if (y < 0 && x > 0 && y < MIN / x) || (x < 0 && y > 0 && x < MIN / y) then return MIN, true;
            
        } else {
            
            #if Tr ==  u8 { MAX ::  U8_MAX; }
            #if Tr == u16 { MAX :: U16_MAX; }
            #if Tr == u32 { MAX :: U32_MAX; }
            #if Tr == u64 { MAX :: U64_MAX; }
            
            if x == 0 || y == 0 then return 0, false;
            if x > MAX / y then return MAX, true;
            
        }
        
        return x * y, false;
        
    } else {
        
        result: Tr = ---;
        saturated: bool = ---;
        
        MUL_SIGNED_ASM :: #string DONE
        #asm {
            // Using two copies of the x value (x_, sign) seems to be a bit faster (not sure why).
            mov         x_: gpr === a, x;       // Pin copy of x value to register A.
            
            mov         result, -1;             // Pre-set result with signed maximum (set all bits...
            shr.SIZE    result, 1;              // ...then, clear MSB).
            mov         sign:, x;               // Use copy of x value.
            xor         sign, y;                // Calculate result signal bit using xor.
            bt          sign, SIGN_BIT;         // Test signal bit (affect CF).
            adc         result, 0;              // Overflow signed maximum to signed minimum if CF is set.
            
            imul.SIZE   x_, y;                  // Multiply values (affect OF).
            seto        saturated;              // Set saturated flag if OF.
            cmovno      result, x_;             // Move multiply-result to result if NOT OF.
        }
        DONE

        #if Tr == s8
            #insert #run replace(replace(MUL_SIGNED_ASM, ".SIZE", ".b"), "SIGN_BIT", "7");
        #if Tr == s16
            #insert #run replace(replace(MUL_SIGNED_ASM, ".SIZE", ".w"), "SIGN_BIT", "15");
        #if Tr == s32
            #insert #run replace(replace(MUL_SIGNED_ASM, ".SIZE", ".d"), "SIGN_BIT", "31");
        #if Tr == s64
            #insert #run replace(replace(MUL_SIGNED_ASM, ".SIZE", ".q"), "SIGN_BIT", "63");


        MUL_UNSIGNED_ASM :: #string DONE
        #asm {
            result === a;                       // Pin result to register A.
            
            mov         result, x;              // Move value x to result.
            mul.SIZE    reg_d:, result, y;      // Multiply values (affect CF).
            setc        saturated;              // Set saturated flag if CF.
            sbb         mask:, mask;            // If CF: mask = -1 (all bits set); else: mask = 0.
            or          result, mask;           // If CF was set, then result will be set to unsigned maximum (all bits set).
        }
        DONE
        
        #if Tr == u8
            #insert #run replace(replace(MUL_UNSIGNED_ASM, ".SIZE", ".b"), "reg_d:,", ""); // For 8bits mul, we do not need D register.
        #if Tr == u16
            #insert #run replace(MUL_UNSIGNED_ASM, ".SIZE", ".w");
        #if Tr == u32
            #insert #run replace(MUL_UNSIGNED_ASM, ".SIZE", ".d");
        #if Tr == u64
            #insert #run replace(MUL_UNSIGNED_ASM, ".SIZE", ".q");
        
        
        return result, saturated;
        
    }
}

div :: (x: $Tx, y: $Ty, $prefer_branch_free_code := PREFER_BRANCH_FREE_CODE) -> result: $Tr, remainder: Tr, saturated: bool #modify { #insert INTEGER_ARITHMETIC_TYPES_CHECK; }
{
    
    #if !(prefer_branch_free_code && CPU == .X64) {
        
        #if Tr == s8 || Tr == s16 || Tr == s32 || Tr == s64 {
            
            #if Tr ==  s8 { MAX ::  S8_MAX; MIN ::  S8_MIN; }
            #if Tr == s16 { MAX :: S16_MAX; MIN :: S16_MIN; }
            #if Tr == s32 { MAX :: S32_MAX; MIN :: S32_MIN; }
            #if Tr == s64 { MAX :: S64_MAX; MIN :: S64_MIN; }
            
            if x == MIN && y == -1 then return MAX, -1, true;
            
        }
        
        result := x / y;
        remainder := x - (y * result);
        return result, remainder, false;
        
    } else {
        
        result: Tr = ---;
        remainder: Tr = ---;
        saturated: bool = ---;
        
        DIV_SIGNED_ASM :: #string DONE
        #asm {
            result === a;                       // Pin result to register A (to be used as dividend on idiv).
            remainder === d;                    // Pin remainder to register D.
            
            xor         saturated, saturated;   // Clear saturated.
            
            // Detect div(MIN/-1) and flag it on ZF.
            mov         t_dividend:, -1;        // Pre-set t_dividend with signed minimum (set all bits...
            shr.SIZE    t_dividend, 1;          // ...then, clear MSB...
            not         t_dividend;             // ...then, negate to obtain MSB set and all other bits cleared).
            //
            mov         limit:, t_dividend;     // Keep copy of signed minimum on limit.
            add         limit, 1;               // Set limit as signed minimum + 1.
            //
            xor.SIZE    t_dividend, x;          // Clear dividend if x value is equal to signed minimum.
            //
            mov         t_divisor:, -1;         // Pre-set test_divisor with -1.
            xor.SIZE    t_divisor, y;           // Clear test_divisor if y value is equal to -1.
            //
            or.SIZE     t_dividend, t_divisor;  // Or t_dividend with t_divisor (affect ZF).
            
            setz        saturated;              // Set saturated flag if ZF.
            mov         result, x;              // Copy x value to result (dividend).
            cmovz       result, limit;          // If ZF: copy limit (signed minimum + 1) to result (dividend).
            
            DIVIDE_PLACEHOLDER
            
            sub.SIZE    remainder, saturated;   // If saturated: remainder = 0 - 1; otherwise: remainder = x - 0.
        }
        DONE

        DIV_SIGNED_CALC_8BITS :: #string DONE
            cbw         result;                 // Prepare dividend high bits (sign-extend).
            idiv.SIZE   result, y;              // Divide values.
            mov         remainder, result;      // Extract remainder from result's high bits.
            sar         remainder, 8;           // Shift remainder from high to low bits.
        DONE

        DIV_SIGNED_CALC_16BITS :: #string DONE
            cwd         remainder, result;      // Prepare dividend high bits (sign-extend).
            idiv.SIZE   remainder, result, y;   // Divide values.
        DONE

        DIV_SIGNED_CALC_32BITS :: #string DONE
            cdq         remainder, result;      // Prepare dividend high bits (sign-extend).
            idiv.SIZE   remainder, result, y;   // Divide values.
        DONE

        DIV_SIGNED_CALC_64BITS :: #string DONE
            cqo         remainder, result;      // Prepare dividend high bits (sign-extend).
            idiv.SIZE   remainder, result, y;   // Divide values.
        DONE
        
        #if Tr == s8
            #insert #run replace(replace(DIV_SIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_SIGNED_CALC_8BITS), ".SIZE", ".b");
        #if Tr == s16
            #insert #run replace(replace(DIV_SIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_SIGNED_CALC_16BITS), ".SIZE", ".w");
        #if Tr == s32
            #insert #run replace(replace(DIV_SIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_SIGNED_CALC_32BITS), ".SIZE", ".d");
        #if Tr == s64
            #insert #run replace(replace(DIV_SIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_SIGNED_CALC_64BITS), ".SIZE", ".q");
        
        
        DIV_UNSIGNED_ASM :: #string DONE
        #asm {
            result === a;                       // Pin result to register A.
            remainder === d;                    // Pin remainder to register D.

            xor         result, result;         // Clear result.
            xor         remainder, remainder;   // Clear remainder (required when used as dividend's high bits).
            xor         saturated, saturated;   // Clear saturated (unsigned division never saturates).
            mov.SIZE    result, x;              // Copy x value to result.

            DIVIDE_PLACEHOLDER
        }
        DONE

        DIV_UNSIGNED_CALC_8BITS :: #string DONE
            div.SIZE    result, y;              // Divide values.
            mov         remainder, result;      // Extract remainder from result's high bits.
            sar         remainder, 8;           // Shift remainder from high to low bits.
        DONE
        
        DIV_UNSIGNED_CALC :: #string DONE
            div.SIZE    remainder, result, y;   // Divide values.
        DONE
        
        #if Tr == u8
            #insert #run replace(replace(DIV_UNSIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_UNSIGNED_CALC_8BITS), ".SIZE", ".b");
        #if Tr == u16
            #insert #run replace(replace(DIV_UNSIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_UNSIGNED_CALC), ".SIZE", ".w");
        #if Tr == u32
            #insert #run replace(replace(DIV_UNSIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_UNSIGNED_CALC), ".SIZE", ".d");
        #if Tr == u64
            #insert #run replace(replace(DIV_UNSIGNED_ASM, "DIVIDE_PLACEHOLDER", DIV_UNSIGNED_CALC), ".SIZE", ".q");
        
        
        return result, remainder, saturated;
        
    }
}
