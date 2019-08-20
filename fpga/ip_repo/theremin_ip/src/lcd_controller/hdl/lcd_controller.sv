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
    parameter integer BURST_SIZE = 8,
    parameter integer HPIXELS = 800,
    parameter integer VPIXELS = 480,
    parameter integer HBP = 13, // 2
    parameter integer VBP = 23, // 2
    parameter integer HSW = 29, // 10
    parameter integer VSW = 9, // 2
    parameter integer HFP = 12, // 2
    parameter integer VFP = 8, // 2
    parameter integer HSYNC_POLARITY = 0,
    parameter integer VSYNC_POLARITY = 0,
    parameter integer Y_BITS = ( (VPIXELS+VBP+VSW+VFP) <= 256 ? 8
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
    
    // color of LED0 (4 bits per R, G, B)    
    input logic [11:0] RGB_LED_COLOR0,
    // color of LED0 (4 bits per R, G, B)    
    input logic [11:0] RGB_LED_COLOR1,

    // color led0 control output {r,g,b}
    output logic [2:0] LED0_PWM,
    // color led1 control output {r,g,b}
    output logic [2:0] LED1_PWM,
    
    
    // backlight brightness setting, 0=dark, 255=light
    input logic [7:0] BACKLIGHT_BRIGHTNESS,
    // backlight PWM control output
    output logic BACKLIGHT_PWM,


    // DMA interface, in CLK clock domain
    // start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
    input logic [29:0] BUFFER_START_ADDRESS,
    
    // read start address for DMA burst read operation 
    output logic [29:0] DMA_RD_ADDR,
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
logic [2:0] ledpwm0;
logic [2:0] ledpwm1;

logic [12:0] pwm_counter;

always @(posedge CLK_PXCLK) begin
    if (RESET) begin
        pwm_counter <= 'b0;
        pwm <= 'b0;
        ledpwm0 <= 'b0;
        ledpwm1 <= 'b0;
    end else begin
        pwm_counter <= pwm_counter + 1;
        if (pwm_counter[4:0] == 5'b11111) begin
            if (pwm_counter[12:5] == 8'b11111111) begin
                pwm <= 1'b1;
            end else begin
                if (pwm_counter[12:5] == BACKLIGHT_BRIGHTNESS)
                    pwm <= 1'b0;
            end
        end
        if (pwm_counter[7:0] == 8'b00000000) begin
            // led0
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm0[2] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR0[11:8]}) begin
                ledpwm0[2] <= 3'b0;
            end
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm0[1] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR0[7:4]}) begin
                ledpwm0[1] <= 3'b0;
            end
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm0[0] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR0[3:0]}) begin
                ledpwm0[0] <= 3'b0;
            end
            // led1
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm1[2] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR1[11:8]}) begin
                ledpwm1[2] <= 3'b0;
            end
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm1[1] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR1[7:4]}) begin
                ledpwm1[1] <= 3'b0;
            end
            if (pwm_counter[12:8] == 5'b00000) begin
                ledpwm1[0] <= 3'b1;
            end if (pwm_counter[12:8] == {1'b0, RGB_LED_COLOR1[3:0]}) begin
                ledpwm1[0] <= 3'b0;
            end
        end
    end
end
always_comb BACKLIGHT_PWM <= pwm;
always_comb LED0_PWM <= ledpwm0;
always_comb LED1_PWM <= ledpwm1;


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
