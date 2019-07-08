`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 05:16:22 PM
// Design Name: 
// Module Name: frequency_meter_tb
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


module frequency_meter_tb(

);

localparam COUNTER_BITS=14;
// oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
localparam OVERSAMPLING_BITS=3; //3;
// filter K right shift
localparam FILTER_K_SHIFT=5;
// output bits
localparam OUTPUT_BITS=32;
// internal filter bits
localparam INTERNAL_BITS=32;


// 100MHz
logic CLK;
// 800MHz
logic CLK_SHIFT;
// 800MHz inverted
logic CLK_SHIFTB;
// 200MHz
logic CLK_PARALLEL;
// reset, active 1
logic RESET;
// input frequency
logic FREQ_IN;

logic EDGE_FLAG;

logic [COUNTER_BITS + OVERSAMPLING_BITS:0] UNFILTERED_DURATION;
logic [OUTPUT_BITS-1:0] DURATION;


frequency_meter 
#(
    .COUNTER_BITS(COUNTER_BITS),
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    .OVERSAMPLING_BITS(OVERSAMPLING_BITS),
    // filter K right shift
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    // output bits
    .OUTPUT_BITS(OUTPUT_BITS),
    // internal filter bits
    .INTERNAL_BITS(INTERNAL_BITS)
) frequency_meter_inst
(
    // 100MHz
    .*
);


initial begin
    // reset, active 1
    #33 RESET = 1;
    #150.3 RESET = 0;
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

always begin
    #1000 $display("%f: %h  %h", clock_counter / 100000.0, UNFILTERED_DURATION, DURATION);
end

always begin
    FREQ_IN = 0;
    #200 ;
    $display("3145.23");
    repeat (33) begin
        #3145.23 FREQ_IN = 1;
        #3145.23 FREQ_IN = 0;
    end
    $display("2165.99");
    repeat (33) begin
        #2165.99 FREQ_IN = 1;
        #2176.33 FREQ_IN = 0;
    end
    $display("1178.34");
    repeat (33) begin
        #1178.34 FREQ_IN = 1;
        #1189.65 FREQ_IN = 0;
    end
    $display("1378.34");
    repeat (33) begin
        #1378.34 FREQ_IN = 1;
        #1389.65 FREQ_IN = 0;
    end
    $display("1178.34");
    repeat (33) begin
        #1178.34 FREQ_IN = 1;
        #1189.65 FREQ_IN = 0;
    end
    #1000 $finish();
end



endmodule
