`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2019 07:56:58 AM
// Design Name: 
// Module Name: iir_multistage_dblchannel
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


module iir_multistage_dblchannel
#(
    parameter FILTER_K_SHIFT = 8,
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

//    , output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_rd_data
//    , output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_state_wr_data
//    , output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_diff_reg
//    , output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_adder_reg
//    , output logic [DATA_BITS + FILTER_K_SHIFT - 1:0] debug_new_value
//    , output logic [3:0] debug_stage_index
//    , output logic debug_init_done
    
);

localparam INTERNAL_BITS = DATA_BITS + FILTER_K_SHIFT;

//=====================================================
// distributed RAM
// interface
logic [3:0] state_rd_addr;
logic [3:0] state_wr_addr;
logic [INTERNAL_BITS-1:0] state_rd_data;
logic [INTERNAL_BITS-1:0] state_wr_data;
// storage
logic [INTERNAL_BITS-1:0] state_regs[16];
// distributed RAM async read
always_comb state_rd_data <= state_regs[state_rd_addr];
// distributed RAM sync write
always_ff @(posedge CLK) begin
    state_regs[state_wr_addr] <= state_wr_data;
end
//=====================================================

logic init_done;
logic [3:0] stage_index;
logic [3:0] stage_index_delay1;
logic [3:0] stage_index_delay2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        stage_index_delay1 <= 'b0;
        stage_index_delay2 <= 'b0;
        stage_index <= 'b0;
        init_done <= 'b0;
    end else begin
        stage_index_delay2 <= stage_index_delay1;
        stage_index_delay1 <= stage_index;
        if (init_done) begin
            if (stage_index == {MAX_STAGE, 1'b1})
                stage_index <= 'b0;
            else
                stage_index <= stage_index + 1;
        end else begin
            if (stage_index == 'b1111)
                init_done <= 'b1;
            stage_index <= stage_index + 1;
        end
    end
end

// state_rd_data delayed by 1 clock cycle
logic [INTERNAL_BITS-1:0] state_rd_data_delay1;
always_ff @(posedge CLK) begin
    if (RESET | ~init_done) begin
        state_rd_data_delay1 <= 'b0;
    end else begin
        state_rd_data_delay1 <= state_rd_data;
    end
end

logic [INTERNAL_BITS-1:0] new_value;

logic [INTERNAL_BITS-1:0] subtractor_in_a;
logic [INTERNAL_BITS-1:0] subtractor_in_b;
(* use_dsp = "yes" *)
logic [INTERNAL_BITS-1:0] subtractor_out;
always_comb subtractor_out <= subtractor_in_a - subtractor_in_b;

always_comb subtractor_in_a <= { {FILTER_K_SHIFT{1'b0}}, new_value[INTERNAL_BITS-1:FILTER_K_SHIFT]};
always_comb subtractor_in_b <= { {FILTER_K_SHIFT{1'b0}}, state_rd_data[INTERNAL_BITS-1:FILTER_K_SHIFT]};
logic [INTERNAL_BITS-1:0] diff_reg;
always_ff @(posedge CLK) begin
    if (RESET | ~init_done) begin
        diff_reg <= 'b0;
    end else begin
        diff_reg <= subtractor_out;
    end
end

logic [INTERNAL_BITS-1:0] adder_in_a;
logic [INTERNAL_BITS-1:0] adder_in_b;
(* use_dsp = "yes" *)
logic [INTERNAL_BITS-1:0] adder_out;
always_comb adder_out <= adder_in_a + adder_in_b;

always_comb adder_in_a <= state_rd_data_delay1;
// sign extended diff right shifted by FILTER_K_SHIFT
always_comb adder_in_b <= diff_reg; //{ { (FILTER_K_SHIFT) {diff_reg[INTERNAL_BITS-1]} }, diff_reg[INTERNAL_BITS-1:FILTER_K_SHIFT]};
logic [INTERNAL_BITS-1:0] adder_reg;
always_ff @(posedge CLK) begin
    if (RESET | ~init_done) begin
        adder_reg <= 'b0;
    end else begin
        adder_reg <= adder_out;
    end
end

always_comb state_rd_addr <= stage_index;
always_comb state_wr_addr <= stage_index_delay2;
always_comb state_wr_data <= adder_reg;

always_comb new_value <= 
          (stage_index == 'b0000) ? { IN_VALUE_A, { FILTER_K_SHIFT {1'b0}} }
        : (stage_index == 'b0001) ? { IN_VALUE_B, { FILTER_K_SHIFT {1'b0}} }
        :                           adder_reg;

logic [DATA_BITS-1:0] out_data_a;
logic [DATA_BITS-1:0] out_data_b;

always_ff @(posedge CLK) begin
    if (RESET | ~init_done) begin
        out_data_a <= 'b0;
        out_data_b <= 'b0;
    end else begin
        if (stage_index == 4'b0000)
            out_data_a <= adder_reg[INTERNAL_BITS-1:FILTER_K_SHIFT];
        if (stage_index == 4'b0001)
            out_data_b <= adder_reg[INTERNAL_BITS-1:FILTER_K_SHIFT];
    end
end

always_comb OUT_VALUE_A <= out_data_a;
always_comb OUT_VALUE_B <= out_data_b;


//always_comb debug_state_rd_data <= state_rd_data;
//always_comb debug_state_wr_data <= state_wr_data;
//always_comb debug_stage_index <= stage_index;
//always_comb debug_new_value <= new_value;
//always_comb debug_init_done <= init_done;
//always_comb debug_diff_reg <= diff_reg;
//always_comb debug_adder_reg <= adder_reg;

endmodule
