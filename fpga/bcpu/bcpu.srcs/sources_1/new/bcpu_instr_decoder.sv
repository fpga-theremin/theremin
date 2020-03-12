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

import bcpu_defs::*;

module bcpu_instr_decoder
#(
    // data width
    parameter DATA_WIDTH = 16,
    // instruction width
    parameter INSTR_WIDTH = 18,
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    parameter PC_WIDTH = 12,
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    parameter ADDR_WIDTH = 14,
    // register file address width, 3 + 2 == 8 registers * 4 threads
    parameter REG_ADDR_WIDTH = 5   // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5 
)
(
    // INPUTS
    // instruction to decode
    input logic [INSTR_WIDTH-1:0] INSTR_IN,
    // current program counter (address of this instruction)
    input logic [PC_WIDTH-1:0] PC_IN,
    // id of current thread in barrel CPU
    input logic [1:0] THREAD_ID,
    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,

    // decoded ALU operation
    output logic [3:0] ALU_OP,
    
    output logic [1:0] IMM_MODE,

    // register A index, e.g. for ALU 
    output logic [2:0] A_INDEX,
    // register B or immediate index, e.g. for ALU 
    output logic [2:0] B_INDEX,

    // register A operand value, e.g. for ALU or write data for memory
    output logic [DATA_WIDTH-1:0] A_VALUE,
    // register B or immediate operand value, e.g. for ALU
    output logic [DATA_WIDTH-1:0] B_VALUE,

    // 1 to enable ALU operation
    output logic ALU_EN,
    // 1 if instruction is LOAD operation
    output logic LOAD_EN,
    // 1 if instruction is STORE operation
    output logic STORE_EN,
    // 1 if instruction is JUMP, CALL or conditional jump operation
    output logic JMP_EN,
    // 1 if instruction is memory WAIT operation
    output logic WAIT_EN,
    // 1 if instruction is LOAD_OP, STORE_OP, or WAIT_OP
    output logic MEMORY_EN,
    // 1 if instruction is PERIPHERIAL operation
    output logic PERIPH_EN,

    // memory or jump address calculated as base+offset
    output logic [ADDR_WIDTH-1:0] ADDR_VALUE,

    // dest reg address, xx000 to disable writing
    output logic [REG_ADDR_WIDTH-1:0] DEST_REG_ADDR,
   

    //=========================================
    // REGISTER FILE READ ACCESS
    // connect to register file
    //=========================================
    // asynchronous read port A
    // always exposes value from address RD_ADDR_A to RD_DATA_A
    output logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_A,
    input logic [DATA_WIDTH-1:0] RD_REG_DATA_A,
    //=========================================
    // asynchronous read port B 
    // always exposes value from address RD_ADDR_B to RD_DATA_B
    output logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_B,
    input logic [DATA_WIDTH-1:0] RD_REG_DATA_B

);

/*
    00 0: ALU ops
    
    00 0 rrr i bbb mmii iddd
         
        rrr RA
        bbb RB
        mm  RB mode (00=reg, 01=consts, 10,11: single bit)
        iiii ALU OP
        ddd destination register index (0: don't write)
    
    
    00 1: Peripherials
    
    00 1 rrr x bbb mmxx xaaa
    
    
    01 0: LOAD
    
    01 0 rrr 0 bbb mmaa aaaa        LOAD R, Rbase + offs6
    01 0 rrr 1 aaa aaaa aaaa        LOAD R, PC + offs11
    
    01 1: STORE
    
    01 1 rrr 0 bbb mmaa aaaa        STORE R, Rbase + offs6
    01 1 rrr 1 aaa aaaa aaaa        STORE R, PC + offs11
    
    10 x: Conditional jumps
    
    10  cccc 0 bbb mmaa aaaa        JMP   Cond1, Rbase+offs6          cond jumps to reg, cond returns, returns, 
    10  cccc 1 aaa aaaa aaaa        JMP   Cond1, PC+offs11            cond and uncond relative jumps
    
    11 0: Calls
    
    11 0 rrr 0 bbb mmaa aaaa        CALL   R, Rbase+offs6
    11 0 rrr 1 aaa aaaa aaaa        CALL   R, PC + offs11     
    
    11 1: WAIT and log jump
    
    11 1 rrr 0 bbb mmaa aaaa        WAIT   R, Rbase+offs6           memory based wait: wait until mem(Rbase+offs8) & R != 0, then put mem(Rbase+offs8) & R to register R
    11 1 aaa 1 aaa aaaa aaaa        JMP    PC+offs14                LONG JUMP PC+offs14
*/

