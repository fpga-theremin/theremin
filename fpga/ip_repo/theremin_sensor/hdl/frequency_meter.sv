`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 02:51:07 PM
// Design Name: 
// Module Name: frequency_meter
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


module frequency_meter
#(
    parameter COUNTER_BITS=12,
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    parameter OVERSAMPLING_BITS=3,
    // filter K right shift
    parameter FILTER_K_SHIFT=6,
    // output bits
    parameter OUTPUT_BITS=32,
    // internal filter bits
    parameter INTERNAL_BITS=32
)
(
    // 100MHz
    input logic CLK,
    // 800MHz
    input logic CLK_SHIFT,
    // 800MHz inverted
    input logic CLK_SHIFTB,
    // 200MHz
    input logic CLK_PARALLEL,
    // reset, active 1
    input logic RESET,
    // input frequency
    input logic FREQ_IN,
    
    output logic EDGE_FLAG,
    
    output logic [COUNTER_BITS + OVERSAMPLING_BITS:0] UNFILTERED_DURATION,
    
    output logic [OUTPUT_BITS - 1:0] DURATION
    
);

logic edge_flag_in;
logic [OVERSAMPLING_BITS + COUNTER_BITS-1:0] duration_in;
 
oversampling_period_measure
#(
    .COUNTER_BITS(COUNTER_BITS),
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .OVERSAMPLING_BITS(OVERSAMPLING_BITS)
) oversampling_period_measure_inst
(
    // 100MHz
    .CLK,
    // 800MHz
    .CLK_SHIFT,
    // 800MHz inverted
    .CLK_SHIFTB,
    // 200MHz
    .CLK_PARALLEL,
    // reset, active 1
    .RESET,
    // input frequency
    .FREQ_IN,
    
    .EDGE_FLAG(edge_flag_in),
    
    .DURATION(duration_in)
);

// add two half-period durations to get duration from the same edge
// it's needed for support non-50% duty cycle signals
logic [OVERSAMPLING_BITS + COUNTER_BITS-1:0] prev_duration_in;
logic [OVERSAMPLING_BITS + COUNTER_BITS:0] period_duration;

logic edge_flag;
always_ff @(posedge CLK) begin
    if (RESET) begin
        prev_duration_in <= 0;
        period_duration <= 0;
        edge_flag <= 0;
    end else begin
        if (edge_flag_in) begin
            prev_duration_in <= duration_in;
            period_duration <= prev_duration_in + duration_in;
        end
        edge_flag <= edge_flag_in;
    end
end

always_comb UNFILTERED_DURATION <= {period_duration}; //period_duration;

always_comb EDGE_FLAG <= edge_flag;

logic filter_phase;
always_ff @(posedge CLK) begin
    if (RESET)
        filter_phase <= '0;
    else
        filter_phase <= ~filter_phase;
end

logic [INTERNAL_BITS-1:0] stage0_in;
logic [INTERNAL_BITS-1:0] stage0_out;
logic [INTERNAL_BITS-1:0] stage1_out;
logic [INTERNAL_BITS-1:0] stage2_out;
logic [INTERNAL_BITS-1:0] stage3_out;

always_comb
    stage0_in <= { period_duration,
      { (INTERNAL_BITS - OVERSAMPLING_BITS - COUNTER_BITS - 1) {1'b0}} 
};

fir_filter_stage_kpow2
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(INTERNAL_BITS)
)
fir_filter_stage_kpow2_stage0 (
    .CLK,
    .RESET,
    .PHASE(filter_phase),

    .IN_VALUE(stage0_in),
    .OUT_VALUE(stage0_out)
);

fir_filter_stage_kpow2
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(INTERNAL_BITS)
)
fir_filter_stage_kpow2_stage1 (
    .CLK,
    .RESET,
    .PHASE(filter_phase),

    .IN_VALUE(stage0_out),
    .OUT_VALUE(stage1_out)
);

fir_filter_stage_kpow2
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(INTERNAL_BITS)
)
fir_filter_stage_kpow2_stage2 (
    .CLK,
    .RESET,
    .PHASE(filter_phase),

    .IN_VALUE(stage1_out),
    .OUT_VALUE(stage2_out)
);

fir_filter_stage_kpow2
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(INTERNAL_BITS)
)
fir_filter_stage_kpow2_stage3 (
    .CLK,
    .RESET,
    .PHASE(filter_phase),

    .IN_VALUE(stage2_out),
    .OUT_VALUE(stage3_out)
);

always_comb DURATION <= stage3_out[OUTPUT_BITS-1:(INTERNAL_BITS-OUTPUT_BITS)];

endmodule
