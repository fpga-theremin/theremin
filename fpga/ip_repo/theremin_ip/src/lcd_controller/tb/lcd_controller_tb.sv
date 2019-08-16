`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 12:52:48 PM
// Design Name: 
// Module Name: lcd_controller_tb
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


module lcd_controller_tb(

);

// DMA clock
logic CLK;
// reset signal, active 1
logic RESET;

// RGB interface
// pixel clock
logic CLK_PXCLK;
// horizontal sync
logic HSYNC;
// vertical sync
logic VSYNC;
// data enable
logic DE;
// pixel value
logic [15:0] PIXEL_DATA;

// current Y position (row index); rows 0..VPIXELS-1 are visible, in CLK_PXCLK domain
logic [8:0] ROW_INDEX;


// DMA interface, in CLK clock domain
// start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
logic [29:0] BUFFER_START_ADDRESS;

// read start address for DMA burst read operation 
logic [29:0] DMA_RD_ADDR;
// 1 for one CLK cycle to start new DMA burst read operation (use only if DMA_READY==1)
logic DMA_START;
// 1 when DMA is ready to accept new operation
logic DMA_READY;
// data read from DMA (when DMA_RD_DATA_VALID==1)
logic [31:0] DMA_RD_DATA;
// 1 for one CLK cycle, when new data becomes available and should be written to FIFO 
logic DMA_RD_DATA_VALID;

// backlight brightness setting, 0=dark, 255=light
logic [7:0] BACKLIGHT_BRIGHTNESS;
// backlight PWM control output
logic BACKLIGHT_PWM;

//logic [14:0] debug_dma_burst_count;
//logic debug_running;

// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR0;
// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR1;

// color led0 control output {r,g,b}
logic [2:0] LED0_PWM;
// color led1 control output {r,g,b}
logic [2:0] LED1_PWM;


lcd_controller
#(
)
lcd_controller_inst
(
    .*
);

initial begin
    RGB_LED_COLOR0 = 12'hf40;   RGB_LED_COLOR1 = 12'hc82;
    BUFFER_START_ADDRESS = 32'h80000000 >> 3;
    BACKLIGHT_BRIGHTNESS = 0;
    #15 RESET = 1;
    #215 RESET = 0;
    #10ms BACKLIGHT_BRIGHTNESS = 0;     RGB_LED_COLOR0 = 12'hfc4;   RGB_LED_COLOR1 = 12'h123;
    #10ms BACKLIGHT_BRIGHTNESS = 255;   RGB_LED_COLOR0 = 12'h842;   RGB_LED_COLOR1 = 12'hfea;
    #10ms BACKLIGHT_BRIGHTNESS = 8;     RGB_LED_COLOR0 = 12'hfc4;   RGB_LED_COLOR1 = 12'h123;
    #10ms BACKLIGHT_BRIGHTNESS = 255-8; RGB_LED_COLOR0 = 12'h234;   RGB_LED_COLOR1 = 12'h567;
    #10ms BACKLIGHT_BRIGHTNESS = 64;    RGB_LED_COLOR0 = 12'hfec;   RGB_LED_COLOR1 = 12'hdba;
    #10ms BACKLIGHT_BRIGHTNESS = 192;   RGB_LED_COLOR0 = 12'h111;   RGB_LED_COLOR1 = 12'h222;
    #10ms BACKLIGHT_BRIGHTNESS = 128;   RGB_LED_COLOR0 = 12'hfff;   RGB_LED_COLOR1 = 12'heee;
end

always begin
    #3.3333 CLK = 1; CLK_PXCLK = 1;
    #3.3333 CLK = 0; 
    #3.3333 CLK = 1;
    #3.3333 CLK = 0;
    #3.3333 CLK = 1; CLK_PXCLK = 0;
    #3.3333 CLK = 0;
    #3.3333 CLK = 1;
    #3.3333 CLK = 0;
end


module dma_simulator_lcd
(
    // DMA and FIFO input clock
    input logic CLK,
    // reset signal, active 1
    input logic RESET,
    
    // read start address for DMA burst read operation 
    input logic [29:0] DMA_RD_ADDR,
    // 1 for one CLK cycle to start new DMA burst read operation (use only if DMA_READY==1)
    input logic DMA_START,
    // 1 when DMA is ready to accept new operation
    output logic DMA_READY,
    // data read from DMA (when DMA_RD_DATA_VALID==1)
    output logic [31:0] DMA_RD_DATA,
    // 1 for one CLK cycle, when new data becomes available and should be written to FIFO 
    output logic DMA_RD_DATA_VALID
);

logic dma_ready;
logic [3:0] dma_burst_index;

always_comb DMA_READY <= dma_ready;
always_comb DMA_RD_DATA_VALID <= dma_burst_index[0] & ~dma_ready; 
always_comb DMA_RD_DATA[15:0] <= dma_ready ? 0 : {DMA_RD_ADDR[14:3], dma_burst_index[3:1], 1'b0};
always_comb DMA_RD_DATA[31:16] <= dma_ready ? 0 : {DMA_RD_ADDR[14:3], dma_burst_index[3:1], 1'b1};

always_ff @(posedge CLK) begin
    if (RESET) begin
        dma_ready <= 'b1;
    end else begin
        if (dma_ready & DMA_START) begin
            dma_ready <= 1'b0;
            dma_burst_index <= 'b0;
        end else if (~dma_ready) begin
            if (dma_burst_index == 4'b1111) begin
                dma_ready <= 1'b1;
            end
            dma_burst_index <= dma_burst_index + 1;
        end
    end
end

endmodule

dma_simulator_lcd dma_simulator_inst (.*);


endmodule
