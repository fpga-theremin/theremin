`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 04:39:25 PM
// Design Name: 
// Module Name: lcd_controller_axi3_dma_tb
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


module lcd_controller_axi3_dma_tb(

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

// backlight brightness setting, 0=dark, 255=light
logic [7:0] BACKLIGHT_BRIGHTNESS;
// backlight PWM control output
logic BACKLIGHT_PWM;


// DMA interface, in CLK clock domain
// start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
logic [29:0] BUFFER_START_ADDRESS;

// AXI3 reader
// address channel
logic  m00_axi_arready;
logic [3 : 0] m00_axi_arlen;     // ****** AXI3: [3:0] AXI4: [7:0]
logic [31 : 0] m00_axi_araddr;
logic  m00_axi_arvalid;
// address channel
logic  m00_axi_rlast;
logic  m00_axi_rvalid;
logic [31 : 0] m00_axi_rdata;
logic  m00_axi_rready;

// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR0;
// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR1;

// color led0 control output {r,g,b}
logic [2:0] LED0_PWM;
// color led1 control output {r,g,b}
logic [2:0] LED1_PWM;

lcd_controller_axi3_dma lcd_controller_axi3_dma_inst
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


module axi3_dma_simulator
(
    // DMA and FIFO input clock
    input logic CLK,
    // reset signal, active 1
    input logic RESET,
    
    // AXI3 reader
    // address channel
    output logic  m00_axi_arready,
    input logic [3 : 0] m00_axi_arlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    input logic [31 : 0] m00_axi_araddr,
    input logic  m00_axi_arvalid,
    // address channel
    output  logic  m00_axi_rlast,
    output  logic  m00_axi_rvalid,
    output  logic [31 : 0] m00_axi_rdata,
    input logic  m00_axi_rready
);

logic dma_ready;
logic [3:0] dma_burst_index;

always_comb m00_axi_arready <= dma_ready;
always_comb m00_axi_rlast <= (dma_burst_index == 4'b1111) & ~dma_ready; 
always_comb m00_axi_rvalid <= dma_burst_index[0] & ~dma_ready; 
always_comb m00_axi_rdata[15:0] <= dma_ready ? 0 : {m00_axi_araddr[17:6], dma_burst_index[3:1], 1'b0};
always_comb m00_axi_rdata[31:16] <= dma_ready ? 0 : {m00_axi_araddr[17:6], dma_burst_index[3:1], 1'b1};

always_ff @(posedge CLK) begin
    if (RESET) begin
        dma_ready <= 'b1;
    end else begin
        if (dma_ready & m00_axi_arvalid) begin
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

axi3_dma_simulator axi3_dma_simulator_inst (.*);


endmodule
