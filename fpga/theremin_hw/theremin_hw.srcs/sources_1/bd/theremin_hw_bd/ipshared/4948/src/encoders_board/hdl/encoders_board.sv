`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2019 11:09:50 AM
// Design Name: 
// Module Name: encoders_board
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


module encoders_board(
    input CLK,
    input RESET,
    
    // for reading encoders and button signals using MUX
    
    // MUX address for multiplexing N buttons into one MUX_OUT
    output logic [3:0] MUX_ADDR,
    // input value from MUX (MUX_OUT <= button[MUX_ADDR])
    input logic MUX_OUT,

    // exposing processed state as controller registers
    
    // packed state of encoders 0, 1
    // [31]    encoder1 button state
    // [30:24] encoder1 button state duration
    // [23:20] encoder1 pressed state position
    // [19:16] encoder1 normal state position
    // [15]    encoder0 button state
    // [14:8]  encoder0 button state duration
    // [7:4]   encoder0 pressed state position
    // [3:0]   encoder0 normal state position
    output logic[31:0] R0,
    // packed state of encoders 2, 3
    // [31]    encoder3 button state
    // [30:24] encoder3 button state duration
    // [23:20] encoder3 pressed state position
    // [19:16] encoder3 normal state position
    // [15]    encoder2 button state
    // [14:8]  encoder2 button state duration
    // [7:4]   encoder2 pressed state position
    // [3:0]   encoder2 normal state position
    output logic[31:0] R1,
    // packed state of encoder 4, button and last change counter
    // [31]    button state
    // [30:24] button state duration
    // [23:16] duration (in 100ms intervals) since last change of any control
    // [15]    encoder4 button state
    // [14:8]  encoder4 button state duration
    // [7:4]   encoder4 pressed state position
    // [3:0]   encoder4 normal state position
    output logic[31:0] R2
);

// debounced output values: bit DEBOUNCED[i] is debounced value of MUX[i] input
logic [15:0] DEBOUNCED;
// change flags, CHANGE_FLAGS[i] set to 1 means that DEBOUNCED[i] is changed since
// last UPDATED signal
logic [15:0] CHANGE_FLAGS;
// 1 for one clock cycle after DEBOUNCED and CHANGE_FLAGS are updated
logic UPDATED;

mux_debouncer
#(
    // Number of bits in CLK divider to produce MUX switching frequency.
    // For  CLK_DIV_BITS = 5, /32 divider gives 3MHz for 100MHz CLK.
    .CLK_DIV_BITS(5),
    // Number of address bits for MUX. MUX has (1<<MUX_ADDR_BITS) inputs.
    // One input is read once per CLK/(1<<CLK_DIV_BITS)/(1<<MUX_ADDR_BITS)
    // For 5 bits in divider and bits in address, each input is checked once
    // per 100MHz/32/16 == 200KHz interval 
    .MUX_ADDR_BITS(4),
    // Debouncing counter determines how many cycles input should remain in the same state
    // after change to propagate this change to output.
    // For DEBOUNCE_COUNTER_BITS == 12, it's input check interval / 4096.
    // For default settings, 200KHz/4096 == 47Hz is max frequency of input change (unbounced)
    // which can be noticed.
    .DEBOUNCE_COUNTER_BITS(12),
    // Outputs are updated once per CLK/(1<<CLK_DIV_BITS)/(1<<MUX_ADDR_BITS)/(1<<UPDATE_DIVIDER_BITS)
    // For default settings it's approximately once per 100ms
    .UPDATE_DIVIDER_BITS(11)
)
mux_debouncer_inst
(
    .*
//    // clock, active posedge
//    .CLK,
//    // reset, active 1
//    .RESET,
//    // MUX address for multiplexing N buttons into one MUX_OUT
//    .MUX_ADDR,
//    // input value from MUX (MUX_OUT <= button[MUX_ADDR])
//    .MUX_OUT,
//    // debounced output values: bit DEBOUNCED[i] is debounced value of MUX[i] input
//    .DEBOUNCED,
//    // change flags, CHANGE_FLAGS[i] set to 1 means that DEBOUNCED[i] is changed since
//    // last UPDATED signal
//    .CHANGE_FLAGS,
//    // 1 for one clock cycle after DEBOUNCED and CHANGE_FLAGS are updated
//    .UPDATED
);

// each encoder output is packed value:
// [15] encoder button state
// [14:8] encoder button state duration in 100ms cycles
// [7:4] encoder rotation position for button pressed
// [3:0] encoder rotation position for button not pressed
logic [15 : 0] ENCODERS[5];
// each button output is packed value:
// [7] button state
// [6:0] button state duration in 100ms cycles
logic [7 : 0] BUTTONS[1];

encoders_tracker
#(
    .ENCODER_POSITION_BITS(4),
    .BUTTON_STATE_DURATION_BITS(7),
    .ENCODER_COUNT(5),
    .BUTTON_COUNT(1)
)
encoders_tracker_inst
(
    .*
);

logic [7:0] last_change_counter_reg;

always_ff @(posedge CLK) begin
    if (RESET | (UPDATED & |CHANGE_FLAGS)) begin
        last_change_counter_reg <= '0;
    end else begin
        if (UPDATED) begin
            if (last_change_counter_reg != 8'hff)
                last_change_counter_reg <= last_change_counter_reg + 1;
        end
    end
end

always_comb R0[15:0] <= ENCODERS[0];
always_comb R0[31:16] <= ENCODERS[1];
always_comb R1[15:0] <= ENCODERS[2];
always_comb R1[31:16] <= ENCODERS[3];
always_comb R2[15:0] <= ENCODERS[4];
always_comb R2[23:16] <= last_change_counter_reg;
always_comb R2[31:24] <= BUTTONS[0];


endmodule
