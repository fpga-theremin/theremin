`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2020 05:52:06 PM
// Design Name: 
// Module Name: xor_bit_count
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


module xor_bit_count
#(
    // power of two of output size (3 for 8, 4 for 16, 5 for 32) 
    parameter OVERSAMPLING = 5,
    // oversampling bits
    parameter OVERSAMPLING_BITS = (1<<OVERSAMPLING)
)
(
    // 150MHz 
    input logic CLK,
    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,

    // input 1
    input logic [OVERSAMPLING_BITS-1:0] IN1,
    // input 2
    input logic [OVERSAMPLING_BITS-1:0] IN2,
    // IN1 ^ IN2 bit count
    output logic [OVERSAMPLING:0] XORBITS
);

logic [OVERSAMPLING:0] out_reg;

logic [OVERSAMPLING_BITS-1:0] xor_value;

always_comb xor_value = IN1 ^ IN2;
logic [OVERSAMPLING:0] bit_count;
always_comb XORBITS <= out_reg;

function logic[2:0] quadBitCount;
    input logic[3:0] inBits;
    begin
        quadBitCount = inBits[0]+inBits[1]+inBits[2]+inBits[3];
    end
endfunction

generate
    if (OVERSAMPLING==3) begin
        always_comb bit_count <= quadBitCount(xor_value[3:0]) + quadBitCount(xor_value[7:4]);
    end else if (OVERSAMPLING==4) begin
        always_comb bit_count <= (quadBitCount(xor_value[3:0]) + quadBitCount(xor_value[7:4]))
                               + (quadBitCount(xor_value[11:8]) + quadBitCount(xor_value[15:12]));
    end else if (OVERSAMPLING==5) begin
        always_comb bit_count <= ((quadBitCount(xor_value[3:0]) + quadBitCount(xor_value[7:4]))
                               +  (quadBitCount(xor_value[11:8]) + quadBitCount(xor_value[15:12])))
                               + ((quadBitCount(xor_value[19:16]) + quadBitCount(xor_value[23:20]))
                               +  (quadBitCount(xor_value[27:24]) + quadBitCount(xor_value[31:28])));
    end
endgenerate

always_ff @(posedge CLK) begin
    if (RESET) begin
        out_reg <= 'b0;
    end else begin
        out_reg <= bit_count;
    end
end

endmodule
