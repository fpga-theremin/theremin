`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2019 08:55:32 AM
// Design Name: 
// Module Name: encoders_tracker
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


module encoders_tracker
#(
    parameter ENCODER_POSITION_BITS = 4,
    parameter BUTTON_STATE_DURATION_BITS = 7,
    parameter ENCODER_COUNT = 5,
    parameter BUTTON_COUNT = 1
)
(
    input logic CLK,
    input logic RESET,
    input logic [ENCODER_COUNT*3 + BUTTON_COUNT - 1:0] DEBOUNCED,
    input logic [ENCODER_COUNT*3 + BUTTON_COUNT - 1:0] CHANGE_FLAGS,
    input logic UPDATED,
    output logic [ENCODER_POSITION_BITS*2 + BUTTON_STATE_DURATION_BITS : 0] ENCODERS[ENCODER_COUNT],
    output logic [BUTTON_STATE_DURATION_BITS : 0] BUTTONS[BUTTON_COUNT]
);

typedef struct packed {
    logic btn_state;
    logic [BUTTON_STATE_DURATION_BITS-1:0] btn_state_duration;
    logic [ENCODER_POSITION_BITS-1:0] position0;
    logic [ENCODER_POSITION_BITS-1:0] position1;
} encoder_state_t;

generate
    genvar i;
    // generate ENCODER_COUNT encoders
    for (i = 0; i < ENCODER_COUNT; i = i + 1) begin
        encoder_state_t encoder;
        assign ENCODERS[i] = encoder;
        button_state_tracker
        #(
            .BUTTON_STATE_DURATION_BITS(BUTTON_STATE_DURATION_BITS)
        )
        enc_button_state_tracker_inst
        (
            .CLK,
            .RESET,
            .BTN_VALUE(DEBOUNCED[i*3 + 2]),
            .BTN_VALUE_FLAG(CHANGE_FLAGS[i*3 + 2]
                // reset button state duration on encoder rotation as well 
                | CHANGE_FLAGS[i*3 + 1] | CHANGE_FLAGS[i*3 + 0]
            ),
            .UPDATED,
            .BTN_STATE(encoder.btn_state),
            .BTN_STATE_DURATION(encoder.btn_state_duration)
        );
        encoder_position_tracker
        #(
            .ENCODER_POSITION_BITS(ENCODER_POSITION_BITS)
        )
        encoder_position_tracker_inst
        (
            .CLK,
            .RESET,
            // encoder A signal value
            .ENC_A_VALUE(DEBOUNCED[i*3 + 0]),
            // 1 if encoder A signal value is changed
            .ENC_A_FLAG(CHANGE_FLAGS[i*3 + 0]),
            // encoder B signal value
            .ENC_B_VALUE(DEBOUNCED[i*3 + 1]),
            // 1 if encoder B signal value is changed
            .ENC_B_FLAG(CHANGE_FLAGS[i*3 + 1]),
            // encoder button (C) signal value
            .ENC_BTN(DEBOUNCED[i*3 + 2]),
            // 1 to request update
            .UPDATED,
            // encoder position for button in normal state
            .POS0(encoder.position0),
            // encoder position for button in pressed state
            .POS1(encoder.position1)
        );
    end
    // generate BUTTON_COUNT buttons
    for (i = 0; i < BUTTON_COUNT; i = i + 1) begin
    button_state_tracker
    #(
        .BUTTON_STATE_DURATION_BITS(BUTTON_STATE_DURATION_BITS)
    )
    button0_state_tracker_inst
    (
        .CLK,
        .RESET,
        .BTN_VALUE(DEBOUNCED[ENCODER_COUNT*3 + i]),
        .BTN_VALUE_FLAG(CHANGE_FLAGS[ENCODER_COUNT*3 + i]),
        .UPDATED,
        .BTN_STATE(BUTTONS[i][BUTTON_STATE_DURATION_BITS]),
        .BTN_STATE_DURATION(BUTTONS[i][BUTTON_STATE_DURATION_BITS-1:0])
    );
    end
endgenerate

endmodule
