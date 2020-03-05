`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2020 09:45:17 AM
// Design Name: 
// Module Name: iir_filter_dsp_1stage
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


module iir_filter_dsp_1stage
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // fixed point 16 bit value (fractional part only) of filter K
    input logic [15 : 0] FILTER_K,
    
    // filter input value
    input logic [31 : 0] IN_VALUE,
    // previous state
    input logic [31 : 0] IN_STATE,

    // new state (filter output)
    output logic [31 : 0] OUT_STATE 
);

logic [24:0] in_value_top_bits;
logic [24:0] in_state_top_bits;
always_comb in_value_top_bits <= {0, IN_VALUE[ 31 : 8 ]};
always_comb in_state_top_bits <= {0, IN_STATE[ 31 : 8 ]};


// input value registers
// B (multiplier) register
logic signed [16 : 0] filter_k_b;
// AD (preadder) register
logic signed [24 : 0] diff;
// C register
logic [47:0] in_value_scaled;
// register + preadder logic
always_ff @(posedge CLK) begin
    if (RESET) begin
        filter_k_b <= 'b0;
        diff <= 'b0;
        in_value_scaled <= 'b0;
    end else begin
        filter_k_b <= {1'b0, FILTER_K};
        diff <= in_value_top_bits - in_state_top_bits;
        in_value_scaled <= {IN_VALUE, 16'b0};
    end
end

logic [47:0] out_value_scaled;
always_comb out_value_scaled <= in_value_scaled + (diff * filter_k_b);

always_comb OUT_STATE <= out_value_scaled[47:16];

endmodule
