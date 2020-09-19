`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2019 08:11:25 AM
// Design Name: 
// Module Name: i2s_out
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


module i2s_out(
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    input logic CLK,
    // Reset, active 1
    input logic RESET,

    input logic [23:0] LEFT_CHANNEL,
    input logic [23:0] RIGHT_CHANNEL,
    
    output logic I2S_DATA_OUT,
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    input logic OUT_SHIFT,
    // 1 for one CLK cycle to load new words into shift registers
    input logic LOAD
);

logic [47:0] shift_reg;
always_comb I2S_DATA_OUT <= shift_reg[47];

always_ff @(posedge CLK) begin
    if (RESET) begin
        shift_reg <= 'b0;
    end else begin
        if (LOAD) begin
            shift_reg <= {LEFT_CHANNEL, RIGHT_CHANNEL};
        end else if (OUT_SHIFT) begin
            shift_reg <= {shift_reg[46:0], 1'b0};
        end
    end
end

endmodule
