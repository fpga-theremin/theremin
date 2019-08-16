`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2019 08:21:44 AM
// Design Name: 
// Module Name: theremin_audio_io
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


module theremin_audio_io(
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    input logic CLK,
    // Reset, active 1
    input logic RESET,
    
    // generated audio clocks
    
    // MCLK = CLK / 8 = 18.4375MHz
    output logic MCLK,
    // LRCK(WS) = MCLK / 384 = BCLK / 48 = 48014.32
    output logic LRCK,
    // BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
    output logic BCLK,
    // serial output for channel 0 (Line Out)
    output logic I2S_DATA_OUT0,
    // serial output for channel 1 (Phones Out)
    output logic I2S_DATA_OUT1,
    // I2S data input for Line In
    input logic I2S_DATA_IN,


    // when 1, audio IRQ is enabled
    input logic INTERRUPT_EN,
    // audio interrupt request, set to 1 in the beginning of new sample cycle, reset to 0 afer ACK
    output logic IRQ,
    // audio IRQ acknowlegement
    input logic ACK,

    // Audio Out Channel 0 (Line Out) data
    // left
    input logic [23:0] OUT_LEFT_CHANNEL0,
    // right
    input logic [23:0] OUT_RIGHT_CHANNEL0,
    
    // Audio Out Channel 1 (Phones Out) data
    // left
    input logic [23:0] OUT_LEFT_CHANNEL1,
    // right
    input logic [23:0] OUT_RIGHT_CHANNEL1,

    // Audio Input channel 0 (Line In)
    // left
    output logic [23:0] IN_LEFT_CHANNEL,
    // right
    output logic [23:0] IN_RIGHT_CHANNEL
    
);

// generated control signals for audio output shift registers (in CLK clock domain)
// 1 for one CLK cycle to shift next bit out from shift register
logic out_shift;
// 1 for one CLK cycle to load new words into shift registers
logic load;

logic in_shift;

audio_clk_gen audio_clk_gen_inst (
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    .CLK,
    // Reset, active 1
    .RESET,
    
    // generated audio clocks
    
    // MCLK = CLK / 8 = 18.4375MHz
    .MCLK,
    // LRCK = MCLK / 384 = BCLK / 48 = 48014.32
    .LRCK,
    // BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
    .BCLK,
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    .OUT_SHIFT(out_shift),
    // 1 for one CLK cycle to load new words into shift registers
    .LOAD(load),
    
    .IN_SHIFT(in_shift)
);

i2s_out i2s_out_inst0 (
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    .CLK,
    // Reset, active 1
    .RESET,

    .LEFT_CHANNEL(OUT_LEFT_CHANNEL0),
    .RIGHT_CHANNEL(OUT_RIGHT_CHANNEL0),
    
    .I2S_DATA_OUT(I2S_DATA_OUT0),
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    .OUT_SHIFT(out_shift),
    // 1 for one CLK cycle to load new words into shift registers
    .LOAD(load)
);

i2s_out i2s_out_inst1 (
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    .CLK,
    // Reset, active 1
    .RESET,

    .LEFT_CHANNEL(OUT_LEFT_CHANNEL1),
    .RIGHT_CHANNEL(OUT_RIGHT_CHANNEL1),
    
    .I2S_DATA_OUT(I2S_DATA_OUT1),
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    .OUT_SHIFT(out_shift),
    // 1 for one CLK cycle to load new words into shift registers
    .LOAD(load)
);



i2s_in i2s_in_inst0 (
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    .CLK,
    // Reset, active 1
    .RESET,

    .LEFT_CHANNEL(IN_LEFT_CHANNEL),
    .RIGHT_CHANNEL(IN_RIGHT_CHANNEL),
    
    .I2S_DATA_IN,
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    .IN_SHIFT(in_shift),
    // 1 for one CLK cycle to load new words into shift registers
    .LOAD(load)
);

// IRQ logic
logic irq;
always_comb IRQ <= irq;
always_ff @(posedge CLK) begin
    if (RESET) begin
        irq <= 'b0;
    end else begin
        if (load & INTERRUPT_EN) begin
            irq <= 1'b1;
        end else if (irq & ACK) begin
            irq <= 1'b0;
        end
    end
end


endmodule