logic[2:0] instr_category;
/*
	INSTR_ALU        = 3'b000,  //   ALU operation
	INSTR_PERIPH     = 3'b001,  //   Peripherial operations: read, write, wait
	INSTR_LOAD       = 3'b010,  //   LOAD - memory reads   
	INSTR_STORE      = 3'b011,  //   STORE - memory writes   
	INSTR_CONDJMP1   = 3'b100,  //   conditional jumps, part 1
	INSTR_CONDJMP2   = 3'b101,  //   conditional jumps, part 2   
	INSTR_CALL       = 3'b110,  //   CALL - jumps with storing return address into register   
	INSTR_JMP_WAIT   = 3'b111   //   WAIT - wait on memory value, JMP long address jump
*/
assign instr_category = INSTR_IN[INSTR_WIDTH-1:INSTR_WIDTH-3];

logic [2:0] dst_reg_index;

// register file access: higher 2 bits are always thread id 
assign DEST_REG_ADDR[4:3] = THREAD_ID;
assign RD_REG_ADDR_A[4:3] = THREAD_ID;
assign RD_REG_ADDR_B[4:3] = THREAD_ID;

logic [2:0] reg_a_index;
logic [2:0] reg_b_index;
assign reg_a_index = INSTR_IN[14:12];   // register A index
assign reg_b_index = INSTR_IN[10:8];    // register B or immediate index

// ALU
/*
    00 0 rrr i bbb mmii iddd
         
        rrr RA
        bbb RB
        mm  RB mode (00=reg, 01=consts, 10,11: single bit)
        iiii ALU OP
        ddd destination register index (0: don't write)
*/
assign ALU_OP = {INSTR_IN[11], INSTR_IN[5:3]}; // iiii from instruction

assign DEST_REG_ADDR[2:0] = dst_reg_index;
assign RD_REG_ADDR_A[2:0] = reg_a_index;    // register A index 
assign RD_REG_ADDR_B[2:0] = reg_b_index;    // register B or immediate index

logic [1:0] immediate_mode;
assign immediate_mode = INSTR_IN[7:6];      // register B immediate mode
assign IMM_MODE = immediate_mode;


// register A value can be used as is from reg file 
logic [DATA_WIDTH-1:0] a_value;
assign a_value = RD_REG_DATA_A;

// register B value should be processed by immediate constants table to allow overriding it with const 
logic [DATA_WIDTH-1:0] b_value;

assign A_VALUE = a_value;
assign B_VALUE = b_value;
assign A_INDEX = reg_a_index;
assign B_INDEX = reg_b_index;

// instantiate embed table here
bcpu_imm_table
#(
    .DATA_WIDTH(DATA_WIDTH)
)
bcpu_imm_table_inst
(
    // input register value
    .B_VALUE_IN(RD_REG_DATA_B),
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    .CONST_OR_REG_INDEX(reg_b_index), 
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    .IMM_MODE(immediate_mode),
    .B_VALUE_OUT(b_value)
);

//======================================================================
// Calculating address for jumps and memory access as base+offset

// 1 if base addr is PC (use signed offset), 0 if b_value (unsigned offset)
logic base_addr_pc;
assign base_addr_pc = INSTR_IN[11];

logic is_long_jmp = ((instr_category == INSTR_JMP_WAIT) & base_addr_pc);
logic is_wait = ((instr_category == INSTR_JMP_WAIT) & ~base_addr_pc);

// address offset sign extension value
logic offset_sign_ex;
// long PC based address:
//    11 1 aaa 1 aaa aaaa aaaa        JMP    PC+offs14                LONG JUMP PC+offs14
// short PC based address example:
//    01 1 rrr 1 aaa aaaa aaaa        STORE R, PC + offs11
// non-PC based address example:
//    11 0 rrr 0 bbb mmaa aaaa        CALL   R, Rbase+offs6
assign offset_sign_ex = 
        is_long_jmp ? INSTR_IN[14] : INSTR_IN[10];
// using DATA_WIDTH instead of ADDR_WIDTH to simplify slicing
logic [DATA_WIDTH-1:0] offset_value; // fill more bits than needed, then take only useful part from it 
assign offset_value[5:0] = INSTR_IN[5:0];
assign offset_value[10:6] = base_addr_pc ? INSTR_IN[10:6] : 5'b00000; // fill with 0 for non-PC -- unsigned
assign offset_value[13:11] = base_addr_pc 
                ? (((instr_category == INSTR_JMP_WAIT) & base_addr_pc)   
                         ? INSTR_IN[10:6]                               // long PC address format
                         : {3{offset_sign_ex}})                         // short PC address: fill with sign
                :  3'b000; // fill with 0 for non-PC -- unsigned
