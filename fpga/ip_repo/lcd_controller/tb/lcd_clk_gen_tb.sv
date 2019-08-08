`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2019 03:56:27 PM
// Design Name: 
// Module Name: lcd_clk_gen_tb
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


module lcd_clk_gen_tb(

    );


logic CLK_PXCLK;
logic RESET;

logic HSYNC;
logic VSYNC;
logic DE;
logic [9:0] X;
logic [8:0] Y;
// 1 for one cycle near before next frame begin
logic BEFORE_FRAME;
// 1 for one cycle near after frame ended
logic AFTER_FRAME;

lcd_clk_gen lcd_clk_gen_inst
(
    .*
);

initial begin
    #15 RESET = 1;
    #115 RESET = 0;
end

always begin
    #13.3333 CLK_PXCLK = 1;
    #13.3333 CLK_PXCLK = 0;
end

endmodule
