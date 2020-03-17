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
logic [3:0] ALU_OP;

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
            $display("ASSERTION FAILED in %m: signal != value (%h != %h)   dec (%d != %d)", signal, value, signal, value); \
            $finish; \
        end

always begin
    #5 CLK=0;
    #5 CLK=1;
end

`define executeOp( opcode, a_in, b_in, flags_in, expected_out, expected_flags) \
    @(posedge CLK) #2 EN = 1; CE = 1; A_REG_INDEX = 1; A_IN = a_in; B_CONST_OR_REG_INDEX = 3; B_IMM_MODE = 0; B_IN = b_in; ALU_OP = opcode; FLAGS_IN = flags_in; \
    @(posedge CLK) #2 EN = 0; CE = 1; A_REG_INDEX = 0; A_IN = 0; B_CONST_OR_REG_INDEX = 0; B_IMM_MODE = 0; B_IN = 0; ALU_OP = 0; FLAGS_IN = 4'b0101; \
    @(posedge CLK) #2 FLAGS_IN = 4'b1010; \
    @(posedge CLK) #3 $display("ALU op1\t%4b\ta_in\t%d\t%4h\tb_in\t%d\t%4h\tflags_in\t%4b\talu_out\t%d\t%4h\tflags_out\t%4b", \
          opcode, a_in, a_in, b_in, b_in, flags_in, ALU_OUT, ALU_OUT, FLAGS_OUT); \
    @(posedge CLK) #3 `assert(FLAGS_OUT, 4'b0101); \
    @(posedge CLK) #3 `assert(FLAGS_OUT, 4'b1010); \
    CE = 0;

initial begin
    $display("Starting ALU test");
    #3 RESET = 0;
    #1 RESET = 1; 
    EN = 0; CE = 0; A_REG_INDEX = 0; A_IN = 0; B_CONST_OR_REG_INDEX = 0; B_IMM_MODE = 0; B_IN = 0; ALU_OP = 0; FLAGS_IN = 0;
    #120 RESET = 0;
    `executeOp(ALUOP_ADD, 3, 5, 4'b0000, 3+5, 4'b0000);    
    `executeOp(ALUOP_ADD, 7, 8, 4'b0000, 7+8, 4'b0000);    
    `executeOp(ALUOP_SUB, 7, 3, 4'b0000, 7-3, 4'b0000);    
    `executeOp(ALUOP_SUB, 7, 8, 4'b0000, 16'hffff, 4'b0000);    
    $display("*** finished");
    $finish();    
end

endmodule

