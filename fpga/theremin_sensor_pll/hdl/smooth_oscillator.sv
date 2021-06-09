`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    smooth_oscillator is implementation of high precision periodig signal generator (NCO).
    Target signal period value is being filtered by 2-stage iir filter.
    Target singnal period may be optionally replaced with OVERRIDE value for calibration.

    Period value is fixed point value. Int part corresponds to CLK cycles (150MHz)
    
    Resources: 218 LUTs for 30-bit period precision and 11 bits filter shift on Xilinx platform.
*/
module smooth_oscillator
#(
    parameter PERIOD_INT_PART = 10,
    parameter PERIOD_FRAC_PART = 20,
    parameter LIMIT_FRAC_PART = 3,
    parameter FILTER_K_SHIFT_BITS = 11
)
(
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    input logic RESET,
    input logic CE,
    // period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
    input logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] PERIOD_IN,
    // period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
    input logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] OVERRIDE_PERIOD_IN,
    // min period value: used instead of PERIOD_IN if PERIOD_IN < MIN_PERIOD
    input logic [PERIOD_INT_PART+LIMIT_FRAC_PART-1:0] MIN_PERIOD,
    // max period value: used instead of PERIOD_IN if PERIOD_IN > MAX_PERIOD
    input logic [PERIOD_INT_PART+LIMIT_FRAC_PART-1:0] MAX_PERIOD,
    // 1 to set period to OVERRIDE_PERIOD_IN instead of PERIOD_IN
    input logic OVERRIDE_EN,

    // current filtered and limited period value
    output logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] FILTERED_PERIOD,
    // serial output
    output logic OUT
);


logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] filtered_period;
always_comb FILTERED_PERIOD <= filtered_period;

logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] limited_period;



// limit requested frequency from min bound
logic min_limit_exceeded;
always_comb min_limit_exceeded = (PERIOD_IN[PERIOD_INT_PART+PERIOD_FRAC_PART-1:PERIOD_FRAC_PART-LIMIT_FRAC_PART] < MIN_PERIOD);
logic max_limit_exceeded;
always_comb max_limit_exceeded = (PERIOD_IN[PERIOD_INT_PART+PERIOD_FRAC_PART-1:PERIOD_FRAC_PART-LIMIT_FRAC_PART] >= MAX_PERIOD);

always_ff @(posedge CLK) begin
    if (RESET) begin
        limited_period <= 'b0;  
    end else if (CE) begin
        if (OVERRIDE_EN) begin
            // optionally, override
            limited_period <= OVERRIDE_PERIOD_IN;
        end else begin
            limited_period[PERIOD_FRAC_PART-LIMIT_FRAC_PART-1:0] <= 
                    (min_limit_exceeded | max_limit_exceeded) 
                    ? 'b0 
                    : PERIOD_IN[PERIOD_FRAC_PART-LIMIT_FRAC_PART-1:0];  
            limited_period[PERIOD_INT_PART+PERIOD_FRAC_PART-1:PERIOD_FRAC_PART-LIMIT_FRAC_PART] 
                            <= (min_limit_exceeded) ? MIN_PERIOD
                            : (max_limit_exceeded) ? MAX_PERIOD
                            :                        PERIOD_IN[PERIOD_INT_PART+PERIOD_FRAC_PART-1:PERIOD_FRAC_PART-LIMIT_FRAC_PART];
        end  
    end
end


logic [PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:0] filter_stage1;
logic [PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:0] filter_stage2;

//new_state = state * (1-1/k) + input * 1 / k
//new_state = state - state * 1/k + input * 1 / k
//new_state = state + (input - state)/k

logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART:0] diff_stage1;
always_comb diff_stage1 <= (limited_period - filter_stage1[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS]);

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
        //if (FILTER_EN)
            filtered_period <= filter_stage2[PERIOD_INT_PART+PERIOD_FRAC_PART+FILTER_K_SHIFT_BITS-1:FILTER_K_SHIFT_BITS];
        //else
        //    filtered_period <= limited_period;
    end
end

oscillator_ddr
#(
    .PERIOD_INT_PART(PERIOD_INT_PART),
    .PERIOD_FRAC_PART(PERIOD_FRAC_PART)
)
oscillator_ddr_inst
(
    // parallel data clock
    .CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    .CLK_X4,
    .RESET,
    .CE,
    // period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
    .PERIOD_IN(filtered_period),
    // serial output
    .OUT
);

endmodule
