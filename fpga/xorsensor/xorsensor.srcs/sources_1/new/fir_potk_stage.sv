`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2020 06:11:19 PM
// Design Name: 
// Module Name: fir_potk_stage
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


module fir_potk_stage
#(
    parameter IN_BITS = 6,
    parameter OUT_BITS = 12,
    parameter INTERNAL_BITS = 16,
    parameter SHIFT_BITS = 4
)
(
    // 150MHz 
    input logic CLK,
    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,

    input logic [IN_BITS-1:0] IN_VALUE,    
    output logic [OUT_BITS-1:0] OUT_VALUE    
);

logic [INTERNAL_BITS-1:0] state_reg;


// state = state + (in - state) >> shift

logic signed [INTERNAL_BITS - 1 : 0] in_less_state;
always_comb in_less_state <= ({IN_VALUE, {INTERNAL_BITS-IN_BITS{1'b0}} } >> SHIFT_BITS) - (state_reg >>> SHIFT_BITS);

always_ff @(posedge CLK) begin
    if (RESET) begin
        state_reg <= 'b0;
    end else begin
        state_reg <= state_reg + in_less_state;
    end
end

always_comb OUT_VALUE <= state_reg[INTERNAL_BITS-1:INTERNAL_BITS-OUT_BITS];

endmodule
