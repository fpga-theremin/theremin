`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    smooth_phase_shift measures phase difference between two signals with 2-stage IIR filter averaging
    INT_PART is counted in CLK cycles (150MHz)
    
    Resources: 207 LUTs for 30-bit period precision and 11 bits filter shift
*/
module smooth_phase_shift
#(
    parameter PERIOD_INT_PART = 10,
    parameter PERIOD_FRAC_PART = 20,
    parameter FILTER_K_SHIFT_BITS = 11
)
(
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    input logic CLK_X4B,
    input logic RESET,
    input logic CE,

    // serial input of reference signal
    input logic IN_REF,
    // serial input of shifted signal
    input logic IN_SHIFTED,

    // period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
    output logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] PERIOD_OUT

);


logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] filtered_period;
always_comb PERIOD_OUT <= filtered_period;

logic signed [PERIOD_INT_PART + 4 - 1:0] phase_difference;


logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:0] filter_stage1;
logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:0] filter_stage2;

//new_state = state * (1-1/k) + input * 1 / k
//new_state = state - state * 1/k + input * 1 / k
//new_state = state + (input - state)/k

logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART:0] diff_stage1;
always_comb diff_stage1 <= ({phase_difference, {PERIOD_FRAC_PART-4{1'b0}}} - filter_stage1[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS]);

always_ff @(posedge CLK) begin
    if (RESET) begin
        filter_stage1 <= 'b0;
    end else if (CE) begin
        filter_stage1 <= filter_stage1 + diff_stage1;
    end
end

logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART:0] diff_stage2;
always_comb diff_stage2 <= (filter_stage1[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS] - filter_stage2[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS]);

always_ff @(posedge CLK) begin
    if (RESET) begin
        filter_stage2 <= 'b0;
    end else if (CE) begin
        filter_stage2 <= filter_stage2 + diff_stage2;
    end
end

always_ff @(posedge CLK) begin
    if (RESET) begin
    end else if (CE) begin
        filtered_period <= filter_stage2[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS];
    end
end

phase_shift_ddr 
#(
    // precision (determines min frequency), lower 4 bits represent fractional part of CLK (150MHz), and the rest is number of CLK cycles between ref and shifted signal
    .POSITION_BITS(PERIOD_INT_PART + 4)
)
phase_shift_ddr_inst
(
    // parallel data clock
    .CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    .CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    .CLK_X4B,
    .RESET,
    .CE,
    
    // serial input of reference signal
    .IN_REF,
    // serial input of shifted signal
    .IN_SHIFTED,

    // detected phase difference between shifted and ref signals, lower 4 bits are fractional part of CLK
    .PHASE_DIFFERENCE(phase_difference)
);

endmodule
