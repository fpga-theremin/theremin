`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2020 02:06:44 PM
// Design Name: 
// Module Name: bcpu_instr_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     Instruction decoder
//     Fetches register values needed for instruction
//     Calculates address for memory operation or jumps
//     Checks flags for conditional jumps
//     Decodes immediate value, if operation needs it
//     Decodes instruction categories
//     Prepares all needed inputs for execution blocks
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*

      BCPU16 instruction set

 16  14  12  10 9 8 7 6 5 4 3 2 1 0
------------------------------------
0 0 0|s s s|m|b b b|m|d d d|z z z z |  ALU       (16 ops)
0 0 1|d d d|m|b b b|m|r r|a a a a a |  BUSREAD   (4 ops)
0 1 0|s s s|m|b b b|m|w w|a a a a a |  BUSWRITE  (4 ops)
0 1 1|d d d|0|b b b|i i i i i i i i |  LOAD      Rddd, (Rbbb + offs8)
0 1 1|d d d|1|i i i i i i i i i i i |  LOAD      Rddd, (PC + offs11)
1 0 0|s s s|0|b b b|i i i i i i i i |  STORE     Rsss, (Rbbb + offs8)
1 0 0|s s s|1|i i i i i i i i i i i |  STORE     Rsss (PC + offs11)
1 0 1|d d d|0|b b b|i i i i i i i i |  CALL      Rddd, (Rbbb + offs8)
1 0 1|d d d|1|i i i i i i i i i i i |  CALL      Rddd, (PC + offs11)
1 1|c c c c|0|b b b|i i i i i i i i |  JMPC      cccc, (Rbbb + offs8)
1 1|c c c c|1|i i i i i i i i i i i |  JMPC      cccc, (PC + offs11)


sss         Source register index - to write to memory or bus or ALU operand 1
ddd         Destinatoin register index - to write result of operation
bbb         Base address register index or ALU operand 2 register index, mask register index for bus operations
mm          Immediate mode for ALU and BUS operations - when 00 use register bbb value, 01..11: replace with const
cccc        Condition code for conditional jumps
iiiiiiii    Offset from base for memory and jump operations (8 or 11 bits)
zzzz        ALU opcode
rr          BUS READ opcode
ww          BUS WRITE opcode
aaaaa		BUS address

*/

import bcpu_defs::*;

module bcpu_instr_decoder
#(
    // data width
    parameter DATA_WIDTH = 16,
    // instruction width
    parameter INSTR_WIDTH = 18,
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    parameter PC_WIDTH = 10,
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    parameter ADDR_WIDTH = 10
)
(
    // INPUTS
    // instruction to decode - from program memory
    input logic [INSTR_WIDTH-1:0] INSTR_IN,
    // current program counter (address of this instruction)
    input logic [PC_WIDTH-1:0] PC_IN,
    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,

    // decoded instruction outputs
    // register A index : to register file
    output logic [2:0] A_INDEX,
    // register B or immediate index : to register file 
    output logic [2:0] B_INDEX,
    
    // register B value from register file -- for address and ALU operand calculations 
    input logic [DATA_WIDTH-1:0] B_VALUE_IN,
    // register B or const for ALU and IOBUS ops
    output logic [DATA_WIDTH-1:0] B_VALUE_OUT,
    
    // calculated address value (for LOAD,STORE,CALL,JUMP)
    output logic [ADDR_WIDTH-1:0] ADDR_VALUE,

    // destination register index
    output logic [2:0] DST_REG_INDEX,
    // data source mux index for writing to register
    output logic [1:0] DST_REG_SOURCE,
    // 1 to enable writing of operation result to destination register
    output logic DST_REG_WREN,

    // 1 for ALU op
    output logic ALU_EN,
    // 1 for BUS read op
    output logic BUS_RD_EN,
    // 1 for BUS write op
    output logic BUS_WR_EN,
    // 1 for LOAD and STORE ops
    output logic MEM_EN,
    // 1 for STORE op
    output logic MEM_WRITE_EN,
    // 1 for CALL and JMP with condition met
    output logic JMP_EN,

    // ALU operation code (valid if ALU_EN==1)
    output logic [3:0] ALU_OP,

    // bus operation
    output logic [1:0] BUS_OP,
    // bus address
    output logic [4:0] BUS_ADDR


);

// instruction parts
logic [2:0] ra_index;
logic [2:0] rb_index;
logic [3:0] jmp_cond;
logic [1:0] imm_mode;
logic addr_mode;
logic [10:0] addr_offset;
logic [3:0] alu_op;
logic [1:0] bus_op;
logic [4:0] bus_addr;

// 1 if condition is met
logic cond_result;


// register A index 
assign A_INDEX = ra_index;
// register B or immediate index 
assign B_INDEX = rb_index;

/*

      BCPU16 instruction set

 16  14  12  10 9 8 7 6 5 4 3 2 1 0
------------------------------------
0 0 0|s s s|m|b b b|m|d d d|z z z z |  ALU       (16 ops)
0 0 1|d d d|m|b b b|m|r r|a a a a a |  BUSREAD   (4 ops)
0 1 0|s s s|m|b b b|m|w w|a a a a a |  BUSWRITE  (4 ops)
0 1 1|d d d|0|b b b|i i i i i i i i |  LOAD      Rddd, (Rbbb + offs8)
0 1 1|d d d|1|i i i i i i i i i i i |  LOAD      Rddd, (PC + offs11)
1 0 0|s s s|0|b b b|i i i i i i i i |  STORE     Rsss, (Rbbb + offs8)
1 0 0|s s s|1|i i i i i i i i i i i |  STORE     Rsss (PC + offs11)
1 0 1|d d d|0|b b b|i i i i i i i i |  CALL      Rddd, (Rbbb + offs8)
1 0 1|d d d|1|i i i i i i i i i i i |  CALL      Rddd, (PC + offs11)
1 1|c c c c|0|b b b|i i i i i i i i |  JMPC      cccc, (Rbbb + offs8)
1 1|c c c c|1|i i i i i i i i i i i |  JMPC      cccc, (PC + offs11)

sss         Source register index - to write to memory or bus or ALU operand 1
ddd         Destinatoin register index - to write result of operation
bbb         Base address register index or ALU operand 2 register index, mask register index for bus operations
mm          Immediate mode for ALU and BUS operations - when 00 use register bbb value, 01..11: replace with const
cccc        Condition code for conditional jumps
iiiiiiii    Offset from base for memory and jump operations (8 or 11 bits)
zzzz        ALU opcode
rr          BUS READ opcode
ww          BUS WRITE opcode
aaaaa		BUS address
*/

always_comb ra_index <= INSTR_IN[14:12]; // sss Source register index - to write to memory or bus or ALU operand 1
always_comb rb_index <= INSTR_IN[10:8];  // bbb Base address register index or ALU operand 2 register index, mask register index for bus operations
always_comb jmp_cond <= INSTR_IN[15:12]; // cccc        Condition code for conditional jumps 
always_comb addr_mode <= INSTR_IN[11]; 
always_comb imm_mode <= { INSTR_IN[11], INSTR_IN[7]};
always_comb addr_offset <= INSTR_IN[10:0];
always_comb alu_op <= INSTR_IN[3:0];
always_comb bus_op <= INSTR_IN[6:5];
always_comb bus_addr <= INSTR_IN[4:0];

assign A_INDEX = ra_index;
assign B_INDEX = rb_index;

logic [2:0] instr_category;
assign instr_category = INSTR_IN[17:15]; 

// 0 oo aaaa m bbbb oo rrrr
assign ALU_OP = alu_op;
assign BUS_OP = bus_op;

always_comb ALU_EN    = (instr_category == INSTR_ALU);
always_comb BUS_RD_EN = (instr_category == INSTR_BUSREAD);
always_comb BUS_WR_EN = (instr_category == INSTR_BUSWRITE);
always_comb MEM_EN    = (instr_category == INSTR_LOAD) | (instr_category == INSTR_STORE);
always_comb MEM_WRITE_EN  = (instr_category == INSTR_STORE);
always_comb JMP_EN    = (instr_category == INSTR_CALL) 
                      | ( ((instr_category == INSTR_JMPC0) | (instr_category == INSTR_JMPC1)) & cond_result);

// 0 00 rrrr m bbbb 1 oo aaa
always_comb BUS_OP <= bus_op;
always_comb BUS_ADDR <= bus_addr;


logic [2:0] dst_reg;
assign dst_reg = (instr_category == INSTR_ALU) ? INSTR_IN[6:4] : ra_index;

//    // destination register index
assign DST_REG_INDEX = dst_reg; 
//    // data source mux index for writing to register
assign DST_REG_SOURCE = (instr_category == INSTR_ALU)  ? REG_WRITE_FROM_ALU
                      : (instr_category == INSTR_LOAD) ? REG_WRITE_FROM_MEM
                      : (instr_category == INSTR_CALL) ? REG_WRITE_FROM_JMP
                      :                                  REG_WRITE_FROM_BUS;
// 1 to enable writing of operation result to destination register
assign DST_REG_WREN 
                = (    (instr_category == INSTR_ALU) 
                    || (instr_category == INSTR_LOAD)
                    || (instr_category == INSTR_BUSREAD) 
                    || (instr_category == INSTR_CALL)
                  ) 
                    && (dst_reg != 3'b000); 


logic [ADDR_WIDTH-1:0] addr_value;
assign ADDR_VALUE = addr_value;

bcpu_addr_adder
#(
    // address width
    .ADDR_WIDTH(ADDR_WIDTH)
)
bcpu_addr_adder_inst
(
    .RB_IN(B_VALUE_IN[ADDR_WIDTH-1:0]),
    .PC_IN({ {ADDR_WIDTH-PC_WIDTH{1'b0}},  PC_IN}),
    // offset 10 bits, for MODE=0 top 4 bits should be zeroed
    .OFFSET_IN(addr_offset),
    .MODE(addr_mode),
    .ADDR_OUT(addr_value)
);

logic [DATA_WIDTH - 1 : 0] b_value;
assign B_VALUE_OUT = b_value;

bcpu_breg_consts
#(
    .DATA_WIDTH(DATA_WIDTH)
)
bcpu_breg_consts_inst
(
    // input register value
    .B_VALUE_IN(B_VALUE_IN),
    // B register index from instruction - used as const index when CONST_MODE==1 
    .B_REG_INDEX(rb_index), 
    // const_mode- when 1, replace B register value with constant
    .CONST_MODE(imm_mode),
    // output value: CONST_MODE?(1<<B_REG_INDEX):B_VALUE_IN    
    .B_VALUE_OUT(b_value)
);

bcpu_cond_eval bcpu_cond_eval_inst
(
    // input flag values {V,S,Z,C}
    .FLAGS_IN(FLAGS_IN),
    // condition code, 0000 is unconditional
    .CONDITION_CODE(jmp_cond),
    
    // 1 if condition is met
    .CONDITION_RESULT(cond_result)
);


endmodule
