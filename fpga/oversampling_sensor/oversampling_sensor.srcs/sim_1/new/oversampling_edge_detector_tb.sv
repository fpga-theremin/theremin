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
localparam COUNTER_BITS = 8 + 9 - 1;

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

localparam EDGE_POSITION_BITS = 3 + OVERSAMPLING + COUNTER_BITS;
// counter value for edge    
logic[EDGE_POSITION_BITS - 1 : 0] EDGE_POSITION;

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

logic [EDGE_POSITION_BITS - 1 : 0] OUT_DIFF;
localparam DELAY_CYCLES = 512;

delay_diff_filter
#(
    // filter will calculate diff with value delayed by DELAY_CYCLES WR cycles, power of two is recommended
    .DELAY_CYCLES(DELAY_CYCLES),
    // number of bits in value (the bigger is delay, the more bits in value is needed: one addr bit == +1 value bit)
    .VALUE_BITS(EDGE_POSITION_BITS),
    // use BRAM for delays with log2(DELAY_CYCLE) >= BRAM_ADDR_BITS_THRESHOLD
    .BRAM_ADDR_BITS_THRESHOLD(5)
)
delay_diff_filter_inst
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    .CLK,

    // reset, active 1
    .RESET,

    // input value for filter
    .IN_VALUE(EDGE_POSITION),

    // set to 1 for one clock cycle to push new value
    .WR(CHANGE_FLAG),
    
    // filter output (IN_VALUE - delay(IN_VALUE, 2**DELAY_ADDR_BITS)), updated one cycle after WR
    // delay is counted as number of input values (WR==1 count)
    .OUT_DIFF
);

always begin
    // 150MHz
    #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 1;
    #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 1;
    #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 1;
    #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 1;
    #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 0;
    #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 0;
    #0.833333333333333 CLK_SHIFT = 1; CLK_SHIFTB=0; CLK = 0;
    #0.833333333333333 CLK_SHIFT = 0; CLK_SHIFTB=1; CLK = 0;
end

initial begin
    IN = 0;
    $display("freq1 = %f MHz", 1000.0/(451.73561123+473.14321239));
    repeat (1500) begin
        #451.73561123 IN = 1;
        #473.14321239 IN = 0;
    end
    $display("freq2 = %f MHz", 1000.0/(371.12387443+543.87325367));
    repeat (1500) begin
        #371.12387443 IN = 1;
        #543.87325367 IN = 0;
    end
    $display("freq3 = %f MHz", 1000.0/(333.14343443+773.54435367));
    repeat (1500) begin
        #333.14343443 IN = 1;
        #773.54435367 IN = 0;
    end
    $display("freq4 = %f MHz", 1000.0/(521.54345343+449.43243367));
    repeat (2000) begin
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
    #4 @(posedge CLK) #4 $display("Edge detected: CHANGE_FLAG = \t%d\tCHANGE_EDGE = \t%d\tEDGE_POSITION = \t%d\tDIFF = \t%d\tDELAY_DIFF = \t%d\tfreq=\t%f", 
        CHANGE_FLAG, CHANGE_EDGE, 
        EDGE_POSITION, EDGE_POSITION - prev_position, 
        OUT_DIFF,
        (150.0 * 8 * (1<<OVERSAMPLING)) / ((OUT_DIFF + 0.0) / (DELAY_CYCLES/2.0))
        );
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
