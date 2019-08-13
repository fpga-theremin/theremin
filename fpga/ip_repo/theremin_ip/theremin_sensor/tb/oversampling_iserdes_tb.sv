`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2019 10:11:50 AM
// Design Name: 
// Module Name: oversampling_iserdes_tb
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


module oversampling_iserdes_tb(

    );

// 100MHz clock
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

// parallel oversampled deserialized output    
logic [63:0] PARALLEL_OUT;

oversampling_iserdes oversampling_iserdes_inst
(
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
`define TB_ISERDES_CLK_GEN_DELAY #0.625
// 600MHZ
//`define TB_ISERDES_CLK_GEN_DELAY #0.83333333

always begin
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1;
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1; CLK = 0;
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 0;
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=0; CLK_SHIFTB = 1; 
    `TB_ISERDES_CLK_GEN_DELAY CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_PARALLEL = 1; CLK = 1;
    clock_counter = clock_counter + 1;
end

logic last_value;
always @(posedge CLK_PARALLEL) begin
    #1 if (last_value != PARALLEL_OUT[63]) $display(">>> %f: %b", clock_counter / 100000.0, PARALLEL_OUT);
    last_value = PARALLEL_OUT[63];
end

always begin
    FREQ_IN = 0;
    #200 ;
    $display("*** 2145.23");
    repeat (33) begin
        #2145.23 FREQ_IN = 1;
        #2145.23 FREQ_IN = 0;
    end
    $display("*** 1165.99+1276.33");
    repeat (33) begin
        #1165.99 FREQ_IN = 1;
        #1276.33 FREQ_IN = 0;
    end
    $display("*** 2178.34+2799.65");
    repeat (33) begin
        #2178.34 FREQ_IN = 1;
        #2799.65 FREQ_IN = 0;
    end
    $display("*** 1378.34+1689.65");
    repeat (33) begin
        #1378.34 FREQ_IN = 1;
        #1689.65 FREQ_IN = 0;
    end
    $display("*** 2178.34+2989.65");
    repeat (33) begin
        #2178.34 FREQ_IN = 1;
        #2989.65 FREQ_IN = 0;
    end
    #1000 $finish();
end

endmodule
