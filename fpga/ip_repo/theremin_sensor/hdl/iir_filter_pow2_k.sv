`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/09/2019 08:43:37 AM
// Design Name: 
// Module Name: iir_filter_pow2_k
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Dual channel IIR filter with variable number of stages and filter K == 1/(2^N) 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(* use_dsp = "yes" *)
module iir_filter_pow2_k
#(
    parameter FILTER_K_SHIFT = 6,
    parameter DATA_BITS = 32
)
(
    // input clock, ~100MHz
    input CLK,
    // reset signal, active 1
    input RESET,
    
    // number of filter stages less one
    input logic [2:0] MAX_STAGE,

    // input value for channel A    
    input logic [DATA_BITS-1:0] IN_VALUE_A,
    // input value for channel B    
    input logic [DATA_BITS-1:0] IN_VALUE_B,
    // output value for channel A    
    output logic [DATA_BITS-1:0] OUT_VALUE_A,
    // output value for channel B    
    output logic [DATA_BITS-1:0] OUT_VALUE_B

    //, output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_rd_data
    //, output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_wr_data
    //, output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_in_value
    //, output logic [3:0] debug_stage_index
    //, output logic debug_init_done
    
);

localparam INTERNAL_BITS = DATA_BITS + FILTER_K_SHIFT;

// distributed RAM
logic [INTERNAL_BITS-1:0] state_regs[16]; // = {0, 0, 0, 0};
logic [INTERNAL_BITS-1:0] in_value;
logic [3:0] stage_index;

logic [INTERNAL_BITS-1:0] state_rd_data;
logic [INTERNAL_BITS-1:0] state_wr_data;

logic [DATA_BITS-1:0] out_data_a;
logic [DATA_BITS-1:0] out_data_b;

// distributed RAM async read
always_comb state_rd_data <= state_regs[stage_index];
// distributed RAM sync write
always_ff @(posedge CLK) begin
    state_regs[stage_index] <= state_wr_data;
end

logic signed [DATA_BITS:0] diff;
always_comb diff <= in_value[INTERNAL_BITS-1:FILTER_K_SHIFT] - state_rd_data[INTERNAL_BITS-1:FILTER_K_SHIFT];

// right shifted diff
logic signed [INTERNAL_BITS-1:0] diff_shifted;
always_comb diff_shifted <= { {FILTER_K_SHIFT - 1{diff[DATA_BITS]}}, diff };

logic init_done;

logic [INTERNAL_BITS-1:0] adder2;
always_comb adder2 <= state_rd_data + diff_shifted;
always_comb state_wr_data <= init_done ? adder2 : 'b0;

always_ff @(posedge CLK) begin
    if (RESET) begin
        stage_index <= 'b0;
        in_value <= 'b0;
        out_data_a <= 'b0;
        out_data_b <= 'b0;
        init_done <= 'b0;
    end else begin
        if (!init_done) begin
            if (stage_index == 4'b1111) begin
                init_done <= 'b1;
                in_value <= {
                        IN_VALUE_A,
                        { (FILTER_K_SHIFT) {1'b0} }
                };
            end
            stage_index <= stage_index + 1;
        end else if (stage_index[2:0] == MAX_STAGE) begin
            // last stage
            in_value <= {
                    stage_index[3] ? IN_VALUE_A : IN_VALUE_B, 
                    { (FILTER_K_SHIFT) {1'b0} } 
            };
            if (stage_index[3])
                out_data_b <= state_wr_data[INTERNAL_BITS-1:FILTER_K_SHIFT];
            else
                out_data_a <= state_wr_data[INTERNAL_BITS-1:FILTER_K_SHIFT];
            
            stage_index[2:0] <= 3'b0;
            stage_index[3] <= ~stage_index[3];
        end else begin
            // intermediate stage
            in_value <= state_wr_data;
            stage_index <= stage_index + 1;
        end
    end
end

always_comb OUT_VALUE_A <= out_data_a;
always_comb OUT_VALUE_B <= out_data_b;


//always_comb debug_state_rd_data <= state_rd_data;
//always_comb debug_state_wr_data <= state_wr_data;
//always_comb debug_stage_index <= stage_index;
//always_comb debug_in_value <= in_value;
//always_comb debug_init_done <= init_done;

endmodule
