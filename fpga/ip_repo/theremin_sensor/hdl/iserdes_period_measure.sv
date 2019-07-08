`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 01:11:08 PM
// Design Name: 
// Module Name: iserdes_period_measure
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

/*
    DDR mode iserdes with 800MHz clock converts 1.6GHz serial signal into 200MHz 8bit parallel signal.
    iserdes_period_measure counts duration from edge to edge (pos->neg, or neg->pos)
    If 12 bits counter is used (up to 4096 cycles count), 1_600_000_000/4096 = 1/195KHz max duration can be counted.
    With ~50% duty cycle, 1/200KHz change corresponds to 400KHz input signal minimum frequency 
*/

module iserdes_period_measure
#(
    parameter COUNTER_BITS=12,
    parameter DELAY_INPUT=0
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
    output logic [COUNTER_BITS-1:0] DURATION
);

logic [7:0] parallel;

iserdes_ddr
#(
    .DELAY_INPUT(DELAY_INPUT)
)
iserdes_ddr_inst
(
    // 800MHz
    .CLK_SHIFT,
    .CLK_SHIFTB,
    // 200MHz
    .CLK_PARALLEL,
    // reset, active 1
    .RESET,
    // serial input
    .IN(FREQ_IN),
    // parallel output
    .OUT(parallel)
);

logic detector_changed_flag;
logic [2:0] detector_changed_bit;

iserdes_detector iserdes_detector_inst (
    .CLK(CLK_PARALLEL),
    .RESET,
    .IN(parallel),
    .CHANGED_FLAG(detector_changed_flag),
    .CHANGED_BIT(detector_changed_bit)
);

logic prev_detector_changed_flag;
logic [2:0] prev_detector_changed_bit;
always_ff @(posedge CLK_PARALLEL) begin
    prev_detector_changed_flag <= detector_changed_flag;
    prev_detector_changed_bit <= detector_changed_bit;
end

// for converted 200MHz 8 bit -> 100MHz 16bit changed bit/flag
logic changed_flag;
logic [3:0] changed_bit;

always_ff @(posedge CLK) begin
    changed_flag <= detector_changed_flag | prev_detector_changed_flag;
    if (prev_detector_changed_flag) begin
        changed_bit <= {1'b0, prev_detector_changed_bit};
        changed_flag <= 'b1;
    end else if (detector_changed_flag) begin
        changed_bit <= {1'b1, detector_changed_bit};
        changed_flag <= 'b1;
    end else begin
        changed_bit <= 'b0;
        changed_flag <= 'b0;
    end
end

logic [COUNTER_BITS-1:0] period_counter;
logic [COUNTER_BITS-1:0] duration_reg;
logic edge_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        period_counter <= 'b0;
        duration_reg <= 'b0;
        edge_reg <= 'b0;
    end else begin
        if (changed_flag) begin
            duration_reg <= period_counter + changed_bit + 1;
            period_counter <= { {COUNTER_BITS-4{1'b0}}, ~changed_bit };
        end else begin
            period_counter <= period_counter + 16;
        end
        edge_reg <= changed_flag;
    end
end

always_comb EDGE_FLAG <= edge_reg;
always_comb DURATION <= duration_reg;

endmodule
