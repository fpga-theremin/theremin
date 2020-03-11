`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2020 09:26:30 AM
// Design Name: 
// Module Name: bcpu_alu_universal
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

module bcpu_alu_universal
#(
    parameter DATA_WIDTH = 16
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,
    // enable ALU (when disabled it should force output to 0 and flags should be kept unchanged)
    input logic EN,


    // Operand A inputs:
    
    // when A_REG_INDEX==000 (RA is R0), use 0 instead of A_IN for operand A
    input logic[2:0] A_REG_INDEX,
    // operand A input
    input logic [DATA_WIDTH-1 : 0] A_IN,

    // Operand B inputs:
    
    // B_CONST_OR_REG_INDEX and B_IMM_MODE are needed to implement special cases for shifts and MOV
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    input [2:0] B_CONST_OR_REG_INDEX,
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    // when B_IMM_MODE == 00 and B_CONST_OR_REG_INDEX == 000, use 0 instead of B_IN as operand B value
    input [1:0] B_IMM_MODE,
    // operand B input    
    input logic [DATA_WIDTH-1 : 0] B_IN,

    // alu operation code    
    input logic [3:0] ALU_OP,
    
    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,
    
    // input flags {V, S, Z, C}
    output logic [3:0] FLAGS_OUT,
    
    // alu result output    
    output logic [DATA_WIDTH-1 : 0] ALU_OUT
);

// EN signal pipelining
logic en_stage1;
logic en_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        en_stage1 <= 'b0;
        en_stage2 <= 'b0;
    end else if (CE) begin
        en_stage2 <= en_stage1;
        en_stage1 <= EN;
    end
end

// B_IMM_MODE pipelining: needed for shifts
logic[1:0] b_imm_mode_stage1;
logic[1:0] b_imm_mode_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        b_imm_mode_stage1 <= 'b0;
        b_imm_mode_stage2 <= 'b0;
    end else if (CE) begin
        b_imm_mode_stage2 <= b_imm_mode_stage1;
        b_imm_mode_stage1 <= B_IMM_MODE;
    end
end

// input flags pipelining
logic [3:0] flags_in_stage1;
logic [3:0] flags_in_stage2;
always_ff @(posedge CLK)
    if (RESET) begin
        flags_in_stage1 <= 'b0;
        flags_in_stage2 <= 'b0;
    end else if (CE) begin
        flags_in_stage2 <= flags_in_stage1;
        flags_in_stage1 <= FLAGS_IN;
    end

// special case: INC RC, R0, RB_imm    (RC=0+RB_imm) is treated as MOV operation, w/o flags
logic is_move;
always_comb is_move <= (ALU_OP == ALUOP_INC) & (A_REG_INDEX == 3'b000); 

// flags update mask decoding
logic [3:0] flags_mask;
always_comb flags_mask[FLAG_V] <= (ALU_OP == ALUOP_ADD || ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUB || ALU_OP == ALUOP_SUBC);
always_comb flags_mask[FLAG_S] <= 'b1;
always_comb flags_mask[FLAG_Z] <= 'b1;
always_comb flags_mask[FLAG_C] <= (ALU_OP == ALUOP_ADD || ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUB || ALU_OP == ALUOP_SUBC
                                || ALU_OP == ALUOP_ROTATE || ALU_OP == ALUOP_ROTATEC);

// flags update mask pipelining
logic [3:0] flags_mask_stage1;
logic [3:0] flags_mask_stage2;
always_ff @(posedge CLK)
    if (RESET | (CE & ~EN) | is_move) begin
        flags_mask_stage1 <= 'b0;
    end else if (CE) begin
        flags_mask_stage1 <= flags_mask;
    end
always_ff @(posedge CLK)
    if (RESET) begin
        flags_mask_stage2 <= 'b0;
    end else if (CE) begin
        flags_mask_stage2 <= flags_mask_stage1;
    end

// ALUOP pipelining
logic [3:0] aluop_stage1;
always_ff @(posedge CLK) begin
    if (RESET | ~EN)
        aluop_stage1 <= 'b0;
    else if (CE) begin
        aluop_stage1 <= ALU_OP;
    end
end
logic [3:0] aluop_stage2;
always_ff @(posedge CLK) begin
    if (RESET)
        aluop_stage2 <= 'b0;
    else if (CE) begin
        aluop_stage2 <= aluop_stage1;
    end
end

// A operand pipelining
logic [DATA_WIDTH-1 : 0] a_in_reg;
always_ff @(posedge CLK) begin
    if (RESET | A_REG_INDEX == 3'b000 | ~EN)
        a_in_reg <= 'b0;
    else if (CE)
        a_in_reg <= A_IN;
end

// B operand pipelining
logic [DATA_WIDTH-1 : 0] b_in_reg;
always_ff @(posedge CLK) begin
    if (RESET | (B_IMM_MODE == 2'b00 && B_CONST_OR_REG_INDEX == 3'b000) | ~EN)
        b_in_reg <= 'b0;
    else if (CE)
        b_in_reg <= B_IN;
end

//================================================================================
// Add / subtract operations
//================================================================================
// adder operation decoding
logic is_adder_op;
logic is_subtract;
always_comb is_adder_op <= (aluop_stage1 == ALUOP_SUB || aluop_stage1 == ALUOP_SUBC || aluop_stage1 == ALUOP_DEC
                        ||  aluop_stage1 == ALUOP_ADD || aluop_stage1 == ALUOP_ADDC || aluop_stage1 == ALUOP_INC) & en_stage1;
always_comb is_subtract <= (aluop_stage1 == ALUOP_SUB || aluop_stage1 == ALUOP_SUBC || aluop_stage1 == ALUOP_DEC);


logic [DATA_WIDTH-1 : 0] adder_a_in;
logic [DATA_WIDTH-1 : 0] adder_b_in;
logic [DATA_WIDTH : 0] adder_out;
logic adder_carry_in;
logic adder_carry_out;
logic adder_overflow_out;
always_comb adder_carry_in <= ((aluop_stage1 == ALUOP_ADDC) ? flags_in_stage1[FLAG_C]
                            : (aluop_stage1 == ALUOP_SUBC) ? ~flags_in_stage1[FLAG_C]
                            : (aluop_stage1 == ALUOP_SUB || aluop_stage1 == ALUOP_DEC) ? 1'b1
                            : 1'b0) & en_stage1;
always_comb adder_a_in <= a_in_reg;
always_comb adder_b_in <= is_subtract ? ~b_in_reg : b_in_reg;
always_comb adder_out <= adder_a_in + adder_b_in + adder_carry_in;
always_comb adder_carry_out <= is_subtract ? ~adder_out[DATA_WIDTH] : adder_out[DATA_WIDTH];
always_comb adder_overflow_out <= adder_out[DATA_WIDTH] != adder_out[DATA_WIDTH-1];

// pipelining adder outputs
logic [DATA_WIDTH-1 : 0] adder_out_stage2;
logic adder_carry_out_stage2;
logic adder_overflow_out_stage2;
always_ff @(posedge CLK) begin
    if (RESET | (CE & ~is_adder_op)) begin
        adder_out_stage2 <= 'b0;
        adder_carry_out_stage2 <= 'b0;
        adder_overflow_out_stage2 <= 'b0;
    end else if (CE) begin
        adder_out_stage2 <= adder_out[DATA_WIDTH-1 : 0];
        adder_carry_out_stage2 <= adder_carry_out;
        adder_overflow_out_stage2 <= adder_overflow_out;
    end
end

//================================================================================
// Logic operations
//================================================================================
logic is_logic_op;
always_comb is_logic_op <= (aluop_stage1 == ALUOP_AND || aluop_stage1 == ALUOP_ANDN || aluop_stage1 == ALUOP_OR
                        ||  aluop_stage1 == ALUOP_XOR) & en_stage1;
logic [DATA_WIDTH-1 : 0] logic_out;
always_comb
    case(aluop_stage1[1:0])
        2'b00: logic_out <= a_in_reg & b_in_reg;  // ALUOP_AND
        2'b01: logic_out <= a_in_reg & ~b_in_reg; // ALUOP_ANDN
        2'b10: logic_out <= a_in_reg | b_in_reg;  // ALUOP_OR
        2'b11: logic_out <= a_in_reg ^ b_in_reg;  // ALUOP_XOR
    endcase

// pipelining logic outputs
logic [DATA_WIDTH-1 : 0] logic_out_stage2;
always_ff @(posedge CLK) begin
    if (RESET | (CE & ~is_logic_op)) begin
        logic_out_stage2 <= 'b0;
    end else if (CE) begin
        logic_out_stage2 <= logic_out[DATA_WIDTH-1 : 0];
    end
end


//================================================================================
// Multiplier operations
//================================================================================
logic is_multiplier_op;
logic multiplier_a_sign_extended;
logic multiplier_b_sign_extended;
logic multiplier_out_low;
logic multiplier_out_high;
always_comb multiplier_out_low <= (aluop_stage1 == ALUOP_MUL || aluop_stage1 == ALUOP_ROTATE || aluop_stage1 == ALUOP_ROTATEC);
always_comb multiplier_out_high <= (aluop_stage1 == ALUOP_MULHUU || aluop_stage1 == ALUOP_MULHSS || aluop_stage1 == ALUOP_MULHSU 
                                || aluop_stage1 == ALUOP_ROTATE || aluop_stage1 == ALUOP_ROTATEC);

always_comb is_multiplier_op <= (aluop_stage1 == ALUOP_MULHSS || aluop_stage1 == ALUOP_MULHSU || aluop_stage1 == ALUOP_MULHUU
                              || aluop_stage1 == ALUOP_MUL || aluop_stage1 == ALUOP_ROTATE || aluop_stage1 == ALUOP_ROTATEC) & en_stage1;
always_comb multiplier_a_sign_extended <= (aluop_stage1 == ALUOP_MULHSS || aluop_stage1 == ALUOP_MULHSU);
always_comb multiplier_b_sign_extended <= (aluop_stage1 == ALUOP_MULHSS);

// shifts support, C flag generation
// is multiplier operation which can be treated as left shift - for shifted out C flag generation
logic is_left_shift;
always_comb is_left_shift  <= ((aluop_stage1 == ALUOP_MUL) && b_imm_mode_stage1[1]) // any MUL with single bit immediate
                           || ((aluop_stage1 == ALUOP_ROTATE || aluop_stage1 == ALUOP_ROTATEC) && b_imm_mode_stage1 == 2'b10); // rotations with single bit < 1<<8
logic is_right_shift;
always_comb is_right_shift <= ((aluop_stage1 == ALUOP_MULHUU || aluop_stage1 == ALUOP_MULHSU)  && b_imm_mode_stage1[1])         // any MULH with single bit immediate
                           || ((aluop_stage1 == ALUOP_ROTATE || aluop_stage1 == ALUOP_ROTATEC) && b_imm_mode_stage1 == 2'b11); // rotations with single bit >= 1<<8

// shifts support, shifting in C flag with rotation (ROTATEC: RCL, RCR)
// rotate left through C: need to replace lower bit with C_in
logic is_rcl;
// rotate right through C: need to replace upper bit with C_in
logic is_rcr;
always_comb is_rcl <= (aluop_stage1 == ALUOP_ROTATEC) & en_stage1 & (b_imm_mode_stage1 == 2'b10); // ROTATEC with single bit imm < 1<<8
always_comb is_rcr <= (aluop_stage1 == ALUOP_ROTATEC) & en_stage1 & (b_imm_mode_stage1 == 2'b11); // ROTATEC with single bit imm >= 1<<8

logic signed [17:0] multiplier_a_in;
logic signed [17:0] multiplier_b_in;
logic signed [35:0] multiplier_out;
logic multiplier_carry_out;

always_comb multiplier_a_in <= { 
               {18-DATA_WIDTH{(multiplier_a_sign_extended ? a_in_reg[DATA_WIDTH-1] : 1'b0)}}, // optional sign extension 
               a_in_reg 
            };
always_comb multiplier_b_in <= { 
               {18-DATA_WIDTH{(multiplier_b_sign_extended ? b_in_reg[DATA_WIDTH-1] : 1'b0)}}, // optional sign extension 
               b_in_reg 
            };
always_comb multiplier_out <= multiplier_a_in * multiplier_b_in;

logic signed [DATA_WIDTH-1:0] multiplier_out_mixed;
always_comb multiplier_out_mixed <= 
               (multiplier_out[DATA_WIDTH*2-1:DATA_WIDTH] & {DATA_WIDTH{multiplier_out_high}})
            || (multiplier_out[DATA_WIDTH-1:0] & {DATA_WIDTH{multiplier_out_low}});

// multiplier result pipelining
logic [DATA_WIDTH-1:0] multiplier_out_stage2;
logic multiplier_out_c_stage2;
logic multiplier_out_c_enabled_stage2;
always_ff @(posedge CLK) begin
    if (RESET | (CE & ~is_multiplier_op)) begin
        multiplier_out_stage2 <= 'b0;
        multiplier_out_c_stage2 <= 'b0;
        multiplier_out_c_enabled_stage2 <= 'b0;
    end else if (CE) begin
        multiplier_out_stage2 <= {
             is_rcr ? flags_in_stage1[FLAG_C] : multiplier_out_mixed[DATA_WIDTH-1], // optionally replace upper bit with C for RCL
             multiplier_out_mixed[DATA_WIDTH-2:1],
             is_rcl ? flags_in_stage1[FLAG_C] : multiplier_out_mixed[0]             // optionally replace lower bit with C for RCÊ
        };
        multiplier_out_c_stage2 <= is_left_shift ? multiplier_out[DATA_WIDTH] : (is_right_shift ? multiplier_out[DATA_WIDTH-1] : 1'b0);
        multiplier_out_c_enabled_stage2 <= is_left_shift | is_right_shift;
    end
end

logic [DATA_WIDTH-1:0] alu_out_stage2;
always_comb alu_out_stage2 <= adder_out_stage2 | logic_out_stage2 | multiplier_out_stage2;


logic [3:0] new_flags;
always_comb new_flags[FLAG_V] <= ~(|alu_out_stage2);            // zero flag: 1 if all bits of result are 0
always_comb new_flags[FLAG_S] <= alu_out_stage2[DATA_WIDTH-1];  // sign flag: top bit of result
always_comb new_flags[FLAG_Z] <= adder_overflow_out_stage2;     // overflow flag: from adder
always_comb new_flags[FLAG_C] <=
        multiplier_out_c_enabled_stage2
        ? multiplier_out_c_stage2     // carry flag from multiplier rotation
        : adder_carry_out_stage2;     // carry flag from adder

logic [3:0] flags_stage2;
always_comb flags_stage2 <= (flags_in_stage2 & ~flags_mask_stage2) | (new_flags & flags_mask_stage2);

// result flags
logic [3:0] flags_stage3;
always_ff @(posedge CLK)
    if (RESET)
        flags_stage3 <= 'b0;
    else if (CE)
        flags_stage3 <= flags_stage2;
        
assign FLAGS_OUT = flags_stage3;

// result value
logic [DATA_WIDTH-1 : 0] alu_out_stage3;
always_ff @(posedge CLK)
    if (RESET)
        alu_out_stage3 <= 'b0;
    else if (CE)
        alu_out_stage3 <= alu_out_stage2;

assign ALU_OUT = alu_out_stage3;

endmodule
