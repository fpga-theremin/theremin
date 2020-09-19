`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2019 09:35:23 AM
// Design Name: 
// Module Name: button_state_tracker
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


module button_state_tracker
#(
    parameter BUTTON_STATE_DURATION_BITS = 7
)
(
    input logic CLK,
    input logic RESET,
    input logic BTN_VALUE,
    input logic BTN_VALUE_FLAG,
    input logic UPDATED,
    output logic BTN_STATE,
    output logic [BUTTON_STATE_DURATION_BITS-1 : 0] BTN_STATE_DURATION
);

logic state_reg;
logic [BUTTON_STATE_DURATION_BITS-1  + 3 : 0] state_duration_reg;

always_comb BTN_STATE_DURATION <= state_duration_reg[BUTTON_STATE_DURATION_BITS-1  + 3 : 3];
always_comb BTN_STATE <= state_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        state_reg <= 1'b0;
        state_duration_reg <= 'b0;
    end else begin
        if (UPDATED) begin
            if (BTN_VALUE_FLAG) begin
                // btn value is changed
                state_duration_reg <= 0;
                state_reg <= BTN_VALUE;
            end else begin
                // btn value is unchanged
                // just increment state duration if not reached max value
                if (state_duration_reg != {(BUTTON_STATE_DURATION_BITS+3){1'b1}})
                    state_duration_reg <= state_duration_reg + 1;
            end
        end
    end
end

endmodule
