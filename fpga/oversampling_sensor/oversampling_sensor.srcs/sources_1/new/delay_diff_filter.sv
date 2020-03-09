`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vadim Lopatin 
// 
// Create Date: 03/03/2020 06:37:46 PM
// Design Name: 
// Module Name: delay_diff_filter
// Project Name: 
// Target Devices: optimized for Xilinx Series 7, but should work on other platforms as well  
// Tool Versions: 
// Description: 
//      Implements delay based filter OUT_DIFF = (IN_VALUE - DELAYED_VALUE[DELAY_CYCLES])
//      Uses distributed RAM or block RAM for delay buffer.
//      Updates output each time new value is supplied.
//      Input data flow should be incremental measured values (e.g. timer counter latched values)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module delay_diff_filter
#(
    // filter will calculate diff with value delayed by DELAY_CYCLES WR cycles, power of two is recommended
    parameter DELAY_CYCLES = 64,
    // number of bits in value (the bigger is delay, the more bits in value is needed: one addr bit == +1 value bit)
    parameter VALUE_BITS = 20,
    // use BRAM for delays with log2(DELAY_CYCLE) >= BRAM_ADDR_BITS_THRESHOLD
    parameter BRAM_ADDR_BITS_THRESHOLD = 7
)
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // input value for filter
    input logic [VALUE_BITS - 1 : 0] IN_VALUE,

    // set to 1 for one clock cycle to push new value
    input logic WR,
    
    // toggling each time we have new value on output
    output logic CHANGED,
    // filter output (IN_VALUE - delay(IN_VALUE, 2**DELAY_ADDR_BITS)), updated one cycle after WR
    // delay is counted as number of input values (WR==1 count)
    output logic [VALUE_BITS - 1 : 0] OUT_DIFF
    
    
);


generate
    if (DELAY_CYCLES < 4 || DELAY_CYCLES > 8192)
        $error("DELAY_CYCLES should be in range 4..8192");
endgenerate

// delay buffer address bits: filter will calculate diff with value delayed by 2**DELAY_ADDR_BITS WR cycles
localparam DELAY_ADDR_BITS = (DELAY_CYCLES <= 4) ? 2
                           : (DELAY_CYCLES <= 8) ? 3
                           : (DELAY_CYCLES <= 16) ? 4
                           : (DELAY_CYCLES <= 32) ? 5
                           : (DELAY_CYCLES <= 64) ? 6
                           : (DELAY_CYCLES <= 128) ? 7
                           : (DELAY_CYCLES <= 256) ? 8
                           : (DELAY_CYCLES <= 512) ? 9
                           : (DELAY_CYCLES <= 1024) ? 10
                           : (DELAY_CYCLES <= 2048) ? 11
                           : (DELAY_CYCLES <= 4096) ? 12
                           :                          13;
// support for non-power-of-two delays
localparam DELAY_COUNTER_OFFSET = (1<<DELAY_ADDR_BITS) - DELAY_CYCLES;


logic [VALUE_BITS - 1 : 0] ram_read_value;
logic [VALUE_BITS - 1 : 0] diff_value;
always_comb OUT_DIFF <= diff_value;
logic ram_initialized;

// RAM address counter logic
logic [DELAY_ADDR_BITS-1 : 0] addr_counter;
logic addr_counter_overflow;
always_comb addr_counter_overflow <= &addr_counter;
always_ff @(posedge CLK) begin
    if (RESET) begin
        addr_counter <= 'b0;
        ram_initialized <= 'b0;
    end else begin
        if (WR) begin
            addr_counter <= addr_counter + 1;
            // turn on ram_initialized flag on counter overflow: when buffer is filled with data
            ram_initialized <= ram_initialized | addr_counter_overflow;
        end
    end
end

// toggling each time we have new value on output
logic output_changed;
always_comb CHANGED <= output_changed;

// Output value logic
always_ff @(posedge CLK) begin
    if (RESET) begin
        diff_value <= 'b0;
        output_changed <= 'b0;
    end else begin
        if (WR & ram_initialized) begin
            diff_value <= IN_VALUE - ram_read_value;
            output_changed <= ~output_changed;
        end
    end
end


// memory access logic
generate

    if (DELAY_ADDR_BITS >= BRAM_ADDR_BITS_THRESHOLD) begin
        // use BRAM: synchronous read and write
        // we can specify ram style attribute, but it's often inferred automatically  *** ram_style="block" *
        (* ram_style="block" *) 
        logic [VALUE_BITS - 1 : 0] delay_ram [(1 << DELAY_ADDR_BITS) - 1 : 0];

        logic [DELAY_ADDR_BITS-1 : 0] read_addr;
        always_comb read_addr <= addr_counter + 1 + DELAY_COUNTER_OFFSET;
        
        always_ff @(posedge CLK) begin
            if (RESET) begin
                ram_read_value <= 'b0;
            end else if (WR) begin
                delay_ram[addr_counter] <= IN_VALUE;
                ram_read_value <= delay_ram[read_addr];
            end
        end
    end else begin
        // use distributed RAM: asynchronous read and synchronous write
        // we can specify ram style attribute, but it's often inferred automatically
        (* ram_style="distributed" *)
        logic [VALUE_BITS - 1 : 0] delay_ram [(1 << DELAY_ADDR_BITS) - 1 : 0];
 
        logic [DELAY_ADDR_BITS-1 : 0] read_addr;
        always_comb read_addr <= addr_counter + DELAY_COUNTER_OFFSET;

        always_comb ram_read_value <= delay_ram[read_addr];
        
        always_ff @(posedge CLK) begin
            if (RESET) begin
            end else if (WR) begin
                delay_ram[addr_counter] <= IN_VALUE;
            end
        end
    end

endgenerate

endmodule
