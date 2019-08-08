`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 12:36:31 PM
// Design Name: 
// Module Name: lcd_controller
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


module lcd_controller
#(
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    parameter BURST_SIZE = 8,
    parameter HPIXELS = 800,
    parameter VPIXELS = 480,
    parameter HBP = 2,
    parameter VBP = 2,
    parameter HSW = 10,
    parameter VSW = 2,
    parameter HFP = 2,
    parameter VFP = 2,
    parameter HSYNC_POLARITY = 0,
    parameter VSYNC_POLARITY = 0,
    parameter Y_BITS = ( (VPIXELS+VBP+VSW+VFP) <= 256 ? 8
                       : (VPIXELS+VBP+VSW+VFP) <= 512 ? 9
                       : (VPIXELS+VBP+VSW+VFP) <= 1024 ? 10
                       :                                 11 )
)
(
    // DMA clock
    input logic CLK,
    // reset signal, active 1
    input logic RESET,

    // RGB interface
    // pixel clock
    input logic CLK_PXCLK,
    // horizontal sync
    output logic HSYNC,
    // vertical sync
    output logic VSYNC,
    // data enable
    output logic DE,
    // pixel value
    output logic [15:0] PIXEL_DATA,
    
    // current Y position (row index); rows 0..VPIXELS-1 are visible, in CLK_PXCLK domain
    output logic [Y_BITS-1:0] ROW_INDEX,
    
    // backlight brightness setting, 0=dark, 255=light
    input logic [7:0] BACKLIGHT_BRIGHTNESS,
    // backlight PWM control output
    output logic BACKLIGHT_PWM,


    // DMA interface, in CLK clock domain
    // start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
    input logic [28:0] BUFFER_START_ADDRESS,
    
    // read start address for DMA burst read operation 
    output logic [28:0] DMA_RD_ADDR,
    // 1 for one CLK cycle to start new DMA burst read operation (use only if DMA_READY==1)
    output logic DMA_START,
    // 1 when DMA is ready to accept new operation
    input logic DMA_READY,
    // data read from DMA (when DMA_RD_DATA_VALID==1)
    input logic [31:0] DMA_RD_DATA,
    // 1 for one CLK cycle, when new data becomes available and should be written to FIFO 
    input logic DMA_RD_DATA_VALID
    //, output logic [14:0] debug_dma_burst_count
    //, output logic debug_running
);

logic pwm;
logic [12:0] pwm_counter;

always @(posedge CLK_PXCLK) begin
    if (RESET) begin
        pwm_counter <= 'b0;
        pwm <= 'b0;
    end else begin
        pwm_counter <= pwm_counter + 1;
        if (pwm_counter[4:0] == 5'b11111) begin
            if (pwm_counter[12:5] == 8'b11111111)
                pwm <= 1'b1;
            else if (pwm_counter[12:5] == BACKLIGHT_BRIGHTNESS)
                pwm <= 1'b0;
        end
    end
end
always_comb BACKLIGHT_PWM <= pwm;

logic hsync;
logic vsync;
logic de;
logic start;
logic stop;

logic hsync_delay;
logic vsync_delay;
logic de_delay;

always_ff @(posedge CLK_PXCLK) begin
    hsync_delay <= hsync;
    vsync_delay <= vsync;
    de_delay <= de;
end

always_comb HSYNC <= hsync_delay;
always_comb VSYNC <= vsync_delay;
always_comb DE <= de_delay;

lcd_clk_gen
#(
    .HPIXELS(HPIXELS),
    .VPIXELS(VPIXELS),
    .HBP(HBP),
    .VBP(VBP),
    .HSW(HSW),
    .VSW(VSW),
    .HFP(HFP),
    .VFP(VFP),
    .HSYNC_POLARITY(HSYNC_POLARITY),
    .VSYNC_POLARITY(VSYNC_POLARITY)
) lcd_clk_gen_inst
(
    .CLK_PXCLK,
    .RESET,
    
    .HSYNC(hsync),
    .VSYNC(vsync),
    .DE(de),
    .X(),
    .Y(ROW_INDEX),
    // 1 for one cycle near before next frame begin
    .BEFORE_FRAME(start),
    // 1 for one cycle near after frame ended
    .AFTER_FRAME(stop)
);

lcd_dma_fifo
#(
    // number of 32bit words to read using DMA
    .BUFFER_SIZE(HPIXELS*VPIXELS/2),
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    .BURST_SIZE(BURST_SIZE)
)
lcd_dma_fifo_inst 
(
    // DMA and FIFO input clock
    .CLK,
    // output clock
    .CLK_PXCLK,
    // reset signal, active 1
    .RESET,

    // DMA interface, in CLK clock domain
    // start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
    .BUFFER_START_ADDRESS,
    
    // read start address for DMA burst read operation 
    .DMA_RD_ADDR,
    // 1 for one CLK cycle to start new DMA burst read operation (use only if DMA_READY==1)
    .DMA_START,
    // 1 when DMA is ready to accept new operation
    .DMA_READY,
    // data read from DMA (when DMA_RD_DATA_VALID==1)
    .DMA_RD_DATA,
    // 1 for one CLK cycle, when new data becomes available and should be written to FIFO 
    .DMA_RD_DATA_VALID,

    // buffer start/stop (in CLK_PXCLK domain)     
    // 1 for one CLK_PXCLK cycle near before next frame begin - DMA may start prefetching
    .START(start),
    // 1 for one CLK_PXCLK cycle near after frame ended - DMA should stop operation
    .STOP(stop),

    // interface to read data from queue, in CLK_PXCLK domain
    // 1 for one CLK_PXCLK cycle to read next word
    .RDEN(de),
    // data read from queue, appears in next CLK_PXCLK cycle after RDEN=1
    .RDDATA(PIXEL_DATA)

//    , output logic [31:0] debug_fifo_data_out
//    , output logic debug_fifo_almost_empty // sync to pxclk
//    , .debug_dma_burst_count
//    , .debug_running

);



endmodule
