`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2020 09:26:05 AM
// Design Name: 
// Module Name: bcpu_addr_adders
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


module bcpu_addr_adders
#(
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    parameter ADDR_WIDTH = 12
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // adder 1 input A
    input logic [ADDR_WIDTH-1:0] IN_A_1,
    // adder 1 input B
    input logic [ADDR_WIDTH-1:0] IN_B_1,
    // adder 1 output
    output logic [ADDR_WIDTH-1:0] OUT_1,

    // adder 2 input A
    input logic [ADDR_WIDTH-1:0] IN_A_2,
    // adder 2 input B
    input logic [ADDR_WIDTH-1:0] IN_B_2,
    // adder 2 output
    output logic [ADDR_WIDTH-1:0] OUT_2,

    // adder 3 input A
    input logic [ADDR_WIDTH-1:0] IN_A_3,
    // adder 3 input B
    input logic [ADDR_WIDTH-1:0] IN_B_3,
    // adder 3 output
    output logic [ADDR_WIDTH-1:0] OUT_3
);

localparam BIG_ADDER_WIDTH = (ADDR_WIDTH + 1) * 3; 

logic [BIG_ADDER_WIDTH-1:0] adder_a;
logic [BIG_ADDER_WIDTH-1:0] adder_b;
(* use_dsp="yes" *)
logic [BIG_ADDER_WIDTH-1:0] adder_out;

assign adder_a = { 1'b0, IN_A_3, 1'b0, IN_A_2,  1'b0, IN_A_1 }; 
assign adder_b = { 1'b0, IN_B_3, 1'b0, IN_B_2,  1'b0, IN_B_1 }; 
assign OUT_1 = adder_out[ADDR_WIDTH-1:0];
assign OUT_2 = adder_out[(ADDR_WIDTH+1)*2 - 1:(ADDR_WIDTH+1)*1];
assign OUT_3 = adder_out[(ADDR_WIDTH+1)*3 - 1:(ADDR_WIDTH+1)*2];

always_ff @(posedge CLK)
    if (RESET) begin
        adder_out <= 'b0;
    end else if (CE) begin
        adder_out <= adder_a + adder_b;
    end

endmodule
