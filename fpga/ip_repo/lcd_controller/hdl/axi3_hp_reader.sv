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
logic dma_ready;

assign m00_axi_arlen = BURST_SIZE - 1;

always_comb m00_axi_arvalid <= arvalid;
always_comb m00_axi_rready <= ~dma_ready;
always_comb m00_axi_araddr <= {DMA_RD_ADDR, 3'b000};

always_comb DMA_RD_DATA <= m00_axi_rdata;
always_comb DMA_RD_DATA_VALID <= m00_axi_rvalid;

always_comb DMA_READY <= dma_ready;

logic [2:0] dma_ready_delay;

always_ff @(posedge CLK) begin
    if (RESET) begin
        dma_ready <= 1'b1;
        arvalid <= 1'b0;
        dma_ready_delay <= 3'b0;
    end else begin
        // * the master must not wait for the slave to assert ARREADY before asserting ARVALID
        // * the slave can wait for ARVALID to be asserted before it asserts ARREADY
        // * the slave can assert ARREADY before ARVALID is asserted
        // * the slave must wait for both ARVALID and ARREADY to be asserted before it asserts RVALID to indicate that valid data is available
        // * the slave must not wait for the master to assert RREADY before asserting RVALID
        // * the master can wait for RVALID to be asserted before it asserts RREADY
        // * the master can assert RREADY before RVALID is asserted
        if (dma_ready) begin //& m00_axi_arready
            // waiting for request
            if (~arvalid & DMA_START) begin
                // master read request 
                arvalid <= 1'b1;
                dma_ready <= 1'b0;
            end else begin
                arvalid <= 1'b0;
            end
        end else begin
            // handle reading
            if (m00_axi_arready) begin
                // address is accepted
                arvalid <= 1'b0;
            end
            if (m00_axi_rvalid & m00_axi_rlast) begin //m00_axi_rvalid m00_axi_rlast 
                dma_ready_delay <= 3'b111;
            end else if (dma_ready_delay != 3'b0000) begin
                if (dma_ready_delay == 3'b001) begin
                    dma_ready <= 1'b1;
                end
                dma_ready_delay <= dma_ready_delay - 1;
            end
        end
    end
end

endmodule
