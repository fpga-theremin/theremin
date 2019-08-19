`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/25/2019 04:59:30 PM
// Design Name: 
// Module Name: oversampling_iserdes_period_measure
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Signal full period measure (sum of two recent half-periods)
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oversampling_iserdes_period_measure
#(
    parameter PERIOD_BITS = 16
) (
    // 600MHz
    input logic CLK_SHIFT,
    // 600MHz inverted
    input logic CLK_SHIFTB,
    // 150MHz
    input logic CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    input logic CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    
    input logic CE,
    
    // input frequency
    input logic FREQ_IN,

    // 1 for one cycle if new measured value is available
    output logic CHANGE_FLAG,
    
    // last measured period value value, becomes available when CHANGED_FLAG==1
    output logic [PERIOD_BITS-1:0] PERIOD

//    , output logic [63:0] debug_parallel

);

logic freq_in_buffered;
IBUF ibuf_inst (
    .I(FREQ_IN),
    .O(freq_in_buffered)
);

// 1 for one cycle if new measured value is available
logic halfperiod_changed_flag;
   
// last measured half period value new value becomes available when CHANGED_FLAG==1
logic [PERIOD_BITS-2:0] halfperiod;

oversampling_iserdes_halfperiod_measure
#(
    .PERIOD_BITS(PERIOD_BITS - 1)
) oversampling_iserdes_halfperiod_measure_inst (
    // 800MHz
    .CLK_SHIFT,
    // 800MHz inverted
    .CLK_SHIFTB,
    // 200MHz
    .CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    .CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    .RESET,
    .CE,
    
    // input frequency
    .FREQ_IN(freq_in_buffered),

    // 1 for one cycle if new measured value is available
    .CHANGED_FLAG(halfperiod_changed_flag),
    
    // last measured half period value new value becomes available when CHANGED_FLAG==1
    .PERIOD(halfperiod)
    
//    , .debug_parallel
);

logic [PERIOD_BITS-2:0] prev_halfperiod;
logic [PERIOD_BITS-1:0] period;
logic ready;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        prev_halfperiod <= 'b0;
        ready <= 'b0;
    end else begin
        ready <= halfperiod_changed_flag;
        if (halfperiod_changed_flag) begin
            period <= halfperiod + prev_halfperiod;
            prev_halfperiod <= halfperiod;
        end
    end
end

// 1 for one cycle if new measured value is available
always_comb CHANGE_FLAG <= ready;
// last measured half value new value becomes available when CHANGED_FLAG==1
always_comb PERIOD <= period;

endmodule
