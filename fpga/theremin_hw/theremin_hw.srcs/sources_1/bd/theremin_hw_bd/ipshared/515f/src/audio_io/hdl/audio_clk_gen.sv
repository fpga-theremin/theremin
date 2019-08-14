`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2019 03:49:16 PM
// Design Name: 
// Module Name: audio_clk_gen
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

/*
   PLL sysnthesis from 120MHz Cora Z7-10 source:
   Desired sample rate 48KHz, 24 bits per sample, stereo
   
   1) For theremin sensor, we need frequencies near 150MHz and 150MHz*4=600MHz
   2) It would be nice to have all clocks phase aligned with audio clock
   3) From sample clock 48000Hz, calculating MCLK clock = Fs*384 = 48000*384=18342000  
   4) Find closest multiply of MCLK near to 150MHz: 18342000 * 8 = 147456000
   5) Try to configure PLL to get frequency 147456000
   6) Closest found frequency is 147500000 - obtained using PLL from 120MHz clock.
   7) MCLK = 147500000/8 = 18437500
   8) Sample clock Fs = LRCK = MCLK / 384 = 48014.323
   9) Bit clock is BCLK = LRCK * 48 = MCLK / 8 = 2304687.5Hz

   Results to following clocks:
   CLK: source clock = 147.5MHz
   MCLK = CLK / 8 = 18.4375MHz
   LRCK = MCLK / 384 = BCLK / 48 = 48014.32 
   BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
   
*/

module audio_clk_gen(
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    input logic CLK,
    // Reset, active 1
    input logic RESET,
    
    // generated audio clocks
    
    // MCLK = CLK / 8 = 18.4375MHz
    output logic MCLK,
    // LRCK = MCLK / 384 = BCLK / 48 = 48014.32
    output logic LRCK,
    // BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
    output logic BCLK,
    
    // generated control signals for audio output shift registers (in CLK clock domain)
    // 1 for one CLK cycle to shift next bit out from shift register
    output logic OUT_SHIFT,
    // 1 for one CLK cycle to load new words into shift registers
    output logic LOAD,
    
    output logic IN_SHIFT
);

logic [2:0] clk_to_mclk_div;
logic [2:0] mclk_to_bclk_div;
logic [5:0] clk_to_bclk_div;
// lower 5 bits is bit number 0..23, top bit is left/right (WS, LRCK)
logic [5:0] bclk_to_lrck_div;

always_comb clk_to_mclk_div <= clk_to_bclk_div[2:0];
always_comb mclk_to_bclk_div <= clk_to_bclk_div[5:3];
always_comb MCLK <= clk_to_mclk_div[2];
always_comb BCLK <= mclk_to_bclk_div[2];
always_comb LRCK <= bclk_to_lrck_div[5];

logic out_shift;
logic load;
logic out_shift_or_load_update;
always_comb out_shift_or_load_update <= (clk_to_bclk_div == 6'b111110);
logic is_load_out;
always_comb is_load_out <= (bclk_to_lrck_div == 6'b000000);

always_comb OUT_SHIFT <= out_shift;
always_comb LOAD <= load;

logic in_shift;
logic in_shift_or_load_update;
always_comb in_shift_or_load_update <= (clk_to_bclk_div == 6'b011110);

always_comb IN_SHIFT <= in_shift;

always_ff @(posedge CLK) begin
    if (RESET) begin
        clk_to_bclk_div <= 'b0;
        bclk_to_lrck_div <= 'b0;
        out_shift <= 'b0;
        load <= 'b0;
        in_shift <= 'b0;
    end else begin
        if (out_shift | load) begin
            if (bclk_to_lrck_div[4:0] == 23) begin
                bclk_to_lrck_div[4:0] <= 'b0;                // lower 5 bits is bit number 0..23
                bclk_to_lrck_div[5] <= ~bclk_to_lrck_div[5]; // top bit is left/right (WS, LRCK)
            end else begin
                bclk_to_lrck_div[4:0] <= bclk_to_lrck_div[4:0] + 1;
            end
        end
        clk_to_bclk_div <= clk_to_bclk_div + 1;
        out_shift <= out_shift_or_load_update & ~is_load_out;
        load <= out_shift_or_load_update & is_load_out;
        in_shift <= in_shift_or_load_update;
    end
end


endmodule
