`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: coolreader.org
// Engineer: Vadim Lopatin 
// 
// Create Date: 07/03/2019 08:58:22 AM
// Design Name: 
// Module Name: encoder_position_tracker
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Tracker for encoder position 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*

  Encoders function:

  ===========================> CW
           ______        _____
  A  _____/      \______/
     _        _______
  B   \______/       \______/

  CCW <=======================
*/

module encoder_position_tracker
#(
    parameter ENCODER_POSITION_BITS = 4
)
(
    input logic CLK,
    input logic RESET,
    // encoder A signal value
    input logic ENC_A_VALUE,
    // 1 if encoder A signal value is changed
    input logic ENC_A_FLAG,
    // encoder B signal value
    input logic ENC_B_VALUE,
    // 1 if encoder B signal value is changed
    input logic ENC_B_FLAG,
    // encoder button (C) signal value
    input logic ENC_BTN,
    // 1 to request update
    input logic UPDATED,
    // encoder position for button in normal state
    output logic [ENCODER_POSITION_BITS-1:0] POS0,
    // encoder position for button in pressed state
    output logic [ENCODER_POSITION_BITS-1:0] POS1
);
    
logic [ENCODER_POSITION_BITS-1:0] pos0_reg;
logic [ENCODER_POSITION_BITS-1:0] pos1_reg;
always_comb POS0 <= pos0_reg;
always_comb POS1 <= pos1_reg;

logic moved_cw;
logic moved_ccw;
// for A transition 0->1, B is 0 for clockwise rotation, 1 for counter-clockwise rotation
always_comb moved_cw <= (ENC_A_FLAG & ENC_A_VALUE) & ~ENC_B_VALUE & UPDATED;
always_comb moved_ccw <= (ENC_A_FLAG & ENC_A_VALUE) & ENC_B_VALUE & UPDATED;

always_ff @(posedge CLK) begin
    if (RESET) begin
        pos0_reg <= 'b0;
        pos1_reg <= 'b0;
    end else begin
        if (ENC_BTN) begin
            // update counter for pressed state
            if (moved_cw)
                pos1_reg <= pos1_reg + 1;
            else if (moved_ccw)
                pos1_reg <= pos1_reg - 1;
        end else begin
            // update counter for normal state
            if (moved_cw)
                pos0_reg <= pos0_reg + 1;
            else if (moved_ccw)
                pos0_reg <= pos0_reg - 1;
        end
    end
end
    
endmodule