// base for address calculation
logic [DATA_WIDTH-1:0] base_value; 
assign base_value = base_addr_pc ? { {DATA_WIDTH-PC_WIDTH{1'b0}}, PC_IN } 
                                 : { b_value };
// effective address for instruction (base + offset)
logic [ADDR_WIDTH-1:0] addr_value;
always_comb addr_value <= base_value[ADDR_WIDTH-1:0] + offset_value[ADDR_WIDTH-1:0];
assign ADDR_VALUE = addr_value;


//======================================================================
// Calculating dst_reg_index
// Should be 0 for instructions which don't want to write output value to register

assign dst_reg_index = (instr_category == INSTR_ALU) ? INSTR_IN[2:0] // for ALU it's located at unusual place
                     : (instr_category == INSTR_CALL || instr_category == INSTR_LOAD) ? INSTR_IN[14:12]
                     : 3'b000; // instruction doesn't write result to register
                      
//======================================================================
// Conditions for conditional jumps
logic [3:0] condition_code = (instr_category == INSTR_CONDJMP1 || instr_category == INSTR_CONDJMP2) 
                        ? INSTR_IN[15:12]
                        : 4'b0000;
logic condition_result;
always_comb case(condition_code)
    COND_NONE: condition_result <= 1'b1;              // 0000 jmp  1                 unconditional
    
    COND_NC:   condition_result <= ~FLAGS_IN[FLAG_C]; // 0001 jnc  c = 0
    COND_NZ:   condition_result <= ~FLAGS_IN[FLAG_Z]; // 0010 jnz  z = 0             jne
    COND_Z:    condition_result <=  FLAGS_IN[FLAG_Z]; // 0011 jz   z = 1             je

    COND_NS:   condition_result <= ~FLAGS_IN[FLAG_S]; // 0100 jns  s = 0
    COND_S:    condition_result <=  FLAGS_IN[FLAG_S]; // 0101 js   s = 1
    COND_NO:   condition_result <= ~FLAGS_IN[FLAG_V]; // 0100 jno  v = 0
    COND_O:    condition_result <=  FLAGS_IN[FLAG_V]; // 0101 jo   v = 1

    COND_A:    condition_result <= (~FLAGS_IN[FLAG_C] & ~FLAGS_IN[FLAG_Z]);    // 1000 ja   c = 0 & z = 0     above (unsigned compare)            !jbe
    COND_AE:   condition_result <= (~FLAGS_IN[FLAG_C] & FLAGS_IN[FLAG_Z]);     // 1001 jae  c = 0 | z = 1     above or equal (unsigned compare)
    COND_B:    condition_result <=  FLAGS_IN[FLAG_C];                          // 1010 jb   c = 1             below (unsigned compare)            jc
    COND_BE:   condition_result <= (FLAGS_IN[FLAG_C] | FLAGS_IN[FLAG_Z]);      // 1011 jbe  c = 1 | z = 1     below or equal (unsigned compare)   !ja

    COND_L:    condition_result <= (FLAGS_IN[FLAG_V] != FLAGS_IN[FLAG_S]);                     // 1100 jl   v != s            less (signed compare)
    COND_LE:   condition_result <= (FLAGS_IN[FLAG_V] != FLAGS_IN[FLAG_S]) | FLAGS_IN[FLAG_Z];  // 1101 jle  v != s | z = 1    less or equal (signed compare)      !jg
    COND_G:    condition_result <= (FLAGS_IN[FLAG_V] == FLAGS_IN[FLAG_S]) & ~FLAGS_IN[FLAG_Z]; // 1110 jg   v = s & z = 0     greater (signed compare)            !jle
    COND_GE:   condition_result <= (FLAGS_IN[FLAG_V] == FLAGS_IN[FLAG_S]) | FLAGS_IN[FLAG_Z];  // 1111 jge  v = s | z = 1     less or equal (signed compare)
endcase;

//======================================================================
// Types of operations
assign LOAD_EN   = (instr_category == INSTR_LOAD);
assign STORE_EN  = (instr_category == INSTR_STORE);
assign JMP_EN    = (instr_category[2] & ~is_wait) & condition_result;
assign WAIT_EN   =  is_wait;
assign PERIPH_EN = (instr_category == INSTR_PERIPH);
assign MEMORY_EN = (instr_category == INSTR_LOAD) | (instr_category == INSTR_STORE) | is_wait;
assign ALU_EN    = (instr_category == INSTR_ALU);


endmodule
