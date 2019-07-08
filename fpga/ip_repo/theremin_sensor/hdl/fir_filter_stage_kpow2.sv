`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 03:20:17 PM
// Design Name: 
// Module Name: fir_filter_stage_kpow2
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


module fir_filter_stage_kpow2
#(
    parameter FILTER_K_SHIFT = 8,
    parameter DATA_BITS = 32
)
(
    input CLK,
    input RESET,
    input PHASE,
    
    input logic [DATA_BITS-1:0] IN_VALUE,
    output logic [DATA_BITS-1:0] OUT_VALUE
    
);

localparam INTERNAL_BITS = FILTER_K_SHIFT + DATA_BITS;

logic signed [INTERNAL_BITS - 1:0] diff_reg;
logic signed [INTERNAL_BITS - 1:0] out_reg;

logic signed [INTERNAL_BITS - 1:0] diff_shifted;

always_comb diff_shifted <= { 
    {FILTER_K_SHIFT{diff_reg[INTERNAL_BITS - 1]}}, // top FILTER_K_SHIFT bits are sign extended
    diff_reg[INTERNAL_BITS - 1 : FILTER_K_SHIFT]     
}; 

/*
    out = prev_out * (1 - K) + in * K
    out = prev_out - prev_out * K + in * K
    out = prev_out + K (in - prev_out)
*/
always_ff @(posedge CLK) begin
    if (RESET) begin
        out_reg <= 0; //{IN_VALUE, {FILTER_K_SHIFT{1'b0}}};
        diff_reg <= 'b0;
    end else begin
        if (~PHASE) begin
            diff_reg <= {IN_VALUE, {FILTER_K_SHIFT{1'b0}}} - out_reg;
        end
        if (PHASE) begin
            out_reg <= out_reg + diff_shifted;
        end        
    end
end

always_comb OUT_VALUE <= out_reg[FILTER_K_SHIFT + DATA_BITS - 1 : FILTER_K_SHIFT];

endmodule
