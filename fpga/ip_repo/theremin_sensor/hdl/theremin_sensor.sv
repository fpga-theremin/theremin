`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 04:36:35 PM
// Design Name: 
// Module Name: theremin_sensor
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


module theremin_sensor
#(
    parameter PITCH_COUNTER_BITS=11,
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    parameter PITCH_OVERSAMPLING_BITS=2,
    // filter K right shift
    parameter PITCH_FILTER_K_SHIFT=6,
    // output bits
    parameter PITCH_OUTPUT_BITS=28,
    // internal filter bits
    parameter PITCH_INTERNAL_BITS=28,
    
    parameter VOLUME_COUNTER_BITS=6,
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    parameter VOLUME_OVERSAMPLING_BITS=0,
    // filter K right shift
    parameter VOLUME_FILTER_K_SHIFT=8,
    // output bits
    parameter VOLUME_OUTPUT_BITS=28,
    // internal filter bits
    parameter VOLUME_INTERNAL_BITS=28
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

    // input frequency from volume oscillator
    input logic PITCH_FREQ_IN,
    // input frequency from volume oscillator
    input logic VOLUME_FREQ_IN,
    
    output logic [PITCH_OUTPUT_BITS - 1:0] PITCH_PERIOD,
    output logic [VOLUME_OUTPUT_BITS - 1:0] VOLUME_PERIOD
);


// instantiate IDELAYCTRL if required
generate
    if (PITCH_OVERSAMPLING_BITS != 0 || VOLUME_OVERSAMPLING_BITS != 0) begin
        // channel delay control
        (* IODELAY_GROUP="GROUP_FQM" *)
        IDELAYCTRL ch1_delayctrl (
            .REFCLK(CLK_PARALLEL),
            .RST(RESET),
            .RDY()
        );
    end
endgenerate


frequency_meter
#(
    .COUNTER_BITS(PITCH_COUNTER_BITS),
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .OVERSAMPLING_BITS(PITCH_OVERSAMPLING_BITS),
    // filter K right shift
    .FILTER_K_SHIFT(PITCH_FILTER_K_SHIFT),
    // output bits
    .OUTPUT_BITS(PITCH_OUTPUT_BITS),
    // internal filter bits
    .INTERNAL_BITS(PITCH_INTERNAL_BITS)
) frequency_meter_pitch
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
    .FREQ_IN(PITCH_FREQ_IN),
    
    .EDGE_FLAG(),
    
    .DURATION(PITCH_PERIOD)
);

frequency_meter
#(
    .COUNTER_BITS(VOLUME_COUNTER_BITS),
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .OVERSAMPLING_BITS(VOLUME_OVERSAMPLING_BITS),
    // filter K right shift
    .FILTER_K_SHIFT(VOLUME_FILTER_K_SHIFT),
    // output bits
    .OUTPUT_BITS(VOLUME_OUTPUT_BITS),
    // internal filter bits
    .INTERNAL_BITS(VOLUME_INTERNAL_BITS)
) frequency_meter_volume
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
    .FREQ_IN(VOLUME_FREQ_IN),
    
    .EDGE_FLAG(),
    
    .DURATION(VOLUME_PERIOD)
);

endmodule
