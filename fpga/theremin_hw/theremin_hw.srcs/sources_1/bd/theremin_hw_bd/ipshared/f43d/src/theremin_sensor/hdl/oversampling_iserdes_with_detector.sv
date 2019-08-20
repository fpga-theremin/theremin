`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/25/2019 04:35:27 PM
// Design Name: 
// Module Name: oversampling_iserdes_with_detector
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


module oversampling_iserdes_with_detector(
    // 600MHz
    input logic CLK_SHIFT,
    // 600MHz inverted
    input logic CLK_SHIFTB,
    // 150MHz
    input logic CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    //input logic CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    input logic CE,
    
    // input frequency
    input logic FREQ_IN,

    // 1 for one cycle if state is changed
    output logic CHANGED_FLAG,
    
    // when CHANGED_FLAG==1, contains number of changed bit
    output logic [5:0] CHANGED_BIT

    //, output logic [63:0] debug_parallel

);

logic [63:0] parallel;

//always_comb debug_parallel = parallel;

oversampling_iserdes oversampling_iserdes_inst
(
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

    // parallel oversampled deserialized output    
    .PARALLEL_OUT(parallel)
);

//oversampling_iserdes_detector oversampling_iserdes_detector_inst (

oversampling_iserdes_bit_detector oversampling_iserdes_bit_detector_inst (
    // 200MHz
    .CLK_PARALLEL,

    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    .RESET,
    .CE,
    
    // parallel oversampled deserialized output    
    .PARALLEL_IN(parallel),

    // 1 for one cycle if state is changed
    .CHANGED_FLAG,
    
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT
);



endmodule
