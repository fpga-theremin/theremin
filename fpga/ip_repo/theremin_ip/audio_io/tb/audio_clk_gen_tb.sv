`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2019 04:35:08 PM
// Design Name: 
// Module Name: audio_clk_gen_tb
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


module audio_clk_gen_tb(

    );


logic CLK;
// Reset, active 1
logic RESET;

// generated audio clocks

// MCLK = CLK / 8 = 18.4375MHz
logic MCLK;
// LRCK = MCLK / 384 = BCLK / 48 = 48014.32
logic LRCK;
// BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
logic BCLK;

logic OUT_SHIFT;
logic LOAD;
logic IN_SHIFT;

audio_clk_gen audio_clk_gen_inst (
    .*
);

// reset signal
initial begin
    #5 RESET = 0;
    #15 RESET = 1;
    #115 RESET = 0;
end

// clock 150MHz
always begin
    #3.333333 CLK = 1;
    #3.333333 CLK = 0;
end

endmodule
