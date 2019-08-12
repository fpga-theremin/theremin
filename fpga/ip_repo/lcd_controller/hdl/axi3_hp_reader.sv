`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2019 03:56:30 PM
// Design Name: 
// Module Name: axi3_hp_reader
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


module axi3_hp_reader #(
    parameter BURST_SIZE = 8
)
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
    output logic DMA_RD_DATA_VALID,

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

logic arvalid;
logic rready;

logic dma_ready;
logic [1:0] state;

always_comb m00_axi_arvalid <= arvalid;
always_comb m00_axi_rready <= rready;
always_comb m00_axi_araddr <= {DMA_RD_ADDR, 3'b000};
always_comb DMA_RD_DATA <= m00_axi_rdata;
always_comb DMA_RD_DATA_VALID <= m00_axi_rvalid;
always_comb DMA_READY <= dma_ready;
always_comb m00_axi_arlen <= BURST_SIZE - 1;

// TODO: support burst reads
always @(posedge CLK) begin
    if (RESET) begin
        state <= 2'b00;
        dma_ready <= 1'b0;
        arvalid <= 1'b0;
        rready <= 1'b0;
    end else begin
        case (state)
        2'b00:
            begin
                if (dma_ready & DMA_START) begin
                    arvalid <= 1'b1;
                    state <= 2'b01;
                    dma_ready <= 1'b0;
                end else begin
                    dma_ready <= 1'b1;
                end
            end
        2'b01:
            begin
                // waiting for address is accepted
                if (m00_axi_arready) begin
                    arvalid <= 1'b0;
                    rready <= 1'b1;
                    state <= 2'b10;
                end
            end
        2'b10:
            begin
                // waiting for data is ready
                if (m00_axi_rvalid) begin
                    rready <= 1'b0;
                    state <= 2'b00;
                    dma_ready <= 1'b1;
                end
            end
        2'b11:
            begin
                state <= 2'b00;
            end
        endcase
    end
end
endmodule
