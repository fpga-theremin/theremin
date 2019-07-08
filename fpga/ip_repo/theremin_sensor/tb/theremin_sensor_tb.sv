`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 05:07:40 PM
// Design Name: 
// Module Name: theremin_sensor_tb
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


module theremin_sensor_tb(

);


localparam PITCH_COUNTER_BITS=12;
// oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
localparam PITCH_OVERSAMPLING_BITS=0;
// filter K right shift
localparam PITCH_FILTER_K_SHIFT=2;
// output bits
localparam PITCH_OUTPUT_BITS=32;
// internal filter bits
localparam PITCH_INTERNAL_BITS=32;

localparam VOLUME_COUNTER_BITS=12;
// oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
localparam VOLUME_OVERSAMPLING_BITS=0;
// filter K right shift
localparam VOLUME_FILTER_K_SHIFT=2;
// output bits
localparam VOLUME_OUTPUT_BITS=32;
// internal filter bits
localparam VOLUME_INTERNAL_BITS=32;



// 800MHz
logic CLK_SHIFT;
logic CLK_SHIFTB;
// 200MHz
logic CLK_PARALLEL;
logic CLK;
// reset, active 1
logic RESET;
// input frequency from volume oscillator
logic PITCH_FREQ_IN;
// input frequency from volume oscillator
logic VOLUME_FREQ_IN;

logic [PITCH_OUTPUT_BITS-1:0] PITCH_PERIOD;
logic [VOLUME_OUTPUT_BITS-1:0] VOLUME_PERIOD;


theremin_sensor  
#(
    .PITCH_COUNTER_BITS(PITCH_COUNTER_BITS),
// oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .PITCH_OVERSAMPLING_BITS(PITCH_OVERSAMPLING_BITS),
// filter K right shift
    .PITCH_FILTER_K_SHIFT(PITCH_FILTER_K_SHIFT),
// output bits
    .PITCH_OUTPUT_BITS(PITCH_OUTPUT_BITS),
// internal filter bits
    .PITCH_INTERNAL_BITS(PITCH_INTERNAL_BITS),

    .VOLUME_COUNTER_BITS(VOLUME_COUNTER_BITS),
// oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .VOLUME_OVERSAMPLING_BITS(VOLUME_OVERSAMPLING_BITS),
// filter K right shift
    .VOLUME_FILTER_K_SHIFT(VOLUME_FILTER_K_SHIFT),
// output bits
    .VOLUME_OUTPUT_BITS(VOLUME_OUTPUT_BITS),
// internal filter bits
    .VOLUME_INTERNAL_BITS(VOLUME_INTERNAL_BITS)
) theremin_sensor_inst
(
    // 100MHz
    .*
);

initial begin
    // reset, active 1
    #33 RESET = 1;
    #150 RESET = 0;
end

int clock_counter = 0;

always begin
    // 100MHz
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1;
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1; CLK = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1; CLK = 1;
    clock_counter = clock_counter + 1;
end

real pitch_period = 0;
real volume_period = 0;

// sample rate MHz
localparam pitch_sample_rate = 1600 << PITCH_OVERSAMPLING_BITS;
localparam data_bits = PITCH_COUNTER_BITS+PITCH_OVERSAMPLING_BITS;
localparam real pitch_div = 1 << (PITCH_COUNTER_BITS+PITCH_OVERSAMPLING_BITS);

always begin
    #200 $display("%d: %f  %f: %h %f   %f: %h", clock_counter, clock_counter / 100000.0, 
        pitch_period, PITCH_PERIOD, 
        PITCH_PERIOD/pitch_div, 
        volume_period, VOLUME_PERIOD);
end

always begin
    PITCH_FREQ_IN = 0;
    #200 ;
    pitch_period = 1345.23 + 1345.23;
    repeat (133) begin
        #1345.23 PITCH_FREQ_IN = 1;
        #1345.23 PITCH_FREQ_IN = 0;
    end
    pitch_period = 1465.99 + 1476.33;
    repeat (133) begin
        #1465.99 PITCH_FREQ_IN = 1;
        #1476.33 PITCH_FREQ_IN = 0;
    end
    pitch_period = 1278.34 + 1289.65;
    repeat (133) begin
        #1278.34 PITCH_FREQ_IN = 1;
        #1289.65 PITCH_FREQ_IN = 0;
    end
    pitch_period = 1378.34 + 1389.65;
    repeat (123) begin
        #1378.34 PITCH_FREQ_IN = 1;
        #1389.65 PITCH_FREQ_IN = 0;
    end
    pitch_period = 2678.34 + 2689.65;
    repeat (123) begin
        #2678.34 PITCH_FREQ_IN = 1;
        #2689.65 PITCH_FREQ_IN = 0;
    end
    //#100 $finish();
end

always begin
    VOLUME_FREQ_IN = 0;
    #234 ;
    volume_period = 3235.23 + 3235.23;
    repeat (113) begin
        #3235.23 VOLUME_FREQ_IN = 1;
        #3235.23 VOLUME_FREQ_IN = 0;
    end
    volume_period = 2835.23 + 2835.23;
    repeat (143) begin
        #2835.23 VOLUME_FREQ_IN = 1;
        #2835.23 VOLUME_FREQ_IN = 0;
    end
    volume_period = 1438.34 + 1439.65;
    repeat (113) begin
        #1438.34 VOLUME_FREQ_IN = 1;
        #1439.65 VOLUME_FREQ_IN = 0;
    end
    volume_period = 1548.34 + 1549.65;
    repeat (123) begin
        #1548.34 VOLUME_FREQ_IN = 1;
        #1549.65 VOLUME_FREQ_IN = 0;
    end
    volume_period = 2418.34 + 2419.65;
    repeat (123) begin
        #2418.34 VOLUME_FREQ_IN = 1;
        #2419.65 VOLUME_FREQ_IN = 0;
    end
    #100 $finish();
end

endmodule
