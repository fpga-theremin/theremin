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
//  mnemonic             opcode   upd CV ZS    opmode          alumode
	ALUOP_ADD        = 4'b0000, //     1 1     011_00_11       0000
	ALUOP_ADDC       = 4'b0001, //     1 1     011_00_11       0000
	ALUOP_SUB        = 4'b0010, //     0 1     011_00_11       0000
	ALUOP_SUBC       = 4'b0011, //     0 0     000_01_01       0000
	
	ALUOP_INC        = 4'b0100, //     1 1     011_00_11       0011
	ALUOP_DEC        = 4'b0101, //     1 1     011_00_11       0011
	ALUOP_ROTATE     = 4'b0110, //     0 1     011_00_11       0011
	ALUOP_ROTATEC    = 4'b0111, //     1 1     011_00_11       0001
	
	ALUOP_AND        = 4'b1000, //     0 1     011_00_11       1100
	ALUOP_ANDN       = 4'b1001, //     0 1     011_10_11       1111
	ALUOP_OR         = 4'b1010, //     0 1     011_10_11       1100
	ALUOP_XOR        = 4'b1011, //     0 1     011_10_11       0101
	
	ALUOP_MULL       = 4'b1100, //     0 0     000_00_00       0000
	ALUOP_MULHUU     = 4'b1101, //     0 0     000_00_00       0000
	ALUOP_MULHSS     = 4'b1110, //     0 0     000_00_00       0000
	ALUOP_MULHSU     = 4'b1111  //     0 0     000_00_00       0000
} aluop_t;

typedef enum logic[1:0] {
    FLAG_C,
    FLAG_Z,
    FLAG_S,
    FLAG_V
} flag_index_t;
typedef logic[3:0] bcpu_flags_t;


endpackage
