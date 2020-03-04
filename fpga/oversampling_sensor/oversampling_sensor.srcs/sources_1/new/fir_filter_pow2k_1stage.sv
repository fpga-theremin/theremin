`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2020 04:45:23 PM
// Design Name: 
// Module Name: fir_filter_pow2k_1stage
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


module fir_filter_pow2k_1stage
#(
    parameter VALUE_BITS = 32,
    parameter FILTER_K_SHIFT_BITS = 8
)
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // filter input value
    input logic [VALUE_BITS-1 : 0] IN_VALUE,
    // filter output value
    output logic [VALUE_BITS-1 : 0] OUT_VALUE 
);

localparam INTERNAL_BITS = VALUE_BITS + FILTER_K_SHIFT_BITS;

logic [INTERNAL_BITS - 1 : 0] state;
always_comb OUT_VALUE <= state[INTERNAL_BITS - 1 : FILTER_K_SHIFT_BITS];

logic signed [VALUE_BITS - 1 : 0] diff;

always_comb diff <= IN_VALUE - state[INTERNAL_BITS - 1 : FILTER_K_SHIFT_BITS];
logic [INTERNAL_BITS - 1 : 0] new_state;
// sign extended
always_comb new_state <= state + { {FILTER_K_SHIFT_BITS{diff[VALUE_BITS - 1]}}, diff };

always_ff @(posedge CLK) begin
    if (RESET) begin
        state <= 'b0;
    end else begin
        state <= new_state;
    end
end 

endmodule
