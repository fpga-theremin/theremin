`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2020 04:19:05 PM
// Design Name: 
// Module Name: bcpu_alu_tb
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

module bcpu_alu_tb(

    );

localparam DATA_WIDTH = 16;
localparam EMBEDDED_IMMEDIATE_TABLE = 0;

// input clock
logic CLK;
// when 1, enable pipeline step, when 0 pipeline is paused
logic CE;
// reset signal, active 1
logic RESET;
// enable ALU (when disabled it should force output to 0 and flags should be kept unchanged)
logic EN;


// Operand A inputs:

// when A_REG_INDEX==000 (RA is R0), use 0 instead of A_IN for operand A
logic[2:0] A_REG_INDEX;
// operand A input
logic [DATA_WIDTH-1 : 0] A_IN;

// Operand B inputs:

// B_CONST_OR_REG_INDEX and B_IMM_MODE are needed to implement special cases for shifts and MOV
// this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
logic [2:0] B_CONST_OR_REG_INDEX;
// immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
// when B_IMM_MODE == 00 and B_CONST_OR_REG_INDEX == 000, use 0 instead of B_IN as operand B value
logic [1:0] B_IMM_MODE;
// operand B input
logic [DATA_WIDTH-1 : 0] B_IN;

// alu operation code    
//logic [3:0] ALU_OP;
aluop_t ALU_OP;

// input flags {V, S, Z, C}
logic [3:0] FLAGS_IN;

// output flags {V, S, Z, C}
logic [3:0] FLAGS_OUT;

// alu result output    
logic [DATA_WIDTH-1 : 0] ALU_OUT;


logic [29:0] debug_dsp_a_in;  // 30-bit A data input
logic [17:0] debug_dsp_b_in;  // 18-bit B data input
logic [47:0] debug_dsp_c_in;  // 48-bit C data input
logic [24:0] debug_dsp_d_in;  // 25-bit D data input
logic [47:0] debug_dsp_p_out; // 48-bit P data output
logic[3:0] debug_dsp_alumode;               // 4-bit input: ALU control input
logic[4:0] debug_dsp_inmode;                // 5-bit input: INMODE control input
logic[6:0] debug_dsp_opmode;                // 7-bit input: Operation mode input
logic debug_dsp_carryout;

bcpu_alu
#(
    .DATA_WIDTH(DATA_WIDTH),
    .EMBEDDED_IMMEDIATE_TABLE(EMBEDDED_IMMEDIATE_TABLE)
)
bcpu_alu_inst
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,
    // enable ALU (when disabled it should force output to 0 and flags should be kept unchanged)
    .EN,
    // Operand A inputs:
    // when A_REG_INDEX==000 (RA is R0), use 0 instead of A_IN for operand A
    .A_REG_INDEX,
    // operand A input
    .A_IN,
    // Operand B inputs:
    // B_CONST_OR_REG_INDEX and B_IMM_MODE are needed to implement special cases for shifts and MOV
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    .B_CONST_OR_REG_INDEX,
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    // when B_IMM_MODE == 00 and B_CONST_OR_REG_INDEX == 000, use 0 instead of B_IN as operand B value
    .B_IMM_MODE,
    // operand B input
    .B_IN,
    // alu operation code    
    .ALU_OP,
    // input flags {V, S, Z, C}
    .FLAGS_IN,
    // output flags {V, S, Z, C}
    .FLAGS_OUT,
    // alu result output    
    .ALU_OUT
    
    
    , .*
);

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value (%h != %h)   dec (%d != %d)   bin (%b != %b)", \
            signal, value, signal, value, signal, value ); \
            $finish; \
        end

always begin
    #5 CLK=0;
    #5 CLK=1;
end

typedef logic[15:0] data_t;
 

`define executeOp( opcode, a_in, b_in, flags_in, expected_out, expected_flags) \
    @(posedge CLK) #2 EN = 1; CE = 1; A_REG_INDEX = 1; A_IN = a_in; B_CONST_OR_REG_INDEX = 3; B_IMM_MODE = 0; B_IN = b_in; ALU_OP = opcode; FLAGS_IN = flags_in; \
    @(posedge CLK) #2 EN = 0; CE = 1; A_REG_INDEX = 0; A_IN = 0; B_CONST_OR_REG_INDEX = 0; B_IMM_MODE = 0; B_IN = 0; ALU_OP = ALUOP_INC; FLAGS_IN = 4'b0101; \
    @(posedge CLK) #2 FLAGS_IN = 4'b1010; \
    @(posedge CLK) #3 $display("%s\ta_in\t%5d\t%4h\tb_in\t%5d\t%4h\tflags_in\t%4b\talu_out\t%5d\t%4h\tflags_out\t%4b\texpected\t%d\t%4h\tfl\t%4b", \
          opcode.name, a_in, a_in, b_in, b_in, flags_in, \
          ALU_OUT, ALU_OUT, FLAGS_OUT, \
          data_t'(expected_out), data_t'(expected_out), expected_flags); \
          `assert(ALU_OUT, data_t'(expected_out)); \
          `assert(FLAGS_OUT, expected_flags); \
    @(posedge CLK) #3 `assert(FLAGS_OUT, 4'b0101); \
    @(posedge CLK) #3 `assert(FLAGS_OUT, 4'b1010); \
    CE = 0;

