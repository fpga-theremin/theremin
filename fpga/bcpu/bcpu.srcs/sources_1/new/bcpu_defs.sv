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
	ALUOP_ADD        = 4'b0000, //   RC = RA + RB                                 VSZC
	ALUOP_ADDC       = 4'b0001, //   RC = RA + RB + CF                            VSZC
	ALUOP_SUB        = 4'b0010, //   RC = RA - RB                                 VSZC
	ALUOP_SUBC       = 4'b0011, //   RC = RA - RB - CF                            VSZC
	
	ALUOP_INC        = 4'b0100, //   RC = RA + RB                                  SZ        MOV
	ALUOP_DEC        = 4'b0101, //   RC = RA - RB                                  SZ
	ALUOP_ROTATE     = 4'b0110, //   RC = high_low(unsigned RA * unsigned RB)      SZC       ROL, ROR
	ALUOP_ROTATEC    = 4'b0111, //   RC = high_low(unsigned RA * unsigned RB)|CF   SZC       RCL, RCR
	
	ALUOP_AND        = 4'b1000, //   RC = RA & RB                                  SZ
	ALUOP_ANDN       = 4'b1001, //   RC = RA & ~RB                                 SZ
	ALUOP_OR         = 4'b1010, //   RC = RA | RB                                  SZ
	ALUOP_XOR        = 4'b1011, //   RC = RA ^ RB                                  SZ
	
	ALUOP_MULL       = 4'b1100, //   RC = low(RA * RB)                             SZ        SHL, SAL
	ALUOP_MULHUU     = 4'b1101, //   RC = high(unsigned RA * unsigned RB)          SZ        SHR
	ALUOP_MULHSS     = 4'b1110, //   RC = high(signed RA * signed RB)              SZ
	ALUOP_MULHSU     = 4'b1111  //   RC = high(signed RA * unsigned RB)            SZ        SAR
} aluop_t;

typedef enum logic[1:0] {
    FLAG_C,        // carry flag
    FLAG_Z,        // zero flag
    FLAG_S,        // sign flag
    FLAG_V         // overflow flag
} flag_index_t;
typedef logic[3:0] bcpu_flags_t;


endpackage
