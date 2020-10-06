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
	INSTR_ALU        = 3'b000,  //   ALU instructions (16)
	INSTR_BUSREAD    = 3'b001,  //   BUS read instructions (4)
	INSTR_BUSWRITE   = 3'b010,  //   BUS write instructions (4)
	INSTR_LOAD       = 3'b011,  //   LOAD - memory reads
	INSTR_STORE      = 3'b100,  //   STORE - memory writes
	INSTR_CALL       = 3'b101,  //   CALL - jumps with storing return address into register
	INSTR_JMPC0      = 3'b110,  //   conditoinal jumps part 1   
	INSTR_JMPC1      = 3'b111   //   conditional jumps part 2
} instr_category_t;

// Types of memory address bases
typedef enum logic {
//  mnemonic             opcode      
	BASEADDR_REG     = 1'b0,    //   Reg or simple immediate const is used as base address (R+offs)
	BASEADDR_PC      = 1'b1     //   PC (program counter) is used as base address          (PC+offs)
} base_address_t;

// Register write MUX control - source indexes
typedef enum logic [1:0] {
    // name                 index      
	REG_WRITE_FROM_ALU  = 2'b00,    //   Write to register from ALU
	REG_WRITE_FROM_BUS  = 2'b01,    //   Write to register from BUS
	REG_WRITE_FROM_MEM  = 2'b10,    //   Write to register from MEM
	REG_WRITE_FROM_JMP  = 2'b11     //   Write to register from JMP
} reg_write_source_t;

// ALU opcodes
typedef enum logic[3:0] {
//  mnemonic             opcode                                                   flags      mapped
	ALUOP_INCNF      = 4'b0000, //   RC = RA + RB                                 ....       MOV, NOP
	ALUOP_DECNF      = 4'b0001, //   RC = RA - RB                                 ....
	ALUOP_INC        = 4'b0010, //   RC = RA + RB                                 .SZ.
	ALUOP_DEC        = 4'b0011, //   RC = RA - RB                                 .SZ.

	ALUOP_ADD        = 4'b0100, //   RC = RA + RB                                 VSZC
	ALUOP_SUB        = 4'b0101, //   RC = RA - RB                                 VSZC       CMP
	ALUOP_ADDC       = 4'b0110, //   RC = RA + RB + CF                            VSZC
	ALUOP_SUBC       = 4'b0111, //   RC = RA - RB - CF                            VSZC       CMPC
	
	ALUOP_AND        = 4'b1000, //   RC = RA & RB                                 .SZ.
	ALUOP_XOR        = 4'b1001, //   RC = RA ^ RB                                 .SZ.
	ALUOP_OR         = 4'b1010, //   RC = RA | RB                                 .SZ.
	ALUOP_ANDN       = 4'b1011, //   RC = RA & ~RB                                .SZ.
	
	ALUOP_MUL        = 4'b1100, //   RC = low(RA * RB)                            .SZ.       SHL, SAL
	ALUOP_MULHUU     = 4'b1101, //   RC = high(unsigned RA * unsigned RB)         .SZ.       SHR
	ALUOP_MULHSS     = 4'b1110, //   RC = high(signed RA * signed RB)             .SZ.
	ALUOP_MULHSU     = 4'b1111  //   RC = high(signed RA * unsigned RB)           .SZ.       SAR
} aluop_t;


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


// BUS operation codes (operands: RB_imm is mask, RA is destination register for result)
typedef enum logic[1:0] {
    BUSOP_IBUSREAD         = 2'b00, //  Rdest = (IBUS[addr] & mask),  update ZF
    BUSOP_IBUSWAIT0        = 2'b01, //  Rdest = (IBUS[addr] & mask),  update ZF, wait until ZF=1
    BUSOP_IBUSWAIT1        = 2'b10, //  Rdest = (IBUS[addr] & mask),  update ZF, wait until ZF=0
    BUSOP_RESERVED         = 2'b11  //  reserved 
} bus_rd_op_t;

// BUS operation codes (operands: RB_imm is mask, RA is destination register for result)
typedef enum logic[1:0] {
    BUSOP_OBUSWRITE        = 2'b00, //  OBUS[addr] = (OBUS[addr] & ~mask) | (Rsrc & mask)
    BUSOP_OBUSSET          = 2'b01, //  OBUS[addr] = OBUS[addr] | mask
    BUSOP_OBUSRESET        = 2'b10, //  OBUS[addr] = OBUS[addr] & ~mask
    BUSOP_OBUSINVERT       = 2'b11  //  OBUS[addr] = OBUS[addr] ^ mask
} bus_wr_op_t;


endpackage
