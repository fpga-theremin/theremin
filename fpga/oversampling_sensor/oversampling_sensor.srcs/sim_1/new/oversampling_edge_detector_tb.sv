`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 05:26:36 PM
// Design Name: 
// Module Name: oversampling_edge_detector
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


module oversampling_edge_detector_tb (

);

// oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
localparam OVERSAMPLING = 3;
// reference frequency for delay line, in MHz
localparam DELAY_REFCLOCK_FREQUENCY=200.0;
// number of bits in timer cycle counter (8 bits for 150MHz->1MHz, 6 bits for max filter stage1 delay)
localparam COUNTER_BITS = 8 + 6;

// ~600MHz
logic CLK_SHIFT;
// ~600MHz, phase inverted CLK_SHIFT 
logic CLK_SHIFTB;
// ~150MHz, must be phase aligned CLK_SHIFT/4 
logic CLK;

// reset, active 1, must be synchronous to CLK_SHIFT !!!
logic RESET;
// counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
// must be synchronous to CLK_SHIFT !!!
logic CE;

// serial input
logic IN;

// 1 for one cycle if state is changed
logic CHANGE_FLAG;

// 1 if change is raising edge, 0 if falling edge
logic CHANGE_EDGE;

// counter value for edge    
logic[3 + OVERSAMPLING + COUNTER_BITS - 1 : 0] EDGE_POSITION;

oversampling_edge_detector
#(
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    .OVERSAMPLING(OVERSAMPLING),
    // reference frequency for delay line, in MHz
    .DELAY_REFCLOCK_FREQUENCY(DELAY_REFCLOCK_FREQUENCY),
    // number of bits in timer cycle counter (8 bits for 150MHz->1MHz, 6 bits for max filter stage1 delay)
    .COUNTER_BITS(COUNTER_BITS)
)
oversampling_edge_detector_inst
(
    // ~600MHz
    .CLK_SHIFT,
    // ~600MHz, phase inverted CLK_SHIFT 
    .CLK_SHIFTB,
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    .CLK,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET,
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    .CE,

    // serial input
    .IN,
    
    // 1 for one cycle if state is changed
    .CHANGE_FLAG,

    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE,
    
    // counter value for edge    
    .EDGE_POSITION
);


initial begin
    // 150MHz
    repeat (100000) begin
        #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 1;
        #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 1;
        #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 1;
        #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 1;
        #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 0;
        #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 0;
        #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 0;
        #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 0;
    end;
end

initial begin
    IN = 0;
    $display("freq1");
    repeat (20) begin
        #451.73561123 IN = 1;
        #473.14321239 IN = 0;
    end
    $display("freq2");
    repeat (20) begin
        #371.12387443 IN = 1;
        #543.87325367 IN = 0;
    end
    $display("freq3");
    repeat (20) begin
        #333.14343443 IN = 1;
        #773.54435367 IN = 0;
    end
    $display("freq4");
    repeat (200) begin
        #521.54345343 IN = 1;
        #449.43243367 IN = 0;
    end
    $finish;
end

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value (%h != %h)", signal, value); \
            $finish; \
        end

logic[3 + OVERSAMPLING + COUNTER_BITS - 1 : 0] prev_position;
always @(posedge CHANGE_FLAG) begin
    #4 $display("Edge detected: CHANGE_FLAG = %d\tCHANGE_EDGE = %d\tEDGE_POSITION = %d\tDIFF = ", CHANGE_FLAG, CHANGE_EDGE, EDGE_POSITION, EDGE_POSITION - prev_position);
    prev_position = EDGE_POSITION;
end

initial begin
    #3 RESET = 0; CE = 0;
    #3 @(posedge CLK) RESET = 1;
    #120 @(posedge CLK) RESET = 0;
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    @(posedge CLK) RESET = 0;
    @(posedge CLK) RESET = 0;
    @(posedge CLK) RESET = 0;
    @(posedge CLK) RESET = 0; CE = 1;
    
end


endmodule
