`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 08:59:11 PM
// Design Name: 
// Module Name: iserdes_period_measure_tb
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


module iserdes_period_measure_tb(

);

localparam COUNTER_BITS=16;

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
logic [COUNTER_BITS-1:0] DURATION;

iserdes_period_measure
#(
    .COUNTER_BITS(COUNTER_BITS),
    .DELAY_INPUT(0)
) iserdes_period_measure_inst
(
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

always @(negedge EDGE_FLAG) begin
    @(posedge CLK) #2 $display("%f: %h", clock_counter / 100000.0, DURATION);
end

always begin
    FREQ_IN = 0;
    #200 ;
    $display("5145.23");
    repeat (23) begin
        #5145.23 FREQ_IN = ~FREQ_IN;
    end
    $display("1145.23/2347.6");
    repeat (33) begin
        #1145.23 FREQ_IN = ~FREQ_IN;
        #2345.6 FREQ_IN = ~FREQ_IN;
    end
    $display("4165.99");
    repeat (13) begin
        #4165.99 FREQ_IN = ~FREQ_IN;
    end
    $display("3178.34");
    repeat (13) begin
        #3178.34 FREQ_IN = ~FREQ_IN;
    end
    $display("1378.34");
    repeat (13) begin
        #1378.34 FREQ_IN = ~FREQ_IN;
    end
    $display("2178.34");
    repeat (13) begin
        #2178.34 FREQ_IN = ~FREQ_IN;
    end
    #100 $finish();
end


endmodule
