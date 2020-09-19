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


module ref_frequency_gen_2phase
#(
    // power of two of output size (3 for 8, 4 for 16, 5 for 32) 
    parameter OVERSAMPLING = 5,
    // oversampling bits
    parameter OVERSAMPLING_BITS = (1<<OVERSAMPLING),
    // base counter size - w/o oversampling bits, e.g. 8 for min frequency 600KHz with 150MHz bus and x8 oversampling 
    parameter BASE_COUNTER_BITS = 8,
    // full counter size, for 300KHz min frequency, should be 12 for OVERSAMPLING=3, 13 for OVERSAMPLING=4, 14 for OVERSAMPLING=5
    parameter COUNTER_BITS = BASE_COUNTER_BITS + OVERSAMPLING,
    // 1 for single phase (OUT only, OUT1 will be 0), 2 for both 0 and PI/2 phases (OUT and OUT1)
    parameter PHASES_COUNT = 2  
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
    output logic [OVERSAMPLING_BITS-1:0] OUT,
    // parallel output - phase 1: PI/2
    output logic [OVERSAMPLING_BITS-1:0] OUT1
    
    , output logic [1:0] debug_phase_index
    , output logic debug_phase_end
//    , output logic debug_end_of_phase_0
//    , output logic debug_end_of_phase_1
//    , output logic debug_end_of_phase_2
//    , output logic debug_end_of_phase_3
    , output logic [COUNTER_BITS-1:0] debug_counter
);

logic [COUNTER_BITS-1:0] period_reg;

logic [COUNTER_BITS-1:0] counter;

// phase_0 is start of cycle - full period value 
logic [COUNTER_BITS-1:0] phase_1; // 3/4 of period
logic [COUNTER_BITS-1:0] phase_2; // 2/4 of period
logic [COUNTER_BITS-1:0] phase_3; // 1/4 of period
// phase_4 is 0 - end of cycle 

//logic end_of_phase_0; // starting phase 1
//logic end_of_phase_1; // starting phase 2
//logic end_of_phase_2; // starting phase 3
//logic end_of_phase_3; // starting phase 0
//always_comb end_of_phase_0 <= PHASES_COUNT > 1 ? (counter[COUNTER_BITS-1:OVERSAMPLING] == phase_1[COUNTER_BITS-1:OVERSAMPLING]) : 0;
//always_comb end_of_phase_1 <= (counter[COUNTER_BITS-1:OVERSAMPLING] == phase_2[COUNTER_BITS-1:OVERSAMPLING]);
//always_comb end_of_phase_2 <= PHASES_COUNT > 1 ? (counter[COUNTER_BITS-1:OVERSAMPLING] == phase_3[COUNTER_BITS-1:OVERSAMPLING]) : 0;
//always_comb end_of_phase_3 <= ( |counter[COUNTER_BITS-1:OVERSAMPLING] == 1'b0 );

always_ff @(posedge CLK) begin
    if (RESET) begin
        period_reg <= {4'b0100, {COUNTER_BITS-4{1'b0}}};
    end else if (WR_PERIOD) begin
        period_reg <= PERIOD_VALUE;
    end
end

