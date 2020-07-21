`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2020 09:55:32 AM
// Design Name: 
// Module Name: bcpu_breg_consts
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


module bcpu_breg_consts
#(
    parameter DATA_WIDTH = 16
)
(
    // input register value
    input logic [DATA_WIDTH - 1 : 0] B_VALUE_IN,
    // B register index from instruction - used as const index when CONST_MODE==1 
    input logic [2:0] B_REG_INDEX, 
    // const_mode - when 00 return B_VALUE_IN, when 01,10,11 return one of 24 consts from table 
    input logic [1:0] CONST_MODE,
    // output value: CONST_MODE?(1<<B_REG_INDEX):B_VALUE_IN    
    output logic [DATA_WIDTH - 1 : 0] B_VALUE_OUT
);

always_comb
    case ({CONST_MODE, B_REG_INDEX})
    // pass register value as is to output
    5'b00_000: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_001: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_010: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_011: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_100: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_101: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_110: B_VALUE_OUT <= B_VALUE_IN;
    5'b00_111: B_VALUE_OUT <= B_VALUE_IN;
    // small constants (non-power of 2)
    5'b01_000: B_VALUE_OUT <= 16'b00000000_00000011;  // 3
    5'b01_001: B_VALUE_OUT <= 16'b00000000_00000101;  // 5
    5'b01_010: B_VALUE_OUT <= 16'b00000000_00000110;  // 6
    5'b01_011: B_VALUE_OUT <= 16'b00000000_00000111;  // 7
    // useful masks
    5'b01_100: B_VALUE_OUT <= 16'b00000000_00001111;  // 15
    5'b01_101: B_VALUE_OUT <= 16'b00000000_11111111;  // 255
    5'b01_110: B_VALUE_OUT <= 16'b11111111_00000000;  // 0xff00
    // all bits set
    5'b01_111: B_VALUE_OUT <= 16'b11111111_11111111;  // 0xffff
    // single bit set (powers of 2)
    5'b10_000: B_VALUE_OUT <= 16'b00000000_00000001;  // 1<<0
    5'b10_001: B_VALUE_OUT <= 16'b00000000_00000010;  // 1<<1
    5'b10_010: B_VALUE_OUT <= 16'b00000000_00000100;  // 1<<2
    5'b10_011: B_VALUE_OUT <= 16'b00000000_00001000;  // 1<<3
    5'b10_100: B_VALUE_OUT <= 16'b00000000_00010000;  // 1<<4
    5'b10_101: B_VALUE_OUT <= 16'b00000000_00100000;  // 1<<5
    5'b10_110: B_VALUE_OUT <= 16'b00000000_01000000;  // 1<<6
    5'b10_111: B_VALUE_OUT <= 16'b00000000_10000000;  // 1<<7
    5'b11_000: B_VALUE_OUT <= 16'b00000001_00000000;  // 1<<8
    5'b11_001: B_VALUE_OUT <= 16'b00000010_00000000;  // 1<<9
    5'b11_010: B_VALUE_OUT <= 16'b00000100_00000000;  // 1<<10
    5'b11_011: B_VALUE_OUT <= 16'b00001000_00000000;  // 1<<11
    5'b11_100: B_VALUE_OUT <= 16'b00010000_00000000;  // 1<<12
    5'b11_101: B_VALUE_OUT <= 16'b00100000_00000000;  // 1<<13
    5'b11_110: B_VALUE_OUT <= 16'b01000000_00000000;  // 1<<14
    5'b11_111: B_VALUE_OUT <= 16'b10000000_00000000;  // 1<<15
    endcase
    
//always_comb
//    for (int i = 0; i < 16; i++)
//        B_VALUE_OUT[i] <= CONST_MODE ? ((B_REG_INDEX==i) ? 1'b1 : 1'b0) : B_VALUE_IN[i];

endmodule
