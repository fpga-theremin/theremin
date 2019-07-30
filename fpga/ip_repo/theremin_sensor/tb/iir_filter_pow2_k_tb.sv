`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2019 09:22:11 AM
// Design Name: 
// Module Name: iir_filter_pow2_k_tb
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


module iir_filter_pow2_k_tb(

    );


localparam FILTER_K_SHIFT = 6;
localparam DATA_BITS = 32;
localparam STAGE_COUNT = 4;

logic CLK;
logic RESET;
    
logic [31:0] IN_VALUE_A;
logic [31:0] OUT_VALUE_A;
logic [31:0] IN_VALUE_B;
logic [31:0] OUT_VALUE_B;
logic [2:0] MAX_STAGE;

always_comb MAX_STAGE <= 3'b011;

//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_rd_data;
//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_wr_data;
//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_in_value;
//logic [3:0] debug_stage_index;

iir_filter_pow2_k
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(DATA_BITS)
)
iir_filter_pow2_k_inst
(
    .*
);

initial begin
    // reset, active 1
    #3 @(posedge CLK) #1 RESET = 1;
    #150 @(posedge CLK) #1 RESET = 0;
end

int clk_counter = 0;

always begin
    // 100MHz
    #5 CLK = 0;
    #5 CLK = 1;
    clk_counter++;
    #5 CLK = 0;
    #5 CLK = 1;
    if ((clk_counter & 4'b1111) == 'b1111)
        $display("%f    %h   %h         %h   %h", clk_counter / 50000.0, IN_VALUE_A, OUT_VALUE_A, IN_VALUE_B, OUT_VALUE_B);
end

initial begin
    IN_VALUE_A = 0;
    #300;
    
    #124300 @(posedge CLK) #1 IN_VALUE_A = 32'h12000000;
    #132300 @(posedge CLK) #1 IN_VALUE_A = 32'h23000000;
    #123300 @(posedge CLK) #1 IN_VALUE_A = 32'h45000000;
    #184400 @(posedge CLK) #1 IN_VALUE_A = 32'h15000000;
    #194400 @(posedge CLK) #1 IN_VALUE_A = 32'h55000000;
    #194400 @(posedge CLK) #1 IN_VALUE_A = 32'hab000000;
    #194400 @(posedge CLK) #1 IN_VALUE_A = 32'h67000000;
    
    repeat(200) begin
    #11840 @(posedge CLK) #1 IN_VALUE_A = 32'h25670000;
    #11840 @(posedge CLK) #1 IN_VALUE_A = 32'h25660000;
    end
    
    //#310000 $finish();
    
end

initial begin
    IN_VALUE_B = 0;
    #300;
    
    #135678 @(posedge CLK) #1 IN_VALUE_B = 32'h12000000;
    #131234 @(posedge CLK) #1 IN_VALUE_B = 32'h23000000;
    #131876 @(posedge CLK) #1 IN_VALUE_B = 32'h45000000;
    #173251 @(posedge CLK) #1 IN_VALUE_B = 32'h15000000;
    #138721 @(posedge CLK) #1 IN_VALUE_B = 32'h55000000;
    
    repeat(200) begin
    #12412 @(posedge CLK) #1 IN_VALUE_B = 32'h25670000;
    #13123 @(posedge CLK) #1 IN_VALUE_B = 32'h25660000;
    end
    
    #310000 $finish();
    
end

endmodule
