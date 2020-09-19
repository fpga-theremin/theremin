`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2020 08:21:25 AM
// Design Name: 
// Module Name: bcpu_alu_universal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      16-bit ALU, 3-stage pipeline
// Dependencies: 
//      No platform specific features 
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
    // input clock, ~200..260MHz
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // enable ALU, (when 1, inputs contain new ALU operation, result will be available after 3 CLK cycles)
    input logic ALU_EN,

    // operand A input
    input logic [DATA_WIDTH-1 : 0] A_IN,

    // operand B input
    input logic [DATA_WIDTH-1 : 0] B_IN,

    // alu operation code, see aluop_t enum 
    input logic [3:0] ALU_OP,

    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,
    
    // output flags {V, S, Z, C} - delayed by 3 clock cycles from inputs
    output logic [3:0] FLAGS_OUT,
    
    // alu result output         - delayed by 3 clock cycles from inputs
    output logic [DATA_WIDTH-1 : 0] ALU_OUT
);

// buffer all inputs
logic [DATA_WIDTH-1:0] a_in_reg;
logic [DATA_WIDTH-1:0] b_in_reg;
logic [3:0] alu_op_reg;
logic alu_en_reg;
logic [3:0] flags_in_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        a_in_reg <= 'b0;
        b_in_reg <= 'b0;
        flags_in_reg <= 'b0;
        alu_op_reg <= 'b0;
        alu_en_reg <= 'b0;
    end else if (CE) begin
        a_in_reg <= A_IN;
        b_in_reg <= B_IN;
        flags_in_reg <= FLAGS_IN;
        alu_op_reg <= ALU_OP;
        alu_en_reg <= ALU_EN;
    end
end

// two additional pipeline stages for storing of flags 
logic [3:0] flags_in_stage1;
logic [3:0] flags_in_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        flags_in_stage1 <= 'b0;
        flags_in_stage2 <= 'b0;
    end else if (CE) begin
        flags_in_stage2 <= flags_in_stage1;
        flags_in_stage1 <= flags_in_reg;
    end
end

// Flags update mask
logic [3:0] flags_update_mask_stage1;
logic [3:0] flags_update_mask_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        flags_update_mask_stage1 <= 'b0;
        flags_update_mask_stage2 <= 'b0;
    end else if (CE) begin
        flags_update_mask_stage2 <= flags_update_mask_stage1;
        if (~alu_en_reg) begin
            flags_update_mask_stage1 <= 'b0;
        end else begin
            case (alu_op_reg)
                ALUOP_INCNF:  flags_update_mask_stage1 <= 4'b0000; //    = 4'b0000, //   RC = RA + RB                                 ....       MOV, NOP
                ALUOP_DECNF:  flags_update_mask_stage1 <= 4'b0000; //    = 4'b0001, //   RC = RA - RB                                 ....
                ALUOP_INC:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b0000, //   RC = RA + RB                                 .SZ.
                ALUOP_DEC:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b0001, //   RC = RA - RB                                 .SZ.
            
                ALUOP_ADD:    flags_update_mask_stage1 <= 4'b1111; //    = 4'b0100, //   RC = RA + RB                                 VSZC
                ALUOP_SUB:    flags_update_mask_stage1 <= 4'b1111; //    = 4'b0101, //   RC = RA - RB                                 VSZC       CMP
                ALUOP_ADDC:   flags_update_mask_stage1 <= 4'b1111; //    = 4'b0110, //   RC = RA + RB + CF                            VSZC
                ALUOP_SUBC:   flags_update_mask_stage1 <= 4'b1111; //    = 4'b0111, //   RC = RA - RB - CF                            VSZC       CMPC
                
                ALUOP_AND:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b1000, //   RC = RA & RB                                 .SZ.
                ALUOP_XOR:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b1001, //   RC = RA ^ RB                                 .SZ.
                ALUOP_OR:     flags_update_mask_stage1 <= 4'b0110; //    = 4'b1010, //   RC = RA | RB                                 .SZ.
                ALUOP_ANDN:   flags_update_mask_stage1 <= 4'b0110; //    = 4'b1011, //   RC = RA & ~RB                                .SZ.
                
                ALUOP_MUL:    flags_update_mask_stage1 <= 4'b0000; //    = 4'b1100, //   RC = low(RA * RB)                            .SZ.       SHL, SAL
                ALUOP_MULHUU: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1101, //   RC = high(unsigned RA * unsigned RB)         .SZ.       SHR
                ALUOP_MULHSS: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1110, //   RC = high(signed RA * signed RB)             .SZ.
                ALUOP_MULHSU: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1111  //   RC = high(signed RA * unsigned RB)           .SZ.       SAR
            endcase
        end
            
    end
end

// Operation type decoder

typedef enum logic[1:0] {
    RESULT_MUX_ADDER   =  2'b00,    // adder result
    RESULT_MUX_LOGIC   =  2'b01,    // logic result
    RESULT_MUX_MULL    =  2'b10,    // lower part of multiplier result
    RESULT_MUX_MULH    =  2'b11     // higher half of multiplier result
} result_mux_t;

logic [1:0] result_mux_index;
logic [1:0] result_mux_index_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        result_mux_index <= RESULT_MUX_ADDER;
        result_mux_index_stage2 <= RESULT_MUX_ADDER;
    end else if (CE) begin 
        result_mux_index_stage2 <= result_mux_index;
        result_mux_index <=
              (alu_op_reg[3] == 1'b0)    ? RESULT_MUX_ADDER   // ops 0000..0111: adder
            : (alu_op_reg[3:2] == 2'b10) ? RESULT_MUX_LOGIC   // ops 1000..1011: logic
            : (alu_op_reg ==ALUOP_MUL)   ? RESULT_MUX_MULL    // op  1100:       multiplier low half
            :                              RESULT_MUX_MULH;   // ops 1101,1110,1111: multiplier high half
    end
end 

/***********************************************
   Adder
 ***********************************************

//  mnemonic             opcode                                                   flags      mapped
	ALUOP_INC        = 4'b0000, //   RC = RA + RB                                 .SZ.       MOV, NOP
	ALUOP_DEC        = 4'b0001, //   RC = RA - RB                                 .SZ.
	ALUOP_BUS0       = 4'b0010, //   reserved for bus instructions
	ALUOP_BUS1       = 4'b0011, //   reserved for bus instructions

	ALUOP_ADD        = 4'b0100, //   RC = RA + RB                                 VSZC
	ALUOP_SUB        = 4'b0101, //   RC = RA - RB                                 VSZC       CMP
	ALUOP_ADDC       = 4'b0110, //   RC = RA + RB + CF                            VSZC
	ALUOP_SUBC       = 4'b0111, //   RC = RA - RB - CF                            VSZC       CMPC
*/

logic adder_op_is_subtract;
logic carry_in;
always_comb adder_op_is_subtract <= (alu_op_reg[0] == 1'b1 && alu_op_reg[3] == 1'b0);
always_comb carry_in <= ((alu_op_reg==ALUOP_ADDC) || (alu_op_reg==ALUOP_SUBC)) ? flags_in_reg[FLAG_C] : 1'b0;

// adder result (with additional bit for carry out)    
logic [DATA_WIDTH : 0] adder_reg;
always_ff @(posedge CLK) begin
    if (RESET) begin
        adder_reg <= 'b0;
    end else if (CE) begin
        if (adder_op_is_subtract)
            adder_reg <= {1'b0, a_in_reg} - {1'b0, b_in_reg} - (~carry_in);
        else
            adder_reg <= {1'b0, a_in_reg} + {1'b0, b_in_reg} + carry_in;
    end
end

// adder carry and overflow logic
logic adder_carry_out;
logic adder_overflow;
always_ff @(posedge CLK) begin
    if (RESET) begin
        adder_carry_out <= 'b0;
        adder_overflow <= 'b0;
    end else if (CE) begin
        adder_carry_out <= adder_reg[DATA_WIDTH];
        adder_overflow <= adder_reg[DATA_WIDTH] ^ adder_reg[DATA_WIDTH-1];
    end
end


/***********************************************
   Multiplier
 ***********************************************

	ALUOP_MUL        = 4'b1100, //   RC = low(RA * RB)                            .SZ.       SHL, SAL
	ALUOP_MULHUU     = 4'b1101, //   RC = high(unsigned RA * unsigned RB)         .SZ.       SHR
	ALUOP_MULHSS     = 4'b1110, //   RC = high(signed RA * signed RB)             .SZ.
	ALUOP_MULHSU     = 4'b1111  //   RC = high(signed RA * unsigned RB)           .SZ.       SAR
 
*/

// operands sign extension
logic a_sign;
logic b_sign;
always_comb a_sign <= (alu_op_reg == ALUOP_MULHSU) | (alu_op_reg == ALUOP_MULHSS) ? a_in_reg[DATA_WIDTH-1] : 1'b0;
always_comb b_sign <= (alu_op_reg == ALUOP_MULHSS) ? b_in_reg[DATA_WIDTH-1] : 1'b0;

logic signed [DATA_WIDTH : 0] mul_a;
logic signed [DATA_WIDTH : 0] mul_b;
always_comb mul_a <= {a_sign, a_in_reg};
always_comb mul_b <= {b_sign, b_in_reg};

// multiplier result register
logic signed [DATA_WIDTH*2 + 1 : 0] mul_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        mul_reg <= 'b0;
    end else if (CE) begin
        mul_reg <= mul_a * mul_b;
    end
end

/***********************************************
   Logic operations
 ***********************************************

	ALUOP_AND        = 4'b1000, //   RC = RA & RB                                 .SZ.
	ALUOP_XOR        = 4'b1001, //   RC = RA ^ RB                                 .SZ.
	ALUOP_OR         = 4'b1010, //   RC = RA | RB                                 .SZ.
	ALUOP_ANDN       = 4'b1011, //   RC = RA & ~RB                                .SZ.
 
*/

logic [DATA_WIDTH-1 : 0] logic_reg;
always_ff @(posedge CLK) begin
    if (RESET) begin
        logic_reg <= 'b0;
    end else if (CE) begin
        case (alu_op_reg[1:0])
            2'b00: logic_reg <= a_in_reg & b_in_reg;  // ALUOP_AND 
            2'b01: logic_reg <= a_in_reg ^ b_in_reg;  // ALUOP_XOR 
            2'b10: logic_reg <= a_in_reg | b_in_reg;  // ALUOP_OR 
            2'b11: logic_reg <= a_in_reg & ~b_in_reg; // ALUOP_ANDN 
        endcase
    end
end


// result mux

logic [DATA_WIDTH-1 : 0] result_reg;
always_ff @(posedge CLK) begin
    if (RESET) begin
        result_reg <= 'b0;
    end else if (CE) begin
        case (result_mux_index_stage2)
            RESULT_MUX_ADDER: result_reg <= adder_reg[DATA_WIDTH-1 : 0]; 
            RESULT_MUX_LOGIC: result_reg <= logic_reg; 
            RESULT_MUX_MULL:  result_reg <= mul_reg[DATA_WIDTH-1:0]; 
            RESULT_MUX_MULH:  result_reg <= mul_reg[DATA_WIDTH*2-1:DATA_WIDTH];
        endcase
    end
end

assign ALU_OUT = result_reg;

// output flags
logic [3:0] new_flags;
always_comb
     FLAGS_OUT <= (new_flags & flags_update_mask_stage2) 
                | (flags_in_stage2 & ~flags_update_mask_stage2);

always_comb new_flags[FLAG_Z] <= ~(&result_reg);           // 1 when all bits of result are 0 
always_comb new_flags[FLAG_S] <= result_reg[DATA_WIDTH-1]; // upper bit is sign
always_comb new_flags[FLAG_C] <= adder_carry_out;
always_comb new_flags[FLAG_V] <= adder_overflow;


endmodule
