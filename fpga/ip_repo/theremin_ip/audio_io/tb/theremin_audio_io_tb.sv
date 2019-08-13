`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2019 08:45:32 AM
// Design Name: 
// Module Name: theremin_audio_io_tb
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


module theremin_audio_io_tb(

    );

// Source clock near to 147.457MHz -> =147.500MHz from PLL
logic CLK;
// Reset, active 1
logic RESET;

// generated audio clocks

// MCLK = CLK / 8 = 18.4375MHz
logic MCLK;
// LRCK(WS) = MCLK / 384 = BCLK / 48 = 48014.32
logic LRCK;
// BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
logic BCLK;
// serial output for channel 0 (Line Out)
logic I2S_DATA_OUT0;
// serial output for channel 1 (Phones Out)
logic I2S_DATA_OUT1;
// I2S data input for Line In
logic I2S_DATA_IN;


// Audio Out Channel 0 (Line Out) data
// left
logic [23:0] OUT_LEFT_CHANNEL0;
// right
logic [23:0] OUT_RIGHT_CHANNEL0;

// Audio Out Channel 1 (Phones Out) data
// left
logic [23:0] OUT_LEFT_CHANNEL1;
// right
logic [23:0] OUT_RIGHT_CHANNEL1;

// Audio Input channel 0 (Line In)
// left
logic [23:0] IN_LEFT_CHANNEL;
// right
logic [23:0] IN_RIGHT_CHANNEL;

// audio interrupt request, set to 1 in the beginning of new sample cycle, reset to 0 afer ACK
logic IRQ;
// audio IRQ acknowlegement
logic ACK;

logic INTERRUPT_EN;

theremin_audio_io theremin_audio_io_inst (
    .*
);

// loopback - from Line Out to Line In
always_comb I2S_DATA_IN <= I2S_DATA_OUT0;
initial begin
    ACK = 0;
    INTERRUPT_EN = 1;
    OUT_LEFT_CHANNEL0 = 0;
    OUT_RIGHT_CHANNEL0 = 0;
    OUT_LEFT_CHANNEL1 = 0;
    OUT_RIGHT_CHANNEL1 = 0;
    #3 RESET = 1;
    #153 RESET = 0;
    
end

always begin
    @(posedge IRQ) #5 ;
    $display("AUDIO_IN: %h %h", IN_LEFT_CHANNEL, IN_RIGHT_CHANNEL);
    OUT_LEFT_CHANNEL0 = 24'haaaaaa;
    OUT_RIGHT_CHANNEL0 = 24'h555555;
    OUT_LEFT_CHANNEL1 = 24'hffffff;
    OUT_RIGHT_CHANNEL1 = 24'h000000;
    #100 @(posedge CLK) ACK = 1; @(posedge CLK) ACK = 0;

    @(posedge IRQ) #5 ;
    $display("AUDIO_IN: %h %h", IN_LEFT_CHANNEL, IN_RIGHT_CHANNEL);
    OUT_LEFT_CHANNEL0 = 24'h555555;
    OUT_RIGHT_CHANNEL0 = 24'haaaaaa;
    OUT_LEFT_CHANNEL1 = 24'hffffff;
    OUT_RIGHT_CHANNEL1 = 24'h000000;
    #100 @(posedge CLK) ACK = 1; @(posedge CLK) ACK = 0;

    @(posedge IRQ) #5 ;
    $display("AUDIO_IN: %h %h", IN_LEFT_CHANNEL, IN_RIGHT_CHANNEL);
    OUT_LEFT_CHANNEL0 = 24'hcdef11;
    OUT_RIGHT_CHANNEL0 = 24'h654321;
    OUT_LEFT_CHANNEL1 = 24'h123456;
    OUT_RIGHT_CHANNEL1 = 24'hfedcba;
    #200 @(posedge CLK) ACK = 1; @(posedge CLK) ACK = 0;

    @(posedge IRQ) #5 ;
    $display("AUDIO_IN: %h %h", IN_LEFT_CHANNEL, IN_RIGHT_CHANNEL);
    OUT_LEFT_CHANNEL0 = 24'h123456;
    OUT_RIGHT_CHANNEL0 = 24'hcccccc;
    OUT_LEFT_CHANNEL1 = 24'h333333;
    OUT_RIGHT_CHANNEL1 = 24'hcccccc;
    #150 @(posedge CLK) ACK = 1; @(posedge CLK) ACK = 0;

    @(posedge IRQ) #2 ;
    $display("AUDIO_IN: %h %h", IN_LEFT_CHANNEL, IN_RIGHT_CHANNEL);
    OUT_LEFT_CHANNEL0 = 24'hfedcba;
    OUT_RIGHT_CHANNEL0 = 24'habcdef;
    OUT_LEFT_CHANNEL1 = 24'h777777;
    OUT_RIGHT_CHANNEL1 = 24'h888888;
    #120 @(posedge CLK) ACK = 1; @(posedge CLK) ACK = 0;
end

always begin
    #3.3333 CLK = 0;
    #3.3333 CLK = 1;
end

endmodule
