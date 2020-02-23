`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2020 09:37:43 AM
// Design Name: 
// Module Name: ref_frequency_gen
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


module ref_frequency_gen
#(
    // power of two of output size (3 for 8, 4 for 16, 5 for 32) 
    parameter OVERSAMPLING = 5,
    // oversampling bits
    parameter OVERSAMPLING_BITS = (1<<OVERSAMPLING),
    // base counter size - w/o oversampling bits, e.g. 8 for min frequency 600KHz with 150MHz bus and x8 oversampling 
    parameter BASE_COUNTER_BITS = 8,
    // full counter size, for 300KHz min frequency, should be 12 for OVERSAMPLING=3, 13 for OVERSAMPLING=4, 14 for OVERSAMPLING=5
    parameter COUNTER_BITS = BASE_COUNTER_BITS + OVERSAMPLING
)
(
    // 150MHz 
    input logic CLK,
    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,

    // 1 to write new period value    
    input logic WR_PERIOD,
    // reference frequency period value in CLK*OVERSAMPLING_BITS (1200MHz for CLK=150MHz and x8 oversampling) clock cycles
    // min possible frequency with 12 bit counter: 300KHz
    // period resolution near 1MHz: 
    input logic [COUNTER_BITS-1:0] PERIOD_VALUE,
    // parallel output
    output logic [OVERSAMPLING_BITS-1:0] OUT
    
    , output logic debug_phase_index
    , output logic debug_phase_end
//    , output logic debug_end_of_phase_0
//    , output logic debug_end_of_phase_1
//    , output logic debug_end_of_phase_2
//    , output logic debug_end_of_phase_3
    , output logic [COUNTER_BITS-1:0] debug_counter
);

logic [COUNTER_BITS-1:0] period_reg;

logic [COUNTER_BITS-1:0] counter;

logic [COUNTER_BITS-1:0] period_middle; // 2/4 of period

always_ff @(posedge CLK) begin
    if (RESET) begin
        period_reg <= {4'b0100, {COUNTER_BITS-4{1'b0}}};
    end else if (WR_PERIOD) begin
        period_reg <= PERIOD_VALUE;
    end
end

logic phase_index;
// next bits offset for phase
logic [OVERSAMPLING-1:0] bits_offset;
always_comb bits_offset
      <= ~phase_index       ? period_middle[OVERSAMPLING-1:0]
      :/*phase_index ==1 */   counter[OVERSAMPLING-1:0];
logic [OVERSAMPLING_BITS-1:0] next_bits_change;
always_comb next_bits_change <= ({OVERSAMPLING_BITS{1'b1}} << (bits_offset)) ^ ({OVERSAMPLING_BITS{phase_index}});

logic [COUNTER_BITS:OVERSAMPLING] phase_end_cycle;
always_comb phase_end_cycle
      <= ~phase_index     ? period_middle[COUNTER_BITS-1:OVERSAMPLING]
      :/* phase_index */    'b0;
logic phase_end;
always_comb
      phase_end <= phase_end_cycle == counter[COUNTER_BITS-1:OVERSAMPLING]; 


logic [COUNTER_BITS-1:0] next_counter_load;
always_comb next_counter_load = period_reg + counter[OVERSAMPLING-1:0]; //({1'b1, {OVERSAMPLING{1'b0}} } - counter[OVERSAMPLING-1:0]);

// counter updates
always_ff @(posedge CLK) begin
    if (RESET) begin
        counter <= {4'b0100, {COUNTER_BITS-4{1'b0}}};
        period_middle <= {4'b0010, {COUNTER_BITS-4{1'b0}}};
    end else begin
        if ( phase_end && phase_index ) begin
            // last cycle
            counter = next_counter_load;
            period_middle <= next_counter_load - (period_reg >> 1);
        end else begin
            counter[COUNTER_BITS-1:OVERSAMPLING] <= counter[COUNTER_BITS-1:OVERSAMPLING] - 1;
        end
    end
end

// main phase
logic state0;
logic [OVERSAMPLING_BITS-1:0] out_reg0;
always_comb OUT <= out_reg0;


always_ff @(posedge CLK) begin
    if (RESET) begin
        state0 <= 1'b0;
        out_reg0 <= 'b0;
        phase_index <= 'b0;
    end else begin
        if (phase_end) begin
            // main phase change
            out_reg0 <= next_bits_change;
            state0 <= ~phase_index;
            phase_index <= ~phase_index;
        end else begin
            out_reg0 <= {OVERSAMPLING_BITS{state0}};
            state0 <= state0;
            phase_index <= phase_index;
        end
    end
end

always_comb begin
    debug_phase_index <= phase_index;
    debug_phase_end <= phase_end;
    debug_counter <= counter;
end


endmodule
