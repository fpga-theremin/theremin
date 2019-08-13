`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2019 05:06:22 PM
// Design Name: 
// Module Name: oversampling_iserdes_period_measure_tb
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


module oversampling_iserdes_period_measure_tb(

    );
    

localparam PERIOD_BITS = 16;

// 100MHz
logic CLK;

// 800MHz
logic CLK_SHIFT;
// 800MHz inverted
logic CLK_SHIFTB;
// 200MHz
logic CLK_PARALLEL;

// 200MHz input for driving IDELAYE2
logic CLK_DELAY;

// reset, active 1, must be synchronous to CLK_PARALLEL !!!
logic RESET;

// input frequency
logic FREQ_IN;

// 1 for one cycle if new measured value is available
logic CHANGE_FLAG;

// last measured period value value, becomes available when CHANGED_FLAG==1
logic [PERIOD_BITS-1:0] PERIOD;

//logic [63:0] debug_parallel;

oversampling_iserdes_period_measure
#(
    .PERIOD_BITS(PERIOD_BITS)
) oversampling_iserdes_period_measure_inst (
    .*
);
  
initial begin
    // reset, active 1
    #33 RESET = 1;
    #150 RESET = 0;
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
//`define TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY #0.625
// 600MHZ
`define TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY #0.834
// 500MHZ
//`define TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY #1.0

always begin
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1;
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1;
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_OVS_ISERDES_PERIOD_MEASURE_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1;
    clock_counter = clock_counter + 1;
end

always @(posedge CHANGE_FLAG) begin
    #7 $display(">>>>  %d   %h", PERIOD, PERIOD);
end

always begin
    FREQ_IN = 0;
    #200 ;
    $display("*** 2145.23");
    repeat (53) begin
        #2145.23 FREQ_IN = 1;
        #2145.23 FREQ_IN = 0;
    end
    $display("*** 1165.99+1276.33");
    repeat (53) begin
        #1165.99 FREQ_IN = 1;
        #1276.33 FREQ_IN = 0;
    end
    $display("*** 2178.34+2799.65");
    repeat (53) begin
        #2178.34 FREQ_IN = 1;
        #2799.65 FREQ_IN = 0;
    end
    $display("*** 1378.34+1689.65");
    repeat (53) begin
        #1378.34 FREQ_IN = 1;
        #1689.65 FREQ_IN = 0;
    end
    $display("*** 2178.34+2989.65");
    repeat (73) begin
        #2178.34 FREQ_IN = 1;
        #2989.65 FREQ_IN = 0;
    end
    #1000 $finish();
end
    
endmodule
