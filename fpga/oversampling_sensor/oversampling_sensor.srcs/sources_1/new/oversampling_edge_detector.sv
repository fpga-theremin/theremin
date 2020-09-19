`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vadim Lopatin 
// 
// Create Date: 03/03/2020 04:04:00 PM
// Design Name: 
// Module Name: oversampling_edge_detector
// Project Name: 
// Target Devices: Xilinx Series 7 
// Tool Versions: 
// Description: 
//      High resolution oversampling based edge detector for serial signal input.
//      Provides edge detection flag, edge type and edge position based on counter value and subsample index.  
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oversampling_edge_detector
#(
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    parameter OVERSAMPLING = 3,
    // reference frequency for delay line, in MHz
    parameter DELAY_REFCLOCK_FREQUENCY=200.0,
    // number of bits in timer cycle counter (8 bits for 150MHz->1MHz, 6 bits for max filter stage1 delay)
    parameter COUNTER_BITS = 8 + 6
)
(
    // ~600MHz
    input logic CLK_SHIFT,
    // ~600MHz, phase inverted CLK_SHIFT 
    input logic CLK_SHIFTB,
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    input logic CLK,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    input logic CE,

    // serial input
    input logic IN,
    
    // 1 for one cycle if state is changed
    output logic CHANGE_FLAG,

    // 1 if change is raising edge, 0 if falling edge
    output logic CHANGE_EDGE,
    
    // counter value for edge    
    output logic[3 + OVERSAMPLING + COUNTER_BITS - 1 : 0] EDGE_POSITION
);

// parallel output, OUT[0] is oldest sample, OUT[7] is most recent sample
logic [(8 << OVERSAMPLING)-1 : 0] deserialized;
// when CHANGED_FLAG==1, contains number of changed bit
logic [OVERSAMPLING - 1 : 0] changed_bit;

oversampling_iserdes
#(
    // oversampling bits, 0=no oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    .OVERSAMPLING(OVERSAMPLING),
    // reference frequency for delay line, in MHz
    .DELAY_REFCLOCK_FREQUENCY(DELAY_REFCLOCK_FREQUENCY)
)
oversampling_iserdes_inst
(
    // ~600MHz
    .CLK_SHIFT(CLK_SHIFT),
    // ~600MHz, phase inverted CLK_SHIFT 
    .CLK_SHIFTB(CLK_SHIFTB),
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    .CLK(CLK),

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET(RESET),
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    .CE(CE),

    // serial input
    .IN(IN),
    
    // parallel output, OUT[0] is oldest sample, OUT[7] is most recent sample
    .OUT(deserialized)
);

logic [OVERSAMPLING + 3 - 1 : 0] detected_bit;

bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    .OVERSAMPLING(OVERSAMPLING + 3)
) 
bit_change_detector_inst
(
    // 150MHz
    .CLK(CLK),

    // reset, active 1, must be synchronous to CLK !!!
    .RESET(RESET),
    
    // parallel oversampled deserialized input    
    .PARALLEL_IN(deserialized),

    // 1 for one cycle if state is changed
    .CHANGE_FLAG(CHANGE_FLAG),

    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(CHANGE_EDGE),
    
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT(detected_bit)
);

logic [COUNTER_BITS-1 : 0] counter;
always_ff @(posedge CLK) begin
    if (RESET) begin
        counter <= 'b0;
    end else begin
        counter <= counter + 1;
    end
end

always_comb EDGE_POSITION <= {counter, detected_bit};


endmodule
