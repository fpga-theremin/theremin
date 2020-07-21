`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2020 03:54:27 PM
// Design Name: 
// Module Name: bcpu_addr_adder
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


module bcpu_addr_adder
#(
    // address width
    parameter ADDR_WIDTH = 10
)
(
    input logic [ADDR_WIDTH-1:0] RB_IN,
    input logic [ADDR_WIDTH-1:0] PC_IN,
    // offset 11 bits, for MODE=0 top 3 bits should be zeroed
    input logic [10:0] OFFSET_IN,
    input logic MODE,
    output logic [ADDR_WIDTH-1:0] ADDR_OUT
);

logic signed [10:0] offset;
always_comb offset <= { 
                                  OFFSET_IN[7:0],
                                  MODE 
                                  ? OFFSET_IN[10:8]      // bits as is 
                                  : {3{OFFSET_IN[7]}}
                                };   // sign extension


//logic [ADDR_WIDTH-1:0] base;
//always_comb base <= MODE ? PC_IN : RB_IN;

logic signed [ADDR_WIDTH-1:0] addr;
always_comb addr <= (MODE ? PC_IN : RB_IN) + offset + MODE;

assign ADDR_OUT = addr;

endmodule
