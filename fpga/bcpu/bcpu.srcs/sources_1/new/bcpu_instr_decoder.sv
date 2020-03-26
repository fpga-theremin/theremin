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
    // PC_WIDTH should match local program/data BRAM size
    parameter PC_WIDTH = 10,
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    parameter ADDR_WIDTH = 10,

    // register file address width, 3 + 2 == 8 registers * 4 threads
    parameter REG_ADDR_WIDTH = 5,  // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5
    
    // bus address width
    parameter BUS_ADDR_WIDTH = 4,
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    parameter BUS_OP_WIDTH = 3,
    
    // when 1, two bits from offset are used for immediate mode to allow using constant table value instead of register
    //         Reduces offset range from 8 to 6 bits, but allows simple addressing of address (1<<n)+(0..63)   
    parameter USE_IMM_MODE_FOR_BASE_ADDRESS = 1,
    // when 1, offset for R_imm+offs (non-PC) address formats is signed (+31..-32 or +127..-128), when 0 - unsigned offset
    parameter USE_SIGNED_REG_BASE_OFFSET = 1
)
(
    // CLOCK AND RESET
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,
    
    // INPUTS
    // instruction to decode - from program memory
    input logic [INSTR_WIDTH-1:0] INSTR_IN,
    // current program counter (address of this instruction)
    input logic [PC_WIDTH-1:0] PC_IN,
    // id of current thread in barrel CPU
    input logic [1:0] THREAD_ID,
    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,

    // ALU operation code (valid if ALU_EN==1)
    output logic [3:0] ALU_OP,
    
    output logic [1:0] IMM_MODE,

    // register A index, e.g. for ALU 
    output logic [2:0] A_INDEX,
    // register B or immediate index, e.g. for ALU 
    output logic [2:0] B_INDEX,

    // BUS operation code (valid if BUS_EN==1) (stage1)
    output logic [BUS_OP_WIDTH-1:0] BUS_OP,
    // BUS address (valid if BUS_EN==1) (stage1)
    output logic [BUS_ADDR_WIDTH-1:0] BUS_ADDR,

    // register A operand value, e.g. for ALU operand A, write data for memory, or mask for WAIT (stage0)
    output logic [DATA_WIDTH-1:0] A_VALUE,
    // register A operand value, delayed by 1 clk cycle (stage1)
    output logic [DATA_WIDTH-1:0] A_VALUE_STAGE1,
    // register B or immediate operand value, e.g. for ALU operand B (stage0)
    output logic [DATA_WIDTH-1:0] B_VALUE,
    // register B or immediate operand value, e.g. for ALU operand B (stage1)
    output logic [DATA_WIDTH-1:0] B_VALUE_STAGE1,

    // 1 to enable ALU operation
    output logic ALU_EN,
    // 1 if instruction is BUS operation (stage1)
    output logic BUS_EN,
    // 1 if instruction is LOAD or STORE operation (stage1)
    output logic MEM_EN,
    // 1 if instruction is STORE operation (stage1)
    output logic STORE_EN,
    // 1 if instruction is JUMP, CALL or conditional jump operation
    output logic JMP_EN,
    // 1 if instruction is CALL operation and we need to save return address
    output logic CALL_EN,

    // memory or jump address calculated as base+offset
    output logic [ADDR_WIDTH-1:0] ADDR_VALUE_STAGE1,

    // dest reg address, xx000 to disable writing
    output logic [REG_ADDR_WIDTH-1:0] DEST_REG_ADDR,
    // register bank write mux source index: REG_WRITE_FROM_ALU, _BUS, _MEM, _JMP (stage3)
    output logic [1:0] DEST_REG_SOURCE_STAGE3,

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
    

    00 1: Bus operations
    
    00 1 rrr i bbb mmii aaaa

        rrr  destination register for read operations
             write value register for write operation
        bbb  RB
        mm   RB mode (00=reg, 01=consts, 10,11: single bit)
		iii  BUS operation code
		aaaa BUS address
    
    
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
    
    11 1: Long jump
    
    11 1 aaa a aaa aaaa aaaa        JMP    PC+offs15                  JUMP PC+offs15
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

logic [1:0] dst_reg_source;
logic [1:0] dest_reg_source_stage1;
logic [1:0] dest_reg_source_stage2;
always_ff @(posedge CLK)
    if (RESET) begin
        DEST_REG_SOURCE_STAGE3 <= 'b0;
        dest_reg_source_stage2 <= 'b0;
        dest_reg_source_stage1 <= 'b0;
    end else if (CE) begin
        DEST_REG_SOURCE_STAGE3 <= dest_reg_source_stage2;
        dest_reg_source_stage2 <= dest_reg_source_stage1;
        dest_reg_source_stage1 <= dst_reg_source;
    end


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

always_ff @(posedge CLK) begin
    if (RESET) begin
        A_VALUE_STAGE1 <= 'b0;
        B_VALUE_STAGE1 <= 'b0;
    end else if (CE) begin
        A_VALUE_STAGE1 <= a_value;
        B_VALUE_STAGE1 <= b_value;
    end
end



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

logic is_long_jmp = (instr_category == INSTR_JMP);
assign base_addr_pc = INSTR_IN[11] | is_long_jmp;

// address offset sign extension value
logic offset_sign_ex;
// long PC based address:
//    11 1 aaa a aaa aaaa aaaa        JMP    PC+offs14                LONG JUMP PC+offs14
// short PC based address example:
//    01 1 rrr 1 aaa aaaa aaaa        STORE R, PC + offs11
// non-PC based address example:
//    11 0 rrr 0 bbb mmaa aaaa        CALL   R, Rbase+offs6
// using DATA_WIDTH instead of ADDR_WIDTH to simplify slicing

if (USE_SIGNED_REG_BASE_OFFSET == 1) begin
    assign offset_sign_ex = 
        is_long_jmp 
            ? INSTR_IN[14]         // for long jump 
            : (base_addr_pc 
                ? INSTR_IN[10]     // short PC based
                : ((USE_IMM_MODE_FOR_BASE_ADDRESS == 1) // short REG based -- unsigned extension, pad with 0
                   ? INSTR_IN[5]   // with imm mode field
                   : INSTR_IN[7])  // w/o imm mode field
              );
end else begin
    assign offset_sign_ex = 
        is_long_jmp 
            ? INSTR_IN[14]         // for long jump 
            : (base_addr_pc 
                ? INSTR_IN[10]     // short PC based
                : 1'b0             // short REG based -- unsigned extension, pad with 0
              );
end

logic [DATA_WIDTH-1:0] offset_value; // fill more bits than needed, then take only useful part from it
if (USE_IMM_MODE_FOR_BASE_ADDRESS == 1) begin
    // using IMM MODE code: we have 6 bits in first chunk
    assign offset_value[5:0] = INSTR_IN[5:0];
    assign offset_value[10:6] = (base_addr_pc | is_long_jmp) 
                              ? INSTR_IN[10:6]  // address field bits - RB and IMM position
                              : 5'b00000; // fill with 0 for non-PC -- unsigned
end else begin
    // no IMM MODE code: we have 8 bits in first chunk
    assign offset_value[7:0] = INSTR_IN[7:0];
    assign offset_value[10:8] = base_addr_pc
                              ? INSTR_IN[10:8]  // address field bits - RB position
                              : 3'b000;         // fill with 0 for non-PC -- unsigned
end
assign offset_value[14:11] = is_long_jmp   
                           ? INSTR_IN[14:11]         // long PC address format
                           : {4{offset_sign_ex}};    // short PC address: fill with sign
assign offset_value[DATA_WIDTH-1:15] = {DATA_WIDTH-15{ offset_sign_ex }}; 

// base for address calculation
logic [DATA_WIDTH-1:0] base_value; 
assign base_value = base_addr_pc 
                        ? { {DATA_WIDTH-PC_WIDTH{1'b0}}, PC_IN } // use PC as base 
                        : { // use REG value or REG+imm table override
                             (USE_IMM_MODE_FOR_BASE_ADDRESS == 1) 
                                 ? b_value        // imm mode enabled:  use output of immediate decoder which can replace register B value with constant 
                                 : RD_REG_DATA_B  // imm mode disabled: use register B value directly
                          };


//======================================================================
// Calculating dst_reg_index
// Should be 0 for instructions which don't want to write output value to register

assign dst_reg_index = (instr_category == INSTR_ALU) ? INSTR_IN[2:0] // for ALU it's located at unusual place
                     : (instr_category == INSTR_CALL || instr_category == INSTR_LOAD
                        || (instr_category == INSTR_BUS 
                              && ~INSTR_IN[11] // BUS read/wait instructions
                           )
                       ) ? INSTR_IN[14:12]
                     : 3'b000; // instruction doesn't write result to register
                      
//======================================================================
// Conditions for conditional jumps
logic [3:0] condition_code = INSTR_IN[15:12];
                        
logic jump_enabled;
logic condition_result_raw;

always_comb jump_enabled <= (instr_category == INSTR_CONDJMP1 || instr_category == INSTR_CONDJMP2)
                          ? condition_result_raw
                          : (instr_category == INSTR_JMP || instr_category == INSTR_CALL);

always_comb case(condition_code)
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

//======================================================================
// Types of operations
assign JMP_EN    = jump_enabled;
assign ALU_EN    = (instr_category == INSTR_ALU);
assign CALL_EN   = (instr_category == INSTR_CALL);

always_ff @(posedge CLK) begin
    if (RESET) begin
        BUS_EN    <= 'b0;
        MEM_EN    <= 'b0;
        STORE_EN  <= 'b0;
    end else if (CE) begin
        BUS_EN    <= (instr_category == INSTR_BUS);
        MEM_EN    <= (instr_category == INSTR_LOAD) | (instr_category == INSTR_STORE);
        STORE_EN  <= (instr_category == INSTR_STORE);
    end
end

always_comb case(instr_category)
        INSTR_ALU:      dst_reg_source <= REG_WRITE_FROM_ALU;
	    INSTR_BUS:      dst_reg_source <= REG_WRITE_FROM_BUS;
	    INSTR_LOAD:     dst_reg_source <= REG_WRITE_FROM_MEM;
	    INSTR_STORE:    dst_reg_source <= REG_WRITE_FROM_MEM;
        INSTR_CONDJMP1: dst_reg_source <= REG_WRITE_FROM_JMP;
        INSTR_CONDJMP2: dst_reg_source <= REG_WRITE_FROM_JMP;
        INSTR_CALL:     dst_reg_source <= REG_WRITE_FROM_JMP;
        INSTR_JMP:      dst_reg_source <= REG_WRITE_FROM_JMP;
    endcase

/*
    00 1: Bus operations
    
    00 1 rrr i bbb mmii aaaa

         rrr destination register for read operations
             write value register for write operation
        bbb RB
        mm  RB mode (00=reg, 01=consts, 10,11: single bit)
		iii  BUS operation code
		aaaa BUS address
*/
always_ff @(posedge CLK) begin
    if (RESET) begin
        BUS_ADDR  <= 'b0;
        BUS_OP    <= 'b0;
    end else if (CE) begin
        BUS_ADDR  <= INSTR_IN[3:0];
        BUS_OP    <= { INSTR_IN[11], INSTR_IN[5:4] };
    end
end

// memory or jump address calculated as base+offset
logic [ADDR_WIDTH-1:0] addr_base;
// memory or jump address calculated as base+offset
logic [ADDR_WIDTH-1:0] addr_offset;
always_ff @(posedge CLK) begin
    if (RESET) begin
        addr_base <= 'b0;
        addr_offset <= 'b0;
    end else if (CE) begin
        addr_base <= base_value[ADDR_WIDTH-1:0];
        addr_offset <= offset_value[ADDR_WIDTH-1:0];
    end
end

// effective address for instruction (base + offset)
logic [ADDR_WIDTH-1:0] addr_value;
always_comb addr_value <= addr_base + addr_offset;

assign ADDR_VALUE_STAGE1 = addr_value;



endmodule
