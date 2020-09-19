`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2020 02:39:58 PM
// Design Name: 
// Module Name: iir_nstage_pow2k
// Project Name: 
// Target Devices: Optimized for Xilinx Series 7 devices but should work on any device 
// Tool Versions: 
// Description: 
//     Multiple stage simple IIR filter with K = power of two
//     Each stage is  new_state = prev_state * K + in_value (1 - K) = prev_state + (in_value - prev_state) * K
//     K (as number of bits of right shift), number of filter stages, and output update rate are configurable as module parameters
//      
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module iir_nstage_pow2k
#(
    // filter coefficient is 1 / (1 << K_SHIFT_BITS) : instead of multiply, right shift is used
    parameter K_SHIFT_BITS = 6,
    // number of bits in filter input and output
    parameter VALUE_BITS = 30,
    // filter output is being updated once per CYCLE_COUNT (can be bigger than number of stages to align output rate with other clock)
    parameter CYCLE_COUNT = 5,
    // number of IIR filter stages, should be <= CYCLE_COUNT
    parameter STAGE_COUNT = 5
)
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // filter input value
    input logic [VALUE_BITS-1 : 0] IN_VALUE,
    
    // filter output value
    output logic [VALUE_BITS-1 : 0] OUT_VALUE
    
    
//    , output logic [2:0] debug_phase_counter
//    , output logic debug_filter_en
//    , output logic [2:0] debug_states_wr_addr
//    , output logic [VALUE_BITS-1 : 0] debug_states_wr_data
//    , output logic [2:0] debug_states_rd_addr
//    , output logic [VALUE_BITS-1 : 0] debug_states_rd_data

//    , output logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_scaled_in_state
//    , output logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_diff_in_state
//    , output logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_diff_in_value
//    , output logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_sum
);

logic [VALUE_BITS-1 : 0] out_reg;

always_comb OUT_VALUE <= out_reg;




//=========================================================
// states register bank (distributed ram) implementation
//=========================================================
// read channel
logic [2:0] states_rd_addr;
logic [VALUE_BITS-1 : 0] states_rd_data;
// write channel
logic [2:0] states_wr_addr;
logic [VALUE_BITS-1 : 0] states_wr_data;
logic states_wren;
// memory
logic [VALUE_BITS-1 : 0] states[8];

// state register bank async read
always_comb states_rd_data <= states[states_rd_addr];
// state register bank sync write
always @(posedge CLK) begin
    if (states_wren)
        states[states_wr_addr] <= states_wr_data;
end
// write: always enabled
always_comb states_wren <= 'b1;



//===========================================================================================
// filter: filter_out = filter_in_state + (filter_in_value - filter_in_state) >> K_SHIFT_BITS
//===========================================================================================
// 0: use filter_in_value, 1: use filter out from previous stage
logic filter_value_mux;
// filter input
logic [VALUE_BITS-1 : 0] filter_in_value;
logic [VALUE_BITS-1 : 0] filter_in_state;
// filter output
logic [VALUE_BITS-1 : 0] filter_out;
logic [VALUE_BITS-1 : 0] filter_out_buffered;
// when 0, force output to 1: keep 0 for first loop to init states to 0
logic filter_en;

// filter internal calculations
logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] filter_scaled_in_state;
logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] filter_diff_in_state;
logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] filter_diff_in_value;
logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] filter_sum;

always_comb filter_scaled_in_state <= {filter_in_state, {K_SHIFT_BITS{1'b0}}};
always_comb filter_diff_in_value <= {{K_SHIFT_BITS{1'b0}}, (filter_value_mux ? filter_out_buffered : filter_in_value)};  
always_comb filter_diff_in_state <= {{K_SHIFT_BITS{1'b0}}, filter_in_state};  
always_comb filter_sum <= filter_scaled_in_state + (filter_diff_in_value - filter_diff_in_state);

// output unbuffered
assign filter_out = filter_sum[VALUE_BITS+K_SHIFT_BITS-1 : K_SHIFT_BITS];
// output buffered
always_ff @(posedge CLK) begin
    if (RESET | ~filter_en)
        filter_out_buffered <= 'b0;
    else
        filter_out_buffered <= filter_out;
end


//===========================================================================================
// phase counter counts 0..CYCLE_COUNT-1
//===========================================================================================

logic [2:0] phase_counter;
always_ff @(posedge CLK) begin
    if (RESET || phase_counter == (CYCLE_COUNT-1)) begin
        phase_counter <= 'b0;
        filter_en <= ~RESET;
    end else begin
        phase_counter <= phase_counter + 1;
        filter_en <= filter_en;
    end
end
// delayed counter value: for WR address
logic [2:0] phase_counter_delay1;
always_ff @(posedge CLK) begin
    if (RESET) begin
        phase_counter_delay1 <= 'b0;
    end else begin
        phase_counter_delay1 <= phase_counter;
    end
end

always_comb filter_in_value <= IN_VALUE;
always_comb filter_value_mux <= (phase_counter == 3'b000) ? 1'b0 : 1'b1;

// read at cycle counter address
always_comb states_rd_addr <= phase_counter;
// pass read data to filter input as previous state
always_comb filter_in_state <= states_rd_data;

// write to delayed address
always_comb states_wr_addr <= phase_counter_delay1;
// write buffered output
always_comb states_wr_data <= filter_out_buffered;

// catch filter output from last stage
always_ff @(posedge CLK) begin
    if (RESET) begin
        out_reg <= 'b0;
    end else if (states_wr_addr == (STAGE_COUNT - 1)) begin
        // writing new state to last stage: let's write it to output reg as well
        out_reg <= states_wr_data;
    end
end



//assign debug_phase_counter = phase_counter;
//assign debug_filter_en = filter_en;

//assign debug_states_wr_addr = states_wr_addr;
//assign debug_states_wr_data = states_wr_data;
//assign debug_states_rd_addr = states_rd_addr;
//assign debug_states_rd_data = states_rd_data;

//assign debug_filter_scaled_in_state = filter_scaled_in_state;
//assign debug_filter_diff_in_state = filter_diff_in_state;
//assign debug_filter_diff_in_value = filter_diff_in_value;
//assign debug_filter_sum = filter_sum;


endmodule
