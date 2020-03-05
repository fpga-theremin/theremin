`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2020 10:55:59 AM
// Design Name: 
// Module Name: iir_filter_pow2k_1stage_pipeline
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


module iir_filter_pow2k_1stage_pipeline
#(
    parameter K_SHIFT_BITS = 8,
    parameter VALUE_BITS = 32,
    parameter USE_INPUT_REG = 1,
    parameter USE_OUTPUT_REG = 1
)
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // 1 to enable processing, 0 to force output
    input logic EN,
    
    // filter input value1
    input logic [VALUE_BITS-1 : 0] IN_VALUE1,
    // filter input value2
    input logic [VALUE_BITS-1 : 0] IN_VALUE2,
    // previous state
    input logic [VALUE_BITS-1 : 0] IN_STATE,
    
    // 0: use IN_VALUE, 1: use pervious value from OUT_STATE
    input logic IN_VALUE_MUX,
    // 0: use IN_VALUE1, 1: use IN_VALUE2
    input logic IN_VALUE_ADDR,

    // new state (filter output)
    output logic [VALUE_BITS-1 : 0] OUT_STATE 
);

logic en_delay1;
always_ff @(posedge CLK) begin
    if (RESET)
        en_delay1 <= 'b0;
    else
        en_delay1 <= EN;
end

logic [VALUE_BITS-1 : 0] result;
logic [VALUE_BITS-1 : 0] result_top_bits;


logic [VALUE_BITS-1 : 0] in_value_muxed;

always_comb in_value_muxed <= (IN_VALUE_ADDR ? IN_VALUE2 : IN_VALUE1);

logic [VALUE_BITS-1 : 0] in_diff;
always_comb in_diff <= (IN_VALUE_MUX ? result : in_value_muxed) - IN_STATE;

logic [VALUE_BITS-1 : 0] in_state_buf;
logic [VALUE_BITS-1 : 0] in_diff_buf;


generate

    if (USE_INPUT_REG == 1) begin
        always_ff @(posedge CLK) begin
            if (RESET | ~EN) begin
                in_state_buf <= 'b0;
                in_diff_buf <= 'b0;
            end else begin
                in_state_buf <= IN_STATE;
                in_diff_buf <= in_diff;
            end
        end
    end else begin
        always_comb in_state_buf <= IN_STATE;
        always_comb in_diff_buf <= in_diff;
    end
    
    if (USE_OUTPUT_REG == 1) begin
        always_ff @(posedge CLK) begin
            if (RESET | ~en_delay1)
                result <= 'b0;
            else
                result <= in_state_buf + in_diff_buf[VALUE_BITS-1 : K_SHIFT_BITS];
        end
    end else begin
        always_comb result <= in_state_buf + in_diff_buf[VALUE_BITS-1 : K_SHIFT_BITS];
    end
endgenerate


always_comb OUT_STATE <= result;

endmodule
