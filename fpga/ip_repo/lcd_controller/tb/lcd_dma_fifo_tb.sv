`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 09:06:18 AM
// Design Name: 
// Module Name: lcd_dma_fifo_tb
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


module lcd_dma_fifo_tb(

    );

// DMA and FIFO input clock
logic CLK;
// output clock
logic CLK_PXCLK;
// reset signal, active 1
logic RESET;

// DMA interface, in CLK clock domain
// start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
logic [28:0] BUFFER_START_ADDRESS;

// read start address for DMA burst read operation 
logic [28:0] DMA_RD_ADDR;
// 1 for one CLK cycle to start new DMA burst read operation (use only if DMA_READY==1)
logic DMA_START;
// 1 when DMA is ready to accept new operation
logic DMA_READY;
// data read from DMA (when DMA_RD_DATA_VALID==1)
logic [31:0] DMA_RD_DATA;
// 1 for one CLK cycle, when new data becomes available and should be written to FIFO 
logic DMA_RD_DATA_VALID;

// buffer start/stop (in CLK_PXCLK domain)     
// 1 for one CLK_PXCLK cycle near before next frame begin - DMA may start prefetching
logic START;
// 1 for one CLK_PXCLK cycle near after frame ended - DMA should stop operation
logic STOP;

// interface to read data from queue, in CLK_PXCLK domain
// 1 for one CLK_PXCLK cycle to read next word
logic RDEN;
// data read from queue, appears in next CLK_PXCLK cycle after RDEN=1
logic [15:0] RDDATA;


//logic [31:0] debug_fifo_data_out;
//logic debug_fifo_almost_empty; // sync to pxclk

lcd_dma_fifo lcd_dma_fifo_inst 
(
    .*
);

logic HSYNC;
logic VSYNC;
logic DE;
logic [9:0] X;
logic [8:0] Y;
// 1 for one cycle near before next frame begin
logic BEFORE_FRAME;
// 1 for one cycle near after frame ended
logic AFTER_FRAME;

always_comb START <= BEFORE_FRAME;
always_comb STOP <= AFTER_FRAME;
always_comb RDEN <= DE;

lcd_clk_gen lcd_clk_gen_inst
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

module dma_simulator
(
    // DMA and FIFO input clock
    input logic CLK,
    // reset signal, active 1
    input logic RESET,
    
    // read start address for DMA burst read operation 
    input logic [28:0] DMA_RD_ADDR,
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

dma_simulator dma_simulator_inst (.*);


endmodule
