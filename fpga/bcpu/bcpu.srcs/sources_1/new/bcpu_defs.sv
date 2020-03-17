`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2019 03:40:39 PM
// Design Name: 
// Module Name: bcpu_defs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     Various definitions for BCPU FPGA Barrel CPU softcore implementation.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package bcpu_defs;

typedef enum logic[2:0] {
//  mnemonic             opcode      
	INSTR_ALU        = 3'b000,  //   ALU operation
	INSTR_BUS        = 3'b001,  //   Peripherial operations: read, write, wait
	INSTR_LOAD       = 3'b010,  //   LOAD - memory reads
	INSTR_STORE      = 3'b011,  //   STORE - memory writes
	INSTR_CONDJMP1   = 3'b100,  //   conditional jumps, part 1
	INSTR_CONDJMP2   = 3'b101,  //   conditional jumps, part 2
	INSTR_CALL       = 3'b110,  //   CALL - jumps with storing return address into register
	INSTR_JMP        = 3'b111   //   JMP with long offset
} instr_category_t;

// Types of memory address bases
typedef enum logic {
//  mnemonic             opcode      
	BASEADDR_REG     = 1'b0,    //   Reg or simple immediate const is used as base address (R+offs)
	BASEADDR_PC      = 1'b1     //   PC (program counter) is used as base address          (PC+offs)
} base_address_t;

// ALU opcodes
typedef enum logic[3:0] {
//  mnemonic             opcode                                                   flags      mapped
	ALUOP_INC        = 4'b0000, //   RC = RA + RB                                 .SZ.       MOV, NOP
	ALUOP_DEC        = 4'b0001, //   RC = RA - RB                                 .SZ.
	ALUOP_ROTATE     = 4'b0010, //   RC = high_low(unsigned RA * unsigned RB)     .SZc       ROL, ROR
	ALUOP_ROTATEC    = 4'b0011, //   RC = high_low(unsigned RA * unsigned RB)|CF  .SZc       RCL, RCR

	ALUOP_ADD        = 4'b0100, //   RC = RA + RB                                 VSZC
	ALUOP_SUB        = 4'b0101, //   RC = RA - RB                                 VSZC       CMP
	ALUOP_ADDC       = 4'b0110, //   RC = RA + RB + CF                            VSZC
	ALUOP_SUBC       = 4'b0111, //   RC = RA - RB - CF                            VSZC       CMPC
	
	ALUOP_AND        = 4'b1000, //   RC = RA & RB                                 .SZ.
	ALUOP_ANDN       = 4'b1001, //   RC = RA & ~RB                                .SZ.
	ALUOP_OR         = 4'b1010, //   RC = RA | RB                                 .SZ.
	ALUOP_XOR        = 4'b1011, //   RC = RA ^ RB                                 .SZ.
	
	ALUOP_MUL        = 4'b1100, //   RC = low(RA * RB)                            .SZc       SHL, SAL
	ALUOP_MULHUU     = 4'b1101, //   RC = high(unsigned RA * unsigned RB)         .SZc       SHR
	ALUOP_MULHSS     = 4'b1110, //   RC = high(signed RA * signed RB)             .SZc
	ALUOP_MULHSU     = 4'b1111  //   RC = high(signed RA * unsigned RB)           .SZc       SAR
} aluop_t;

/*
    Additional ops mapping
    alias op                 mapped to                   behavior change comparing to original op    
    NOP                  <=  INC R0, R0, 0               -- disable ALL flags update
    MOV RC, RB           <=  INC RC, R0, RB              -- disable ALL flags update
    TEST RA, RB          <=  AND R0, RA, RB              -- only flags updated
    CMP RA, RB           <=  SUB R0, RA, RB              -- only flags updated
    CMPC RA, RB          <=  SUBC R0, RA, RB             -- only flags updated
    SHL RC, RA, n        <=  MUL RC, RA, (1<<n)          -- enable C flag, CF=p[16]
    SAL RC, RA, n        <=  MUL RC, RA, (1<<n)          -- enable C flag, CF=p[16]
    SHR RC, RA, n        <=  MULUU RC, RA, (1<<(16-n))   -- enable C flag, CF=p[15]
    SAR RC, RA, n        <=  MULSU RC, RA, (1<<(16-n))   -- enable C flag, CF=p[15]
    ROL RC, RA, n        <=  ROTATE RC, RA, (1<<n)       -- enable C flag, CF=p[16]
    RCL RC, RA, n        <=  ROTATE RC, RA, (1<<n)       -- enable C flag, CF=p[16], result[0]=CF_in
    ROR RC, RA, n        <=  ROTATE RC, RA, (1<<(16-n))  -- enable C flag, CF=p[15]
    RCR RC, RA, n        <=  ROTATE RC, RA, (1<<(16-n))  -- enable C flag, CF=p[15], result[15]=CF_in
*/

// flag indexes
typedef enum logic[1:0] {
    FLAG_C,        // carry flag, 1 when there is carry out or borrow from ADD/SUB, or shifted out bit for shifts
    FLAG_Z,        // zero flag, set to 1 when all bits of result are zeroes
    FLAG_S,        // sign flag, meaningful for signed operations (usually derived from HSB of result, sign bit)
    FLAG_V         // signed overflow flag, meaningful for signed arithmetic operations
} flag_index_t;
typedef logic[3:0] bcpu_flags_t;

// condition codes for conditional jumps
typedef enum logic[3:0] {
    COND_NONE = 4'b0000, // jmp  1                 unconditional
    
    COND_NC   = 4'b0001, // jnc  c = 0             for C==1 test, use JB code
    COND_NZ   = 4'b0010, // jnz  z = 0             jne                                        !=
    COND_Z    = 4'b0011, // jz   z = 1             je                                         ==

    COND_NS   = 4'b0100, // jns  s = 0
    COND_S    = 4'b0101, // js   s = 1
    COND_NO   = 4'b0110, // jno  v = 0
    COND_O    = 4'b0111, // jo   v = 1

    COND_A    = 4'b1000, // ja   c = 0 & z = 0     above (unsigned compare)            !jbe    >
    COND_AE   = 4'b1001, // jae  c = 0 | z = 1     above or equal (unsigned compare)           >=
    COND_B    = 4'b1010, // jb   c = 1             below (unsigned compare)            jc      <
    COND_BE   = 4'b1011, // jbe  c = 1 | z = 1     below or equal (unsigned compare)   !ja     <=

    COND_L    = 4'b1100, // jl   v != s            less (signed compare)                       <
    COND_LE   = 4'b1101, // jle  v != s | z = 1    less or equal (signed compare)      !jg     <=
    COND_G    = 4'b1110, // jg   v = s & z = 0     greater (signed compare)            !jle    >
    COND_GE   = 4'b1111  // jge  v = s | z = 1     less or equal (signed compare)              >=
} jmp_condition_t;


// BUS operation codes (operands: RB_imm is mask, RA is value to write)
typedef enum logic[2:0] {
    BUSOP_READ_IBUS        = 3'b000, //  Rdest = (IBUS[addr] & mask),  update ZF
    BUSOP_WAIT_IBUS        = 3'b001, //  Rdest = (IBUS[addr] & mask),  update ZF, wait until ZF=0
    BUSOP_READ_OBUS        = 3'b010, //  Rdest = (OBUS[addr] & mask),  update ZF
    BUSOP_WAIT_OBUS        = 3'b011, //  Rdest = (OBUS[addr] & mask),  update ZF, wait until ZF=0
    BUSOP_TOGGLE_OBUS      = 3'b100, //  OBUS'[addr] =  OBUS[addr] ^ mask, Rdest = (OBUS[addr] & mask) -- read new value
    BUSOP_SET_OBUS         = 3'b101, //  OBUS'[addr] =  OBUS[addr] | mask, Rdest = (OBUS[addr] & mask) -- read new value
    BUSOP_RESET_OBUS       = 3'b110, //  OBUS'[addr] =  OBUS[addr] & ~mask, Rdest = (OBUS[addr] & mask) -- read new value
    BUSOP_WRITE_OBUS       = 3'b111  //  OBUS'[addr] = (OBUS[addr] & ~mask) | (value & mask)
} bus_op_t;

/*
Instruction set planning:

18 bit instructions

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

    cccc : condition, see table below
    
11 0: Calls

11 0 rrr 0 bbb mmaa aaaa        CALL   R, Rbase+offs6
11 0 rrr 1 aaa aaaa aaaa        CALL   R, PC + offs11     

11 1: WAIT and log jump

11 1: Long jump

11 1 aaa a aaa aaaa aaaa        JMP    PC+offs15                  JUMP PC+offs15

*/


endpackage
