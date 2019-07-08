`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 11:44:39 AM
// Design Name: 
// Module Name: iserdes_ddr_tb
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


module iserdes_ddr_tb(

    );

// 800MHz
logic CLK_SHIFT;
logic CLK_SHIFTB;
// 200MHz
logic CLK_OUT;
logic CLK;
// reset, active 1
logic RESET;
// serial input
logic IN;
// parallel output
logic [7:0] OUT;


iserdes_ddr
#(
    .DELAY_INPUT(1)
)
iserdes_ddr_inst
(
    .CLK_PARALLEL(CLK_OUT),
    .*
);

initial begin
    // reset, active 1
    #33 RESET = 1;
    #150 RESET = 0;
end

always begin
    // 100MHz
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1;
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_OUT = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_OUT = 1; CLK = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_OUT = 0;
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; 
    #0.625 CLK_SHIFT=0; CLK_SHIFTB = 1; 
    #0.625 CLK_SHIFT=1; CLK_SHIFTB = 0; CLK_OUT = 1; CLK = 1;
end

always begin
    repeat (3) begin
        #45.23 IN = 1;
        #45.23 IN = 0;
    end
    repeat (3) begin
        #65.99 IN = 1;
        #76.33 IN = 0;
    end
    repeat (3) begin
        #78.34 IN = 1;
        #89.65 IN = 0;
    end
    #100 $finish();
end

endmodule
