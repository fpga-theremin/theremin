`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 14:56:43
// Design Name: 
// Module Name: edge_to_pulse_position
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Converts sequence of raising/falling edge positions into sequence of pulse centers (averages two recent values).
//      New input comes on toggling of EDGE_TYPE signal.
//      It's useful for removing of PWM modulation from input signal.
//      Includes clock domain conversion.
//      When new output is available, PULSE_TYPE output is toggled, with PULSE_POSITION change.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module edge_to_pulse_position
#(
    parameter EDGE_POSITION_BITS = 16
)
(
    // clock signal, outputs are being changed on raising edge of this clock
    // input signals can be clocked by another clock - clock domain conversion will be made 
    input logic CLK_OUT,

    // reset, active 1
    input logic RESET,

    // 1: raising edge, 0: falling edge -- toggled when new edge is detected
    input logic EDGE_TYPE,
    // edge position value
    input logic [EDGE_POSITION_BITS-1 : 0] EDGE_POSITION,
    
    // 1: high (1) value, 0: low (0) value
    output logic PULSE_TYPE,
    // 1 for one CLK_OUT cycle when new value is ready
    output logic CHANGED,
    // pulse position -- middle point between last falling and raising edges ((raising + falling) / 2) << 1
    output logic [EDGE_POSITION_BITS : 0] PULSE_POSITION
);

logic prev_edge_type;
logic prev_edge_type_delay1;
logic [EDGE_POSITION_BITS-1 : 0] prev_edge_position;
always_ff @(posedge CLK_OUT) begin
    if (RESET) begin
        PULSE_POSITION <= 'b0;
        PULSE_TYPE <= 'b0;
        prev_edge_position <= 'b0;
        prev_edge_type <= 'b0;
        prev_edge_type_delay1 <= 'b0;
        CHANGED <= 'b0;
    end else begin
        if (prev_edge_type_delay1 != prev_edge_type) begin
            PULSE_POSITION <= prev_edge_position + EDGE_POSITION;
            PULSE_TYPE <= prev_edge_type;
            prev_edge_position <= EDGE_POSITION;
            CHANGED <= 'b1;
        end else begin
            CHANGED <= 'b0;
        end
        prev_edge_type_delay1 <= prev_edge_type;
        prev_edge_type <= EDGE_TYPE;
    end
end


endmodule
