`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/30/2019 11:07:10 AM
// Design Name: 
// Module Name: theremin_oversampling_iserdes_period_measure_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Theremin sensor frequency measure module test bench
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module theremin_oversampling_iserdes_period_measure_tb(
);


localparam PITCH_PERIOD_BITS = 16;
localparam VOLUME_PERIOD_BITS = 16;
localparam DATA_BITS = 28;
localparam FILTER_SHIFT_BITS = 8;

// 600MHz - ISERDESE2 DDR mode shift clock
logic CLK_SHIFT;
// 600MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
logic CLK_SHIFTB;
// 150MHz - ISERDESE2 parallel output clock - clock should be 1/4 of CLK_SHIFT, phase aligned 
logic CLK_PARALLEL;

// 200MHz input for driving IDELAYE2
logic CLK_DELAY;

// main clock ~100MHz for measured value outputs
logic CLK;

// reset, active 1, must be synchronous to CLK_SHIFT !!!
logic RESET;

// serial input of pitch signal
logic PITCH_FREQ_IN;
// serial input of volume signal
logic VOLUME_FREQ_IN;

// measured pitch period value - number of 1.2GHz*oversampling ticks since last change  (in CLK clock domain)
//logic [PITCH_PERIOD_BITS-1:0] PITCH_PERIOD_NOFILTER;
// measured volume period value - number of 1.2GHz*oversampling ticks since last change (in CLK clock domain)
//logic [VOLUME_PERIOD_BITS-1:0] VOLUME_PERIOD_NOFILTER;

// output value for channel A (in CLK clock domain)
logic [DATA_BITS-1:0] PITCH_PERIOD_FILTERED;
// output value for channel B (in CLK clock domain)
logic [DATA_BITS-1:0] VOLUME_PERIOD_FILTERED;

//logic debug_pitch_change_flag;
//logic debug_volume_change_flag;
//logic debug_pitch_change_flag_sync;
//logic debug_volume_change_flag_sync;



theremin_oversampling_iserdes_period_measure
#(
    .PITCH_PERIOD_BITS(PITCH_PERIOD_BITS),
    .VOLUME_PERIOD_BITS(VOLUME_PERIOD_BITS),
    .DATA_BITS(DATA_BITS),
    .FILTER_SHIFT_BITS(FILTER_SHIFT_BITS)
) theremin_oversampling_iserdes_period_measure_inst
(
    .*
);

initial begin
    // reset, active 1
    #13 RESET = 1;
    #180 RESET = 0;
end

int clock_counter = 0;

/*
    F,MHz	period, ps	    halfperiod	    1/4 F, MHz
    100	    10.0000000000	5.0000000000	25
    150	    6.6666666667	3.3333333333	37.5
    200	    5.0000000000	2.5000000000	50
    250	    4.0000000000	2.0000000000	62.5
    300	    3.3333333333	1.6666666667	75
    350	    2.8571428571	1.4285714286	87.5
    400	    2.5000000000	1.2500000000	100
    450	    2.2222222222	1.1111111111	112.5
    500	    2.0000000000	1.0000000000	125
    550	    1.8181818182	0.9090909091	137.5
    600	    1.6666666667	0.8333333333	150
    650	    1.5384615385	0.7692307692	162.5
    700	    1.4285714286	0.7142857143	175
    750	    1.3333333333	0.6666666667	187.5
    800	    1.2500000000	0.6250000000	200
    850	    1.1764705882	0.5882352941	212.5
    900	    1.1111111111	0.5555555556	225
    950	    1.0526315789	0.5263157895	237.5
   1000	    1.0000000000	0.5000000000	250

*/

always begin
    // 200MHz for IDELAYE2
    #2.5 CLK_DELAY=0;
    #2.5 CLK_DELAY=1;
end

always begin
    // 100MHz clock for general processing
    #5 CLK=0;
    #5 CLK=1;
    clock_counter = clock_counter + 1;
end

/*
    F,MHz	period, ps	    halfperiod	    1/4 F, MHz
    500	    2.0000000000	1.0000000000	125
    550	    1.8181818182	0.9090909091	137.5
    600	    1.6666666667	0.8333333333	150
    650	    1.5384615385	0.7692307692	162.5
    700	    1.4285714286	0.7142857143	175
    750	    1.3333333333	0.6666666667	187.5
    800	    1.2500000000	0.6250000000	200
    850	    1.1764705882	0.5882352941	212.5
    900	    1.1111111111	0.5555555556	225
    950	    1.0526315789	0.5263157895	237.5
   1000	    1.0000000000	0.5000000000	250

*/

// 800MHZ
//`define TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY #0.625
// 600MHZ
`define TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY #0.834
// 500MHZ
//`define TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY #1.0

always begin
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1;
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1;// CLK = 0;
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1;// CLK = 1;
end

always @(posedge CLK_PARALLEL) begin
    #5 ;
    $display("%d: >>>>  %d   %h          %d   %h", clock_counter, 
        //PITCH_PERIOD_NOFILTER, 
        PITCH_PERIOD_FILTERED,PITCH_PERIOD_FILTERED, 
        //VOLUME_PERIOD_NOFILTER, 
        VOLUME_PERIOD_FILTERED, VOLUME_PERIOD_FILTERED
        );
    //if (debug_iserdes_change_flag)
    //    $display("          %d   %h", debug_iserdes_changed_bit, debug_iserdes_changed_bit);
    #70 ;
end


always begin
    PITCH_FREQ_IN = 0;
    #200 ;
    $display("*** 1145.23+1145.23  expected half period: 2574.276");
    repeat (455) begin
        #1145.23 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
        #1145.23 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
    end
    $display("*** 1165.99+1276.33");
    repeat (393) begin
        #1165.99 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
        #1276.33 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
    end
    $display("*** 1178.34+1799.65");
    repeat (553) begin
        #1178.34 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
        #1799.65 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
    end
    $display("*** 1378.34+689.65");
    repeat (483) begin
        #1378.34 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
        #689.65 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
    end
    $display("*** 2178.34+2989.65");
    repeat (173) begin
        #1178.34 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
        #2989.65 PITCH_FREQ_IN = ~PITCH_FREQ_IN;
    end
    #1000 $finish();
end

always begin
    VOLUME_FREQ_IN = 0;
    #213.567 ;
    $display("=== 3298.17  expected half period: 2574.276");
    repeat (355) begin
        #3298.17 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
        #3298.17 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
    end
    $display("=== 2893.56+2159.21");
    repeat (553) begin
        #2893.56 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
        #2159.21 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
    end
    $display("=== 1721.12+345.71");
    repeat (193) begin
        #1721.12 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
        #345.71 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
    end
    $display("=== 2146.34+992.65");
    repeat (653) begin
        #2146.34 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
        #992.65 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
    end
    $display("=== 345.34+1234.56");
    repeat (573) begin
        #345.34 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
        #1234.56 VOLUME_FREQ_IN = ~VOLUME_FREQ_IN;
    end
    #1000 $finish();
end

endmodule