logic [1:0] phase_index;
// next bits offset for phase
logic [OVERSAMPLING-1:0] bits_offset;
always_comb bits_offset
      <= (phase_index == 2'b00) ? phase_1[OVERSAMPLING-1:0]
      :  (phase_index == 2'b01) ? phase_2[OVERSAMPLING-1:0]
      :  (phase_index == 2'b10) ? phase_3[OVERSAMPLING-1:0]
      :/*(phase_index == 2'b11)*/ counter[OVERSAMPLING-1:0];
logic [OVERSAMPLING_BITS-1:0] next_bits_change;
always_comb next_bits_change <= ({OVERSAMPLING_BITS{1'b1}} << (bits_offset)) ^ ({OVERSAMPLING_BITS{phase_index[1]}});

logic [COUNTER_BITS:OVERSAMPLING] phase_end_cycle;
always_comb phase_end_cycle
      <= (phase_index == 2'b00) ? phase_1[COUNTER_BITS-1:OVERSAMPLING]
      :  (phase_index == 2'b01) ? phase_2[COUNTER_BITS-1:OVERSAMPLING]
      :  (phase_index == 2'b10) ? phase_3[COUNTER_BITS-1:OVERSAMPLING]
      :/*(phase_index == 2'b11)*/ 'b0;
logic phase_end;
always_comb
      phase_end <= phase_end_cycle == counter[COUNTER_BITS-1:OVERSAMPLING]; 

//// transition from 0 to 1 at bit with specified index
//function [OVERSAMPLING_BITS-1:0] oversampledBitChange01;
//    input logic [OVERSAMPLING-1:0] bitIndex;
//    begin
//        oversampledBitChange01 = ({OVERSAMPLING_BITS{1'b1}} << bitIndex);
//    end
//endfunction

//// transition from 1 to 0 at bit with specified index
//function [OVERSAMPLING_BITS-1:0] oversampledBitChange10;
//    input logic [OVERSAMPLING-1:0] bitIndex;
//    begin
//        oversampledBitChange10 = ~({OVERSAMPLING_BITS{1'b1}} << bitIndex);
//    end
//endfunction

logic [COUNTER_BITS-1:0] next_counter_load;
always_comb next_counter_load = period_reg + counter[OVERSAMPLING-1:0]; //({1'b1, {OVERSAMPLING{1'b0}} } - counter[OVERSAMPLING-1:0]);

// counter updates
always_ff @(posedge CLK) begin
    if (RESET) begin
        counter <= {4'b0100, {COUNTER_BITS-4{1'b0}}};
        phase_1 <= PHASES_COUNT > 1 ? {4'b0011, {COUNTER_BITS-4{1'b0}}} : 0;
        phase_2 <= {4'b0010, {COUNTER_BITS-4{1'b0}}};
        phase_3 <= PHASES_COUNT > 1 ? {4'b0001, {COUNTER_BITS-4{1'b0}}} : 0;
    end else begin
        if ( phase_end && (phase_index==2'b11) ) begin
            // last cycle
            counter = next_counter_load;
            phase_1 <= PHASES_COUNT > 1 ? next_counter_load - (period_reg >> 2) : 0;
            phase_2 <= next_counter_load - (period_reg >> 1);
            phase_3 <= PHASES_COUNT > 1 ? next_counter_load - (period_reg >> 1) - (period_reg >> 2) : 0;
        end else begin
            counter[COUNTER_BITS-1:OVERSAMPLING] <= counter[COUNTER_BITS-1:OVERSAMPLING] - 1;
        end
    end
end

// main phase
logic state0;
logic [OVERSAMPLING_BITS-1:0] out_reg0;
always_comb OUT <= out_reg0;
// PI/2 phase
logic state1;
logic [OVERSAMPLING_BITS-1:0] out_reg1;
always_comb OUT1 <= out_reg1;


always_ff @(posedge CLK) begin
    if (RESET) begin
        state0 <= 1'b0;
        out_reg0 <= 'b0;
        state1 <= 1'b1;
        out_reg1 <= {OVERSAMPLING_BITS{1'b1}};
        phase_index <= (PHASES_COUNT>1) ? 2'b00 : 2'b01;
    end else begin
        if (phase_end) begin
            if (phase_index[0]) begin
                // main phase change
                state0 <= ~phase_index[1];
                out_reg0 <= next_bits_change; //oversampledBitChange01(phase_2[OVERSAMPLING-1:0]);
                if (PHASES_COUNT>1) begin
                    state1 <= state1;
                    out_reg1 <= {OVERSAMPLING_BITS{state1}};
                end
            end else begin
                // PI/2 phase change
                state0 <= state0;
                out_reg0 <= {OVERSAMPLING_BITS{state0}};
                
                if (PHASES_COUNT>1) begin
                    out_reg1 <= next_bits_change;
                    state1 <= phase_index[1];
                end
            end
            phase_index <= phase_index + (PHASES_COUNT == 1 ? 2 : 1);
        end else begin
            out_reg0 <= {OVERSAMPLING_BITS{state0}};
            state0 <= state0;
            if (PHASES_COUNT>1) begin
                out_reg1 <= {OVERSAMPLING_BITS{state1}};
                state1 <= state1;
            end
            phase_index <= phase_index;
        end
    end
end
/*
always_ff @(posedge CLK) begin
    if (RESET) begin
        state1 <= 1'b1;
        out_reg1 <= 'b0;
    end else if (PHASES_COUNT > 1) begin
        if ( end_of_phase_0 ) begin
            // 1/4
            out_reg1 <= oversampledBitChange10(phase_1[OVERSAMPLING-1:0]);
            state1 <= 1'b0;
        end else if ( end_of_phase_2 ) begin
            // 3/4
            out_reg1 <= oversampledBitChange01(phase_3[OVERSAMPLING-1:0]);
            state1 <= 1'b1;
        end else begin
            out_reg1 <= {OVERSAMPLING_BITS{state1}};
            state1 <= state1;
        end
    end
end
*/

always_comb begin
    debug_phase_index <= phase_index;
    debug_phase_end <= phase_end;
//    debug_end_of_phase_0 <= end_of_phase_0;
//    debug_end_of_phase_1 <= end_of_phase_1;
//    debug_end_of_phase_2 <= end_of_phase_2;
//    debug_end_of_phase_3 <= end_of_phase_3;
    debug_counter <= counter;
end


endmodule
