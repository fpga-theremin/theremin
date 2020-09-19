`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 08:50:21 AM
// Design Name: 
// Module Name: oversampling_iserdes
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


module oversampling_iserdes
#(
    // oversampling bits, 0=no oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    parameter OVERSAMPLING = 3,
    // reference frequency for delay line, in MHz
    parameter DELAY_REFCLOCK_FREQUENCY=200.0
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
    
    // parallel output, OUT[0] is oldest sample, OUT[7] is most recent sample
    output logic [(8 << OVERSAMPLING)-1 : 0] OUT
);

localparam ISERDES_COUNT = 1 << OVERSAMPLING;
// 64 taps == 200 MHz (ref clock)
// 1 tap = 200*64=12.8GHz
// OVERSAMPLING = 0 is 1.2GHz == 12.8/1.2 == 10.666 taps step  (using 0 instead since we don't need delay for single ISERDES) 
// OVERSAMPLING = 1 is 2.4GHz == 12.8/2.4 == 5.333 taps step : use 5 
// OVERSAMPLING = 2 is 4.8GHz == 12.8/4.8 == 2.666 taps step : use 3 
// OVERSAMPLING = 3 is 9.6GHz == 12.8/9.6 == 1.333 taps step : use 1 
// 64/6 taps == 1200MHz (cycle of ISERDES in DDR mode)
localparam DELAY_STEP_TAPS =  (OVERSAMPLING == 0) ?    0
                           :  (OVERSAMPLING == 1) ?    5
                           :  (OVERSAMPLING == 2) ?    3
                           :/*(OVERSAMPLING == 3) ? */ 1;

genvar i;
generate
    for (i = 0; i < ISERDES_COUNT; i++) begin
        iserdes_ddr
        #(
            // when non-zero, instantiates IDELAYE2 with specified delay value to feed input
            .DELAY_VALUE((OVERSAMPLING > 0 ? ((ISERDES_COUNT - 1 - i) * DELAY_STEP_TAPS) + 1 : 0)),
            // reference frequency for delay line, in MHz
            .DELAY_REFCLOCK_FREQUENCY(DELAY_REFCLOCK_FREQUENCY)
        )
        iserdes_ddr_inst
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
            
            // parallel output, OUT[0] is oldest sample, OUT[7] is most recent sample
            .OUT({
                OUT[(7 << OVERSAMPLING) + i], 
                OUT[(6 << OVERSAMPLING) + i], 
                OUT[(5 << OVERSAMPLING) + i], 
                OUT[(4 << OVERSAMPLING) + i],
                OUT[(3 << OVERSAMPLING) + i],
                OUT[(2 << OVERSAMPLING) + i],
                OUT[(1 << OVERSAMPLING) + i],
                OUT[(0 << OVERSAMPLING) + i]
            })
        );
    end
endgenerate


endmodule
