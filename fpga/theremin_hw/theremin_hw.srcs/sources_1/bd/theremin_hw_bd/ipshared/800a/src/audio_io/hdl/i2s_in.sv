`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2019 08:15:45 AM
// Design Name: 
// Module Name: i2s_in
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


module i2s_in(
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    input logic CLK,
    // Reset, active 1
    input logic RESET,

    output logic [23:0] LEFT_CHANNEL,
    output logic [23:0] RIGHT_CHANNEL,
    
    input logic I2S_DATA_IN,
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    input logic IN_SHIFT,
    // 1 for one CLK cycle to load new words into shift registers
    input logic LOAD
);
    
logic [47:0] shift_reg;
always_ff @(posedge CLK) begin
    if (RESET) begin
        shift_reg <= 'b0;
    end else begin
        if (IN_SHIFT)
            shift_reg <= {shift_reg[46:0], I2S_DATA_IN};
    end
end

logic [23:0] left_reg;
logic [23:0] right_reg;
always_comb LEFT_CHANNEL <= left_reg;
always_comb RIGHT_CHANNEL <= right_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        left_reg <= 'b0;
        right_reg <= 'b0;
    end else if (LOAD) begin
        left_reg <= shift_reg[47:24];
        right_reg <= shift_reg[23:0];
    end
end
    
endmodule
