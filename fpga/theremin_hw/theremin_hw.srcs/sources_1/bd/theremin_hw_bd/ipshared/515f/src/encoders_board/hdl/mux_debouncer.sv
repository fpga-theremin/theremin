`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: coolreader.org
// Engineer: Vadim Lopatin 
// 
// Create Date: 06/21/2019 03:10:39 PM
// Design Name: 
// Module Name: mux_debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Debouncer for buttons/encoders with multiplexed input
//      For default parameters and 100MHz clock,
//         MUX is switched with 3MHz frequency
//         All 16 inputs are checked once per 100MHz/32/16 ~= 200KHz frequency
//         12 bit debouncing counter allows to change output if there were no bouncing
//              for last 200KHz/4096 ~= 47Hz 
// Dependencies: 
//      None
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_debouncer
#(
    // Number of bits in CLK divider to produce MUX switching frequency.
    // For  CLK_DIV_BITS = 5, /32 divider gives 3MHz for 100MHz CLK.
    parameter CLK_DIV_BITS = 5,
    // Number of address bits for MUX. MUX has (1<<MUX_ADDR_BITS) inputs.
    // One input is read once per CLK/(1<<CLK_DIV_BITS)/(1<<MUX_ADDR_BITS)
    // For 5 bits in divider and bits in address, each input is checked once
    // per 100MHz/32/16 == 200KHz interval 
    parameter MUX_ADDR_BITS = 4,
    // Debouncing counter determines how many cycles input should remain in the same state
    // after change to propagate this change to output.
    // For DEBOUNCE_COUNTER_BITS == 12, it's input check interval / 4096.
    // For default settings, 200KHz/4096 == 47Hz is max frequency of input change (unbounced)
    // which can be noticed.
    parameter DEBOUNCE_COUNTER_BITS = 12,
    // Outputs are updated once per CLK/(1<<CLK_DIV_BITS)/(1<<MUX_ADDR_BITS)/(1<<UPDATE_DIVIDER_BITS)
    // For default settings it's approximately once per 100ms
    parameter UPDATE_DIVIDER_BITS = 11
)
(
    // clock, active posedge
    input logic CLK,
    // reset, active 1
    input logic RESET,
    // MUX address for multiplexing N buttons into one MUX_OUT
    output logic [MUX_ADDR_BITS-1:0] MUX_ADDR,
    // input value from MUX (MUX_OUT <= button[MUX_ADDR])
    input logic MUX_OUT,
    // debounced output values: bit DEBOUNCED[i] is debounced value of MUX[i] input
    output logic [(1<<MUX_ADDR_BITS) - 1:0] DEBOUNCED,
    // change flags, CHANGE_FLAGS[i] set to 1 means that DEBOUNCED[i] is changed since
    // last UPDATED signal
    output logic [(1<<MUX_ADDR_BITS) - 1:0] CHANGE_FLAGS,
    // 1 for one clock cycle after DEBOUNCED and CHANGE_FLAGS are updated
    output logic UPDATED
);

// output registers:
// register for output debounced state bits
logic [(1<<MUX_ADDR_BITS) - 1:0] debounced_out_reg;
// register for output debounced state change bits
logic [(1<<MUX_ADDR_BITS) - 1:0] change_flags_reg;
// register for output updated flag
logic updated_flag_reg;

always_comb UPDATED <= updated_flag_reg;
always_comb CHANGE_FLAGS <= change_flags_reg;
always_comb DEBOUNCED <= debounced_out_reg;

// register for current debounced state bits
logic [(1<<MUX_ADDR_BITS) - 1:0] debounced_reg;

// Divider from CLK to MUX address update clock
logic [CLK_DIV_BITS-1:0] clk_div_reg;
// MUX address register
logic [MUX_ADDR_BITS-1:0] mux_addr_reg;
always_comb MUX_ADDR <= mux_addr_reg;

// clock divider and mux address change
always_ff @(posedge CLK) begin
    if (RESET) begin
        mux_addr_reg <= {MUX_ADDR_BITS{1'b1}};
        clk_div_reg <= {CLK_DIV_BITS{1'b1}};
    end else begin
        if (clk_div_reg == 0) begin
            // last cycle
            mux_addr_reg <= mux_addr_reg - 1;
        end
        clk_div_reg <= clk_div_reg - 1;
    end
end


logic [UPDATE_DIVIDER_BITS-1:0] update_counter_reg;
always_ff @(posedge CLK)
    if (RESET)
        update_counter_reg <= 'b0; //{UPDATE_DIVIDER_BITS{1'b1}};
    else if ((clk_div_reg == 0) && (mux_addr_reg == 0))
        update_counter_reg <= update_counter_reg - 1;

logic needs_update;
always_comb needs_update <= (clk_div_reg == 0) && (mux_addr_reg == 0) && (update_counter_reg==0);
always_ff @(posedge CLK)
    updated_flag_reg <= needs_update;

always_ff @(posedge CLK) begin
    if (needs_update) begin
        debounced_out_reg <= debounced_reg;
        change_flags_reg <= debounced_out_reg ^ debounced_reg;
    end
end


logic rd_en;
logic wr_en;

// cycle when reading MUX output state
always_comb rd_en <= (clk_div_reg == 2);
// cycle when updating state
always_comb wr_en <= (clk_div_reg == 0);

logic mux_out_reg;
// update mux_out register
always_ff @(posedge CLK) begin
    if (rd_en) begin
        mux_out_reg <= MUX_OUT;
    end
end


logic prev_state;
logic new_state;
logic[DEBOUNCE_COUNTER_BITS-1:0] prev_counter;
logic[DEBOUNCE_COUNTER_BITS-1:0] new_counter;
always_comb prev_state <= debounced_reg[mux_addr_reg];

// state memory: register file for storing counters
//(* ram_style = "distributed" *) 
logic[DEBOUNCE_COUNTER_BITS-1:0] debounce_counters[1<<MUX_ADDR_BITS];
// Xilinx tools should infer distributed RAM for debounce_counters
// distributed RAM read, async read
always_comb prev_counter <= debounce_counters[mux_addr_reg];
// distributed RAM write, sync write
always_ff @(posedge CLK) begin
    if (wr_en) begin
        debounce_counters[mux_addr_reg] <= new_counter;
    end
end

// calculation of new state
always_comb begin
    if (mux_out_reg == prev_state) begin
        // not changed - reset counter to max value
        new_counter <= {DEBOUNCE_COUNTER_BITS{1'b1}};
        new_state <= prev_state;
    end else begin
        // current state is not equal to input signal
        if (prev_counter == 0) begin
            // when counter reached 0, we didn't detect any bouncing 
            // for last 1024 measures - let's change output state
            new_state <= mux_out_reg; // change output state
        end else begin
            // don't change output state, just count until debouncing interval ends
            new_state <= prev_state;
        end
        new_counter <= prev_counter - 1;
    end
end

// update state for single channel
always_ff @(posedge CLK) begin
    if (RESET) begin
        debounced_reg <= 'b0;
    end else if (wr_en) begin
        debounced_reg[mux_addr_reg] <= new_state;
    end
end

endmodule
