`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2019 09:51:25 AM
// Design Name: 
// Module Name: iir_multistage_dblchannel_tb
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


module iir_multistage_dblchannel_tb(

    );

localparam FILTER_K_SHIFT = 8;
localparam DATA_BITS = 32;
localparam STAGE_COUNT = 4;

logic CLK;
logic RESET;
    
logic [31:0] IN_VALUE_A;
logic [31:0] OUT_VALUE_A;
logic [31:0] IN_VALUE_B;
logic [31:0] OUT_VALUE_B;
logic [2:0] MAX_STAGE;

always_comb MAX_STAGE <= STAGE_COUNT - 1;

//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_diff_reg;
//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_adder_reg;

//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_rd_data;
//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_wr_data;
//logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_new_value;
//logic [3:0] debug_stage_index;
//logic debug_init_done;

iir_multistage_dblchannel
#(
    .FILTER_K_SHIFT(FILTER_K_SHIFT),
    .DATA_BITS(DATA_BITS)
)
iir_multistage_dblchannel_inst
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
    // 150MHz
    #3.333 CLK = 0;
    #3.333 CLK = 1;
end

always  begin
    @(posedge CLK) #4 if ((clk_counter & 3'b111) == 3'b111)
        $display("%f    %h   %h         %h   %h", clk_counter / 50000.0, IN_VALUE_A, OUT_VALUE_A, IN_VALUE_B, OUT_VALUE_B);
    clk_counter++;
end

//always  begin
//    @(posedge CLK) #5
//        $display("%f:    %h %h    %h %h    [%h]  new = %h  diff = %h  add = %h  rd = %h  wr = %h", clk_counter / 50000.0, IN_VALUE_A, OUT_VALUE_A, IN_VALUE_B, OUT_VALUE_B
//        , debug_stage_index
//        , debug_new_value
//        , debug_diff_reg
//        , debug_adder_reg
//        , debug_state_rd_data
//        , debug_state_wr_data
////logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_in_value;
//            );
//end

initial begin
    IN_VALUE_A = 0;
    #234;
    
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
    #558;
    
    #135678 @(posedge CLK) #1 IN_VALUE_B = 32'h56700000;
    #131234 @(posedge CLK) #1 IN_VALUE_B = 32'h45600000;
    #131876 @(posedge CLK) #1 IN_VALUE_B = 32'habcd0000;
    #173251 @(posedge CLK) #1 IN_VALUE_B = 32'h01000000;
    #138721 @(posedge CLK) #1 IN_VALUE_B = 32'h66660000;
    
    repeat(200) begin
    #12412 @(posedge CLK) #1 IN_VALUE_B = 32'h12345000;
    #13123 @(posedge CLK) #1 IN_VALUE_B = 32'h12346000;
    end
    
    #310000 $finish();
    
end

endmodule
