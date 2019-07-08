`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 05:20:56 PM
// Design Name: 
// Module Name: fir_filter_stage_kpow2_tb
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


module fir_filter_stage_kpow2_tb(

    );

logic CLK;
logic RESET;
logic PHASE;
    
logic [31:0] IN_VALUE;
logic [31:0] OUT_VALUE;

fir_filter_stage_kpow2 fir_filter_stage_kpow2_inst
(
    .*
);

initial begin
    // reset, active 1
    #33 RESET = 1;
    #150 RESET = 0;
end

int clk_counter = 0;

always begin
    // 100MHz
    #5.0 CLK = 0;
    #5.0 CLK = 1; PHASE = 1;
    clk_counter++;
    #5.0 CLK = 0;
    #5.0 CLK = 1; PHASE = 0;
    $display("%f    %h   %h", clk_counter / 50000.0, IN_VALUE, OUT_VALUE);
end

initial begin
    IN_VALUE = 0;
    #300;
    
    #24300 IN_VALUE = 32'h12000000;
    #32300 IN_VALUE = 32'h23000000;
    #23300 IN_VALUE = 32'h45000000;
    #84400 IN_VALUE = 32'h15000000;
    #94400 IN_VALUE = 32'h55000000;
    
    #110000 $finish();
    
end

endmodule
