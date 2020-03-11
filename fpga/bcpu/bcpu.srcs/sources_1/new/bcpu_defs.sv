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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package bcpu_defs;

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

typedef enum logic[1:0] {
    FLAG_C,        // carry flag
    FLAG_Z,        // zero flag
    FLAG_S,        // sign flag
    FLAG_V         // overflow flag
} flag_index_t;
typedef logic[3:0] bcpu_flags_t;

/*
Instruction set planning:

18 bit instructions

01: load and store

01 0rrr 0bbb aaaa aaaa        LOAD R, Rbase + offs8
01 0rrr 1aaa aaaa aaaa        LOAD R, PC + offs11
01 1rrr 0bbb aaaa aaaa        STORE R, Rbase + offs8
01 1rrr 1aaa aaaa aaaa        STORE R, PC + offs11

10: conditional jumps

10 cccc 0bbb xxxx xxxx        JMP   Cond1, Rbase+offs8          cond jumps to reg, cond returns, returns, 
10 cccc 1xxx xxxx xxxx        JMP   Cond1, PC+offs11            cond and uncond relative jumps

11 0: calls
11 0rrr 0bbb xxxx xxxx        CALL   R, Rbase+offs8
11 0rrr 1xxx xxxx xxxx        CALL   R, PC + offs11     
11 0: jumps
11 1??? 0bbb xxxx xxxx        JMP    ???, Rbase+offs8           reserved? put wait here? 
11 1xxx 1xxx xxxx xxxx        JMP    Cond0, PC+offs14           LONG JUMP


Condition codes:

???? jmp  no condition, use 0000?


0000 jnc  c = 0
0001 jc   c = 1             jb
0010 jnz  z = 0             jne
0011 jz   z = 1             je

0100 jns  s = 0
0101 js   s = 1
0100 jno  v = 0
0101 jo   v = 1

1000 ja   c = 0 & z = 0     above (unsigned compare)            !jbe
1001 jae  c = 0 | z = 1     above or equal (unsigned compare)
1010 jb   c = 1             below (unsigned compare)
1011 jbe  c = 1 | z = 1     below or equal (unsigned compare)   !ja

1100 jl   v != s            less (signed compare)
1101 jle  v != s | z = 1    less or equal (signed compare)      !jg
1110 jg   v = s & z = 0     greater (signed compare)            !jle
1111 jge  v = s | z = 1     less or equal (signed compare)



*/


endpackage
