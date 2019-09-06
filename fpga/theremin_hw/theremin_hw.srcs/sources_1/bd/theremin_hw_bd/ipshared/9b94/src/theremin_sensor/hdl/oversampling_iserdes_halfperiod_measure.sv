`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin 
// 
// Create Date: 07/25/2019 04:48:42 PM
// Design Name: 
// Module Name: oversampling_iserdes_halfperiod_measure
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Signal half-period measure - returns number of 2*CLK_SHIFT*8 clock ticks since previous signal change 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oversampling_iserdes_halfperiod_measure
#(
    parameter PERIOD_BITS = 16
) (
    // 800MHz
    input logic CLK_SHIFT,
    // 800MHz inverted
    input logic CLK_SHIFTB,
    // 200MHz
    input logic CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    //input logic CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    input logic CE,
    
    // input frequency
    input logic FREQ_IN,

    // 1 for one cycle if new measured value is available
    output logic CHANGED_FLAG,
    
    // last measured half period value new value becomes available when CHANGED_FLAG==1
    output logic [PERIOD_BITS-1:0] PERIOD

    //, output logic [63:0] debug_parallel

);

// 1 for one cycle if state is changed
logic changed_flag;
  
// when CHANGED_FLAG==1, contains number of changed bit
logic [5:0] changed_bit;

oversampling_iserdes_with_detector oversampling_iserdes_with_detector_inst (
    // 800MHz
    .CLK_SHIFT,
    // 800MHz inverted
    .CLK_SHIFTB,
    // 200MHz
    .CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    //.CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    .RESET,
    .CE,
    
    // input frequency
    .FREQ_IN,

    // 1 for one cycle if state is changed
    .CHANGED_FLAG(changed_flag),
    
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT(changed_bit)
    
//    , .debug_parallel
);


logic [PERIOD_BITS-1:0] accumulator;
logic [PERIOD_BITS-1:0] period_reg;
logic ready;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        accumulator <= 'b0;
        period_reg <= 'b0;
        ready <= 'b0;
    end else begin
        if (changed_flag) begin
            // signal edge is detected
            // output value is accumulated value + index of changed bit
            period_reg <= accumulator + changed_bit + 1;
            // reset period accumulator to inverse number of bits
            accumulator <= { {(PERIOD_BITS-6){1'b0}}, ~changed_bit };
            ready <= 'b1;
        end else begin
            // no changes in input: add all 8 samples to period accumulated value
            accumulator <= accumulator + 64;
            ready <= 'b0;
        end
    end
end

always_comb PERIOD <= period_reg;
always_comb CHANGED_FLAG <= ready;


endmodule
