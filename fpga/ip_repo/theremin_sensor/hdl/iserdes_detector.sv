`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 12:12:30 PM
// Design Name: 
// Module Name: iserdes_detector
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


module iserdes_detector(
    input logic CLK,
    input logic RESET,
    input logic [7:0] IN,
    output logic CHANGED_FLAG,
    output logic [2:0] CHANGED_BIT
);

logic last_in;

always_ff @(posedge CLK)
    if (RESET)
        last_in <= 'b0;
    else
        last_in <= IN[7];

logic change_flag;
always_ff @(posedge CLK)
    change_flag <= (last_in != IN[7]);

always_comb CHANGED_FLAG <= change_flag;

logic [2:0] bit_number;

always_ff @(posedge CLK) begin
    if (last_in == IN[7])
        bit_number <= 3'b000;
    else if (IN[0] != last_in)
        bit_number <= 3'b000;
    else if (IN[1] != last_in)
        bit_number <= 3'b001;
    else if (IN[2] != last_in)
        bit_number <= 3'b010;
    else if (IN[3] != last_in)
        bit_number <= 3'b011;
    else if (IN[4] != last_in)
        bit_number <= 3'b100;
    else if (IN[5] != last_in)
        bit_number <= 3'b101;
    else if (IN[6] != last_in)
        bit_number <= 3'b110;
    else 
        bit_number <= 3'b111;
end
always_comb CHANGED_BIT <= bit_number;


endmodule
