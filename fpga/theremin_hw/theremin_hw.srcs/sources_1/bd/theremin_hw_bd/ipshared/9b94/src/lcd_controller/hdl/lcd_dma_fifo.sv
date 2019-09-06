`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2019 04:55:56 PM
// Design Name: 
// Module Name: lcd_dma_fifo
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


module lcd_dma_fifo
#(
    // number of 32bit words to read using DMA
    parameter BUFFER_SIZE = 800*480/2,
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    parameter BURST_SIZE = 8
) 
(
    // DMA and FIFO input clock
    input logic CLK,
    // output clock
    input logic CLK_PXCLK,
    // reset signal, active 1
    input logic RESET,

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
    input logic DMA_RD_DATA_VALID,

    // buffer start/stop (in CLK_PXCLK domain)     
    // 1 for one CLK_PXCLK cycle near before next frame begin - DMA may start prefetching
    input logic START,
    // 1 for one CLK_PXCLK cycle near after frame ended - DMA should stop operation
    input logic STOP,

    // interface to read data from queue, in CLK_PXCLK domain
    // 1 for one CLK_PXCLK cycle to read next word
    input logic RDEN,
    // data read from queue, appears in next CLK_PXCLK cycle after RDEN=1
    output logic [15:0] RDDATA,

    // 1 for LCD side underflow - no data for pixel provided by DMA
    output logic DMA_FIFO_RDERR,
    // 1 for DMA side overflow - buffer full when trying to write data to FIFO
    output logic DMA_FIFO_WRERR
//    , output logic [31:0] debug_fifo_data_out
//    , output logic debug_fifo_almost_empty // sync to pxclk
//    , output logic [14:0] debug_dma_burst_count
//    , output logic debug_running
);

localparam BLOCK_BURST_COUNT = BUFFER_SIZE / BURST_SIZE;
localparam BLOCK_BURST_COUNT_BITS = (BLOCK_BURST_COUNT <= (1<<12)) ? 12
                                  : (BLOCK_BURST_COUNT <= (1<<13)) ? 13
                                  : (BLOCK_BURST_COUNT <= (1<<14)) ? 14
                                  : (BLOCK_BURST_COUNT <= (1<<15)) ? 15
                                  : (BLOCK_BURST_COUNT <= (1<<16)) ? 16
                                  :                                  17;

logic start_sync;
always_ff @(posedge CLK)
    if (RESET)
        start_sync <= 'b0;
    else
        start_sync <= START;

// FIFO write signals, in CLK clock domain
logic [31:0] fifo_data_in;
logic fifo_wren;
logic fifo_almost_full; // sync to clk
logic fifo_full;

// FIFO read signals, in CLK_PXCLK clock domain
logic [31:0] fifo_data_out;
logic fifo_almost_empty; // sync to pxclk
logic fifo_rden;
logic fifo_empty;

//always_comb debug_fifo_data_out <= fifo_data_out; 
//always_comb debug_fifo_almost_empty <= fifo_almost_empty;


//==============================================
// DMA logic
always_comb fifo_data_in <= DMA_RD_DATA;
always_comb fifo_wren <= DMA_RD_DATA_VALID;

logic running;
logic dma_start;

always_comb DMA_START <= dma_start;

logic [29:0] dma_read_address;
logic [BLOCK_BURST_COUNT_BITS-1:0] dma_burst_count;
logic first_burst;

always_comb DMA_RD_ADDR <= dma_read_address;
//always_comb debug_dma_burst_count <= dma_burst_count;
//always_comb debug_running <= running;

always_ff @(posedge CLK) begin
    if (RESET) begin
        running <= 'b0;
        dma_read_address <= 'b0;
        dma_burst_count <= 'b0;
        dma_start <= 'b0;
        first_burst <= 'b1;
    end else begin
        if (start_sync) begin
            dma_read_address <= BUFFER_START_ADDRESS;
            dma_burst_count <= BLOCK_BURST_COUNT - 1;
            running <= BUFFER_START_ADDRESS != 29'b0; // start only if buffer address is not zero
            first_burst <= 'b1;
        end else if (running) begin
            if (dma_start) begin
                dma_start <= 1'b0;
            end else if (~fifo_almost_full & DMA_READY) begin
                // start new DMA cyle
                if (~first_burst) begin
                    dma_read_address <= dma_read_address + BURST_SIZE;
                    dma_burst_count <= dma_burst_count - 1;
                    running <= (dma_burst_count != 0);
                end
                dma_start <= (dma_burst_count != 0);
                first_burst <= 1'b0;
            end
        end
    end
end


//==============================================
// READ logic

// output register
logic [15:0] rd_data_reg;
// 0: bits[0:15] will be read, 1: bits[31:16] will be read
logic rd_word_part_address;
always_comb RDDATA <= rd_data_reg;

// idle: 1 between STOP and START
logic idle;
always_ff @(posedge CLK_PXCLK)
    if (RESET)
        idle <= 'b1;
    else
        idle <= STOP ? 1'b1
              : START ? 1'b0
              : idle;

always_ff @(posedge CLK_PXCLK) begin
    if (RESET | (fifo_empty & RDEN)) begin
        rd_data_reg <= 1'b0;
        rd_word_part_address <= 1'b0;
        fifo_rden <= 1'b0;
    end else begin
        if (RDEN) begin
            rd_data_reg <= rd_word_part_address ? fifo_data_out[31:16] : fifo_data_out[15:0];
            fifo_rden <= ~rd_word_part_address;
            rd_word_part_address <= ~rd_word_part_address;
        end else begin
            // while vblank, read all of data from fifo until it's empty 
            fifo_rden <= idle & ~fifo_empty;
        end
    end
end



// FIFO18E1: 18Kb FIFO (First-In-First-Out) Block RAM Memory
//           Artix-7
// Xilinx HDL Language Template, version 2019.1

FIFO18E1 #(
  .ALMOST_EMPTY_OFFSET(13'h0040),    // Sets the almost empty threshold
  .ALMOST_FULL_OFFSET(13'h0040),     // Sets almost full threshold
  .DATA_WIDTH(36),                   // Sets data width to 4-36
  .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
  .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
  .FIFO_MODE("FIFO18_36"),              // Sets mode to FIFO18 or FIFO18_36
  .FIRST_WORD_FALL_THROUGH("TRUE"),  // Sets the FIFO FWFT to FALSE, TRUE
  .INIT(36'h000000000),              // Initial values on output port
  .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
  .SRVAL(36'h000000000)              // Set/Reset value for output port
)
FIFO18E1_inst (
  // Read Data: 32-bit (each) output: Read output data
  .DO(fifo_data_out),        // 32-bit output: Data output
  .DOP(),                    // 4-bit output: Parity data output
  // Status: 1-bit (each) output: Flags and other FIFO status outputs
  .ALMOSTEMPTY(fifo_almost_empty), // 1-bit output: Almost empty flag
  .ALMOSTFULL(fifo_almost_full),   // 1-bit output: Almost full flag
  .EMPTY(fifo_empty),              // 1-bit output: Empty flag
  .FULL(fifo_full),                // 1-bit output: Full flag
  .RDCOUNT(),                      // 12-bit output: Read count
  .RDERR(DMA_FIFO_RDERR),          // 1-bit output: Read error
  .WRCOUNT(),                      // 12-bit output: Write count
  .WRERR(DMA_FIFO_WRERR),          // 1-bit output: Write error
  // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
  .RDCLK(CLK_PXCLK),               // 1-bit input: Read clock
  .RDEN(fifo_rden),                // 1-bit input: Read enable
  .REGCE(),                        // 1-bit input: Clock enable  1'b1 Output register clock enable. Only used when EN_SYNC = TRUE and DO_REG = 1. RSTREG has priority over REGCE.
  .RST(RESET),                     // 1-bit input: Asynchronous Reset
  .RSTREG(),                       // 1-bit input: Output register set/reset (RESET) Output register synchronous set/reset. Only used when EN_SYNC = TRUE and DO_REG = 1. RSTREG_PRIORITY is always set to RSTREG.
  // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
  .WRCLK(CLK),                     // 1-bit input: Write clock
  .WREN(fifo_wren),                // 1-bit input: Write enable
  // Write Data: 32-bit (each) input: Write input data
  .DI(fifo_data_in),               // 32-bit input: Data input
  .DIP(4'b0)                       // 4-bit input: Parity input
);

// End of FIFO18E1_inst instantiation



endmodule