`define startOp( opcode, a_in, b_in, flags_in, expected_out, expected_flags) \
    @(posedge CLK) #2 EN = 1; CE = 1; A_REG_INDEX = 1; A_IN = a_in; B_CONST_OR_REG_INDEX = 3; B_IMM_MODE = 0; B_IN = b_in; ALU_OP = opcode; FLAGS_IN = flags_in; \
    $display(" start\t%s\ta_in\t%6d\t%4h\tb_in\t%6d\t%4h\tflags_in\t%4b", \
          opcode.name, a_in, a_in, b_in, b_in, flags_in);
`define resultOp( opcode, a_in, b_in, flags_in, expected_out, expected_flags) \
    #1 $display(" result\t%s\ta_in\t%6d\t%4h\tb_in\t%6d\t%4h\tflags_in\t%4b\talu_out\t%6d\t%4h\tflags_out\t%4b\texpected\t%6d\t%4h\tfl\t%4b", \
          opcode.name, a_in, a_in, b_in, b_in, flags_in, \
          ALU_OUT, ALU_OUT, FLAGS_OUT, \
          expected_out, expected_out, expected_flags);


initial begin
    $display("Starting ALU test");
    #3 RESET = 0;
    #1 RESET = 1; 
    EN = 0; CE = 0; A_REG_INDEX = 0; A_IN = 0; B_CONST_OR_REG_INDEX = 0; B_IMM_MODE = 0; B_IN = 0; ALU_OP = ALUOP_INC; FLAGS_IN = 0;
    #120 RESET = 0;
    `executeOp(ALUOP_ADD, 3, 5, 4'b0001, 3+5, 4'b0000);    
    `executeOp(ALUOP_ADD, 7, 8, 4'b1000, 7+8, 4'b0000);    
    `executeOp(ALUOP_INC, 3, 5, 4'b0101, 3+5, 4'b0001);    
    `executeOp(ALUOP_INC, 7, 8, 4'b1010, 7+8, 4'b1000);    
    `executeOp(ALUOP_ADDC, 3, 5, 4'b0001, 3+5+1, 4'b0000);    
    `executeOp(ALUOP_ADDC, 7, 8, 4'b1001, 7+8+1, 4'b0000);    
    `executeOp(ALUOP_AND,  16'hf5ac, 16'h3458, 4'b0100, 16'hf5ac & 16'h3458, 4'b0000);    
    `executeOp(ALUOP_ANDN,  16'hf5ac, 16'h3458, 4'b0101, 16'hf5ac & ~16'h3458, 4'b0101);    
    `executeOp(ALUOP_OR,  16'hf5ac, 16'h3458, 4'b1100, 16'hf5ac | 16'h3458, 4'b1100);    
    `executeOp(ALUOP_XOR,  16'hf5ac, 16'h3458, 4'b0100, 16'hf5ac ^ 16'h3458, 4'b0100);    
    `executeOp(ALUOP_XOR,  16'haaaa, 16'haaaa, 4'b0100, 16'haaaa ^ 16'haaaa, 4'b0010);    
    `executeOp(ALUOP_XOR,  16'haaaa, 16'h5555, 4'b1101, 16'haaaa ^ 16'h5555, 4'b1101);    
    `executeOp(ALUOP_SUB, 7, 3, 4'b0100, 7-3, 4'b1001);    
    `executeOp(ALUOP_SUB, 7, 8, 4'b0010, 16'hffff, 4'b1100);    
    `executeOp(ALUOP_SUB, 12345, 12345, 4'b0000, 0, 4'b1011);    
    `executeOp(ALUOP_MUL, 123, 456, 4'b0000, 123*456, 4'b0100);    
    `executeOp(ALUOP_MULHUU, 16'h1234, 16'h1000, 4'b1111, 16'h0123, 4'b1001);    

    `startOp(ALUOP_ADD,   123, 456, 4'b1111, 123+456,    4'b0000);    
    `startOp(ALUOP_ADDC,  123, 456, 4'b1111, 123+456+1,  4'b0000);    
    `startOp(ALUOP_SUB,   123, 23,  4'b0000, 123-23,     4'b0000);    
    `startOp(ALUOP_SUB,   123, 23,  4'b0001, 123-23,     4'b0000);    
       `resultOp(ALUOP_ADD,   123, 456, 4'b1111, 123+456,    4'b0000);    
    `startOp(ALUOP_SUBC,  123, 23,  4'b0000, 123-23,     4'b0000);    
       `resultOp(ALUOP_ADDC,  123, 456, 4'b1111, 123+456+1,  4'b0000);    
    `startOp(ALUOP_SUBC,  123, 23,  4'b0001, 123-23-1,   4'b0000);    
       `resultOp(ALUOP_SUB,   123, 23,  4'b0000, 123-23,     4'b0000);    
    `startOp(ALUOP_AND,   16'hff12, 16'h1331,  4'b0000, 16'hff12 & 16'h1331, 4'b0000);    
       `resultOp(ALUOP_SUB,   123, 23,  4'b0001, 123-23,     4'b0000);    
    `startOp(ALUOP_ANDN,  16'hff12, 16'h1331,  4'b0000, 16'hff12 & ~16'h1331, 4'b0000);    
       `resultOp(ALUOP_SUBC,  123, 23,  4'b0000, 123-23,     4'b0000);    
    `startOp(ALUOP_OR,    16'hff12, 16'h1331,  4'b0000, 16'hff12 | 16'h1331, 4'b0000);    
       `resultOp(ALUOP_SUBC,  123, 23,  4'b0001, 123-23-1,   4'b0000);    
    `startOp(ALUOP_XOR,   16'hff12, 16'h1331,  4'b0000, 16'hff12 ^ 16'h1331, 4'b0000);    
       `resultOp(ALUOP_AND,   16'hff12, 16'h1331,  4'b0000, 16'hff12 & 16'h1331, 4'b0000);    
    `startOp(ALUOP_MUL,    5, 7,  4'b0000, 5*7, 4'b0000);    
       `resultOp(ALUOP_ANDN,  16'hff12, 16'h1331,  4'b0000, 16'hff12 & ~16'h1331, 4'b0000);    
    `startOp(ALUOP_MULHUU, 16'h0300, 16'h0500,  4'b0000, 15, 4'b0000);    
       `resultOp(ALUOP_OR,    16'hff12, 16'h1331,  4'b0000, 16'hff12 | 16'h1331, 4'b0000);    
    `startOp(ALUOP_MULHSU, -16'h0300, 16'h0500,  4'b0000, -15, 4'b0000);    
       `resultOp(ALUOP_XOR,   16'hff12, 16'h1331,  4'b0000, 16'hff12 ^ 16'h1331, 4'b0000);    

    $display("*** finished");
    $finish();    
end

endmodule

