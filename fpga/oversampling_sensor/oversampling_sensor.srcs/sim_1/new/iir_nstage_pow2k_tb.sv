`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2020 04:16:44 PM
// Design Name: 
// Module Name: iir_nstage_pow2k_tb
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


module iir_nstage_pow2k_tb(

    );

// filter coefficient is 1 / (1 << K_SHIFT_BITS) : instead of multiply, right shift is used
localparam K_SHIFT_BITS = 8;
// number of bits in filter input and output
localparam VALUE_BITS = 30;
// filter output is being updated once per CYCLE_COUNT (can be bigger than number of stages to align output rate with other clock)
localparam CYCLE_COUNT = 4;
// number of IIR filter stages, should be <= CYCLE_COUNT
localparam STAGE_COUNT = 4;


// clock signal, inputs and outputs are being changed on raising edge of this clock 
logic CLK;

// reset, active 1
logic RESET;

// filter input value
logic [VALUE_BITS-1 : 0] IN_VALUE;

// filter output value
logic [VALUE_BITS-1 : 0] OUT_VALUE;


//logic [2:0] debug_phase_counter;
//logic debug_filter_en;
//logic [2:0] debug_states_wr_addr;
//logic [VALUE_BITS-1 : 0] debug_states_wr_data;
//logic [2:0] debug_states_rd_addr;
//logic [VALUE_BITS-1 : 0] debug_states_rd_data;

//logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_scaled_in_state;
//logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_diff_in_state;
//logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_diff_in_value;
//logic signed [VALUE_BITS+K_SHIFT_BITS-1 : 0] debug_filter_sum;

iir_nstage_pow2k
#(
    // filter coefficient is 1 / (1 << K_SHIFT_BITS) : instead of multiply, right shift is used
    .K_SHIFT_BITS(K_SHIFT_BITS),
    // number of bits in filter input and output
    .VALUE_BITS(VALUE_BITS),
    // filter output is being updated once per CYCLE_COUNT (can be bigger than number of stages to align output rate with other clock)
    .CYCLE_COUNT(CYCLE_COUNT),
    // number of IIR filter stages, should be <= CYCLE_COUNT
    .STAGE_COUNT(STAGE_COUNT)
)
iir_nstage_pow2k_inst
(
    .*
);

always begin
    // 150MHz
    #3.33333333333333 CLK = 0;
    #3.33333333333333 CLK = 1;
end

int cycle_count = 0;
always begin
    @(posedge CLK) ;
    @(posedge CLK) ;
    @(posedge CLK) ;
    @(posedge CLK) ;
    #4 $display("\t%f\t%d", cycle_count * CYCLE_COUNT / 3125.0, OUT_VALUE);
    cycle_count++;
end

initial begin
    IN_VALUE = 0;
    RESET = 0;
    #13 RESET = 1;
    #120 RESET = 0;
    
    #150    IN_VALUE =    1000000;
    #150000 IN_VALUE = 1000000000;
    #150000 IN_VALUE =  500000000;
    #150000 IN_VALUE =  100000000;
    #150000 IN_VALUE = 1000000000;
    
    #150000 $finish();
end

endmodule
