`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    int_uint_divider implements signed integer A by unsigned integer B divider.
    Top bit of result is sign, the rest - fractional part (requires abs(A) < B ).
    Result is delayed by RESULT_BITS CLK cycles.   
    
    Resources: 82 LUTs and 115 FFs for 30-bit input and 25 bit output on Xilinx platform.
*/
module iir_lowpass_pow2k_filter
#(
    parameter INPUT_BITS = 30,
    parameter RESULT_BITS = 30,
    parameter FILTER_SHIFT_BITS = 11,
    parameter FILTER_STAGES = 2,
    // 1 for signed data, 0 for unsigned
    parameter SIGNED_DATA = 1
)
(
    input logic CLK,
    input logic RESET,
    input logic CE,
    // input
    input logic signed [INPUT_BITS-1:0] IN_VALUE,
    // output
    output logic signed [RESULT_BITS-1:0] OUT_VALUE
);

logic sign_extension_enabled;
always_comb sign_extension_enabled <= SIGNED_DATA ? 1'b1 : 1'b0;

logic signed [RESULT_BITS + FILTER_SHIFT_BITS - 1:0] stage0_in;
always_comb stage0_in <= { IN_VALUE, { (RESULT_BITS + FILTER_SHIFT_BITS - INPUT_BITS) {1'b0}} };

logic signed [RESULT_BITS:0] diff[FILTER_STAGES];

logic signed [RESULT_BITS + FILTER_SHIFT_BITS - 1:0] state[FILTER_STAGES];

always_comb begin
    for (int i = 0; i < FILTER_STAGES; i++) begin
        diff[i] <=
                (
                    // new value
                    (i == 0) 
                    ? { sign_extension_enabled & stage0_in[RESULT_BITS + FILTER_SHIFT_BITS - 1], stage0_in[RESULT_BITS + FILTER_SHIFT_BITS - 1:FILTER_SHIFT_BITS] } 
                    : { sign_extension_enabled & state[i-1][RESULT_BITS + FILTER_SHIFT_BITS - 1], state[i-1][RESULT_BITS + FILTER_SHIFT_BITS - 1:FILTER_SHIFT_BITS] }
                ) 
                - { state[i][RESULT_BITS + FILTER_SHIFT_BITS - 1], state[i][RESULT_BITS + FILTER_SHIFT_BITS - 1 : FILTER_SHIFT_BITS] };
    end
end

always_comb OUT_VALUE <= state[FILTER_STAGES-1][RESULT_BITS + FILTER_SHIFT_BITS - 1:FILTER_SHIFT_BITS];

//new_state = state + (input - state)/k

always_ff @(posedge CLK) begin
    for (int i = 0; i < FILTER_STAGES; i++) begin
        if (RESET) begin
            state[i] <= 0;
        end else if (CE) begin
            state[i] <= state[i] + diff[i];
        end
    end
end

endmodule
