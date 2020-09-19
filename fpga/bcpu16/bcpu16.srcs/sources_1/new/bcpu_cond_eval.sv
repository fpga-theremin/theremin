`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2020 10:55:12 AM
// Design Name: 
// Module Name: bcpu_cond_eval
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import bcpu_defs::*;

module bcpu_cond_eval
(
    // input flag values {V,S,Z,C}
    input logic [3:0] FLAGS_IN,
    // condition code, 0000 is unconditional
    input logic [3:0] CONDITION_CODE,
    
    // 1 if condition is met
    output logic CONDITION_RESULT
);

logic condition_result_raw;

assign CONDITION_RESULT = condition_result_raw; 

always_comb case(CONDITION_CODE)
    COND_NONE: condition_result_raw <= 1'b1;              // 0000 jmp  1                 unconditional
    
    COND_NC:   condition_result_raw <= ~FLAGS_IN[FLAG_C]; // 0001 jnc  c = 0
    COND_NZ:   condition_result_raw <= ~FLAGS_IN[FLAG_Z]; // 0010 jnz  z = 0             jne
    COND_Z:    condition_result_raw <=  FLAGS_IN[FLAG_Z]; // 0011 jz   z = 1             je

    COND_NS:   condition_result_raw <= ~FLAGS_IN[FLAG_S]; // 0100 jns  s = 0
    COND_S:    condition_result_raw <=  FLAGS_IN[FLAG_S]; // 0101 js   s = 1
    COND_NO:   condition_result_raw <= ~FLAGS_IN[FLAG_V]; // 0100 jno  v = 0
    COND_O:    condition_result_raw <=  FLAGS_IN[FLAG_V]; // 0101 jo   v = 1

    COND_A:    condition_result_raw <= (~FLAGS_IN[FLAG_C] & ~FLAGS_IN[FLAG_Z]);    // 1000 ja   c = 0 & z = 0     above (unsigned compare)            !jbe
    COND_AE:   condition_result_raw <= (~FLAGS_IN[FLAG_C] & FLAGS_IN[FLAG_Z]);     // 1001 jae  c = 0 | z = 1     above or equal (unsigned compare)
    COND_B:    condition_result_raw <=  FLAGS_IN[FLAG_C];                          // 1010 jb   c = 1             below (unsigned compare)            jc
    COND_BE:   condition_result_raw <= (FLAGS_IN[FLAG_C] | FLAGS_IN[FLAG_Z]);      // 1011 jbe  c = 1 | z = 1     below or equal (unsigned compare)   !ja

    COND_L:    condition_result_raw <= (FLAGS_IN[FLAG_V] != FLAGS_IN[FLAG_S]);                     // 1100 jl   v != s            less (signed compare)
    COND_LE:   condition_result_raw <= (FLAGS_IN[FLAG_V] != FLAGS_IN[FLAG_S]) | FLAGS_IN[FLAG_Z];  // 1101 jle  v != s | z = 1    less or equal (signed compare)      !jg
    COND_G:    condition_result_raw <= (FLAGS_IN[FLAG_V] == FLAGS_IN[FLAG_S]) & ~FLAGS_IN[FLAG_Z]; // 1110 jg   v = s & z = 0     greater (signed compare)            !jle
    COND_GE:   condition_result_raw <= (FLAGS_IN[FLAG_V] == FLAGS_IN[FLAG_S]) | FLAGS_IN[FLAG_Z];  // 1111 jge  v = s | z = 1     less or equal (signed compare)
endcase;


endmodule
