`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2020 11:32:56 AM
// Design Name: 
// Module Name: iir_4stage_2channel_pow2k
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


module iir_4stage_2channel_pow2k
#(
    parameter K_SHIFT_BITS = 8,
    parameter VALUE_BITS = 32,
    parameter CYCLE_COUNT = 8,
    parameter STAGE_COUNT = 4
)
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    input logic CLK,

    // reset, active 1
    input logic RESET,

    // filter input value1
    input logic [VALUE_BITS-1 : 0] IN_VALUE1,
    // filter input value2
    input logic [VALUE_BITS-1 : 0] IN_VALUE2,

    // filter output for channel1
    output logic [VALUE_BITS-1 : 0] OUT_VALUE1,
    // filter output for channel2
    output logic [VALUE_BITS-1 : 0] OUT_VALUE2
);

logic [VALUE_BITS-1 : 0] out1;
logic [VALUE_BITS-1 : 0] out2;

always_comb OUT_VALUE1 <= out1;
always_comb OUT_VALUE2 <= out2;


// states register bank (distributed ram) implementation
logic [VALUE_BITS-1 : 0] states[8];
logic [VALUE_BITS-1 : 0] states_rd_data;
logic [VALUE_BITS-1 : 0] states_wr_data;
logic [2:0] states_rd_addr; 
logic [2:0] states_wr_addr; 
logic states_wren; 

// state register bank async read
always_comb states_rd_data <= states[states_rd_addr];
// state register bank sync write
always @(posedge CLK) begin
    if (states_wren)
        states[states_wr_addr] <= states_wr_data;
end

always_comb states_wren <= 'b1;

// keep 0 for first loop to init states to 0
logic filter_en;

// phase counter counts 0..CYCLE_COUNT-1
logic [2:0] phase_counter;
logic [2:0] phase_counter_delay1;
logic [2:0] phase_counter_delay2;
always_comb @(posedge CLK) begin
    if (RESET || phase_counter == (CYCLE_COUNT-1)) begin
        phase_counter <= 'b0;
        phase_counter_delay1 <= 'b0;
        phase_counter_delay2 <= 'b0;
        filter_en <= ~RESET;
    end else begin
        phase_counter_delay2 <= phase_counter_delay1;
        phase_counter_delay1 <= phase_counter;
        phase_counter <= phase_counter + 1;
        filter_en <= filter_en;
    end
end

// 0: use IN_VALUE1, 1: use IN_VALUE2
logic filter_value_addr;
always_comb filter_value_addr <= phase_counter[0];
// 0: use IN_VALUE, 1: use previous stage output
logic filter_value_mux;
always_comb filter_value_mux <= (phase_counter[2:1] == 2'b00) ? 1'b0 : 1'b1;

always_comb states_rd_addr <= phase_counter;
always_comb states_wr_addr <= phase_counter_delay2;

// latch channel1 output
always_ff @(posedge CLK) begin
    if (RESET) begin
        out1 <= 'b0;
    end else if (states_wr_addr == (STAGE_COUNT - 1) * 2 + 0) begin
        out1 <= states_wr_data;
    end
end

// latch channel2 output
always_ff @(posedge CLK) begin
    if (RESET)
        out2 <= 'b0;
    else if (states_wr_addr == (STAGE_COUNT - 1) * 2 + 1)
        out2 <= states_wr_data;
end

iir_filter_pow2k_1stage_pipeline
#(
    .K_SHIFT_BITS(K_SHIFT_BITS),
    .VALUE_BITS(VALUE_BITS),
    .USE_INPUT_REG(1),
    .USE_OUTPUT_REG(1)
)
iir_filter_pow2k_1stage_pipeline_inst
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    .CLK,

    // reset, active 1
    .RESET,

    // 1 to enable processing, 0 to force output
    .EN(filter_en),
    
    // filter input value1
    .IN_VALUE1,
    // filter input value2
    .IN_VALUE2,

    // previous state
    .IN_STATE(states_rd_data),
    
    // 0: use IN_VALUE, 1: use pervious value from OUT_STATE
    .IN_VALUE_MUX(filter_value_mux),
    // 0: use IN_VALUE1, 1: use IN_VALUE2
    .IN_VALUE_ADDR(filter_value_addr),

    // new state (filter output)
    .OUT_STATE(states_wr_data)
);



endmodule
