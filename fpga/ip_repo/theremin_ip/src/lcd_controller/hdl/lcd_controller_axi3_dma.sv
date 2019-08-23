`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 04:06:41 PM
// Design Name: 
// Module Name: lcd_controller_axi3_dma
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


module lcd_controller_axi3_dma #(
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    parameter integer BURST_SIZE = 8,
    parameter integer HPIXELS = 800,
    parameter integer VPIXELS = 480,
    parameter integer HBP = 2,
    parameter integer VBP = 2,
    parameter integer HSW = 12,
    parameter integer VSW = 3,
    parameter integer HFP = 2,
    parameter integer VFP = 2,
    parameter integer HSYNC_POLARITY = 0,
    parameter integer VSYNC_POLARITY = 0,
    parameter integer X_BITS = ( (HPIXELS+HBP+HSW+HFP) <= 256 ? 8
                               : (HPIXELS+HBP+HSW+HFP) <= 512 ? 9
                               : (HPIXELS+HBP+HSW+HFP) <= 1024 ? 10
                               :                                 11 ),
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
    
    // current Y position (col index); cols 0..HPIXELS-1 are visible, in CLK_PXCLK domain
    output logic [X_BITS-1:0] COL_INDEX,
    // current Y position (row index); rows 0..VPIXELS-1 are visible, in CLK_PXCLK domain
    output logic [Y_BITS-1:0] ROW_INDEX,

    // 1 for LCD side underflow - no data for pixel provided by DMA
    output logic DMA_FIFO_RDERR,
    // 1 for DMA side overflow - buffer full when trying to write data to FIFO
    output logic DMA_FIFO_WRERR,


    // DMA interface, in CLK clock domain
    // start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
    input logic [29:0] BUFFER_START_ADDRESS,
    
    // AXI3 reader
    // address channel
    input  logic  m00_axi_arready,
    output logic [3 : 0] m00_axi_arlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    output logic [31 : 0] m00_axi_araddr,
    output logic  m00_axi_arvalid,
    // address channel
    input  logic  m00_axi_rlast,
    input  logic  m00_axi_rvalid,
    input  logic [31 : 0] m00_axi_rdata,
    output logic  m00_axi_rready
);

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

lcd_controller
#(
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    .BURST_SIZE(BURST_SIZE),
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
)
lcd_controller_inst
(
    // DMA clock
    .CLK,
    // reset signal, active 1
    .RESET,

    // RGB interface
    // pixel clock
    .CLK_PXCLK,
    // horizontal sync
    .HSYNC,
    // vertical sync
    .VSYNC,
    // data enable
    .DE,
    // pixel value
    .PIXEL_DATA,
    
    .COL_INDEX,
    // current Y position (row index); rows 0..VPIXELS-1 are visible, in CLK_PXCLK domain
    .ROW_INDEX,


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

    // 1 for LCD side underflow - no data for pixel provided by DMA
    .DMA_FIFO_RDERR,
    // 1 for DMA side overflow - buffer full when trying to write data to FIFO
    .DMA_FIFO_WRERR

);


axi3_hp_reader #(
    .BURST_SIZE(BURST_SIZE)
) 
axi3_hp_reader_inst
(
    // DMA and FIFO input clock
    .CLK,
    // reset signal, active 1
    .RESET,
    
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

    // AXI3 reader
    // address channel
    .m00_axi_arready,
    .m00_axi_arlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    .m00_axi_araddr,
    .m00_axi_arvalid,
    // address channel
    .m00_axi_rlast,
    .m00_axi_rvalid,
    .m00_axi_rdata,
    .m00_axi_rready

);


endmodule
