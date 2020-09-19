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

lcd_controller_axi3_dma lcd_controller_axi3_dma_inst
(
    .*
);




initial begin
    BUFFER_START_ADDRESS = 32'h80000000 >> 3;
    #15 RESET = 1;
    #215 RESET = 0;
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
