`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/29/2019 07:37:06 PM
// Design Name: 
// Module Name: clock_domain_adapter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Clock domain adapter  
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_domain_adapter
#(
    parameter DATA_WIDTH=12
)
(
    input logic CLK_IN,
    input logic CLK_OUT,

    input logic RESET,
    
    input logic CHANGE_FLAG_IN,
    input logic[DATA_WIDTH-1:0] DATA_IN,
    
    output logic CHANGE_FLAG_OUT,
    output logic[DATA_WIDTH-1:0] DATA_OUT
);

logic change_in_flip;
always_ff @(posedge CLK_IN) begin
    if (RESET) begin
        change_in_flip <= 'b0;
    end else begin
        if (CHANGE_FLAG_IN == 1'b1)
            change_in_flip <= ~change_in_flip;
    end
end

logic flip_delay1;
logic flip_delay2;
logic out_flag;
logic[DATA_WIDTH-1:0] out_reg;

always_ff @(posedge CLK_OUT) begin
    if (RESET) begin
        flip_delay1 <= 'b0;
        flip_delay2 <= 'b0;
        out_flag <= 'b0;
        out_reg <= 'b0;
    end else begin
        if (flip_delay1 != flip_delay2) begin
            out_flag <= 1'b1;
            out_reg <= DATA_IN;
        end else begin
            out_flag <= 1'b0;
        end
        flip_delay2 <= flip_delay1;
        flip_delay1 <= change_in_flip;
    end
end

always_comb CHANGE_FLAG_OUT <= out_flag;
always_comb DATA_OUT <= out_reg;

endmodule
