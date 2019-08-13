`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/30/2019 10:16:44 AM
// Design Name: 
// Module Name: oversampling_iserdes_bit_detector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     Converts 64bit parallel output of deserializer to change flag and changed bit index
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oversampling_iserdes_bit_detector(
    // 200MHz
    input logic CLK_PARALLEL,

    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    input logic CE,
    
    // parallel oversampled deserialized output    
    input logic [63:0] PARALLEL_IN,

    // 1 for one cycle if state is changed
    output logic CHANGED_FLAG,
    
    // when CHANGED_FLAG==1, contains number of changed bit
    output logic [5:0] CHANGED_BIT
);

logic last_state;
logic ce_delay1;
logic ce_delay2;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        last_state <= 'b0;
        ce_delay1 <= 'b0;
        ce_delay2 <= 'b0;
    end else begin
        ce_delay2 <= ce_delay1;
        ce_delay1 <= CE;
        last_state <= PARALLEL_IN[63] & CE & ce_delay1 & ce_delay2;
    end
end

logic stage1_quad_changed_flags[16];
logic [1:0] stage1_quad_changed_bit[16];

logic stage2_word_changed_flags[4];
logic [3:0] stage2_word_changed_bit[4];

genvar i;
generate

    for (i = 0; i < 16; i = i + 1) begin
        always_ff @(posedge CLK_PARALLEL) begin
            if (RESET) begin
                stage1_quad_changed_flags[i] <= 'b0;
                stage1_quad_changed_bit[i] <= 'b0;
            end else begin
                stage1_quad_changed_flags[i]  <=  PARALLEL_IN[i*4 + 3] != last_state;
                stage1_quad_changed_bit[i]    <=  PARALLEL_IN[i*4 + 0] != last_state ? 2'b00
                                                : PARALLEL_IN[i*4 + 1] != last_state ? 2'b01
                                                : PARALLEL_IN[i*4 + 2] != last_state ? 2'b10
                                                :                                      2'b11;
            end
        end
    end

    for (i = 0; i < 4; i = i + 1) begin
        always_ff @(posedge CLK_PARALLEL) begin
            if (RESET | ~CE | ~ce_delay1 | ~ce_delay2) begin
                stage2_word_changed_flags[i] <= 'b0;
                stage2_word_changed_bit[i] <= 'b0;
            end else begin
                stage2_word_changed_flags[i]  <=  stage1_quad_changed_flags[i*4 + 0] 
                                                | stage1_quad_changed_flags[i*4 + 1] 
                                                | stage1_quad_changed_flags[i*4 + 2] 
                                                | stage1_quad_changed_flags[i*4 + 3];
                stage2_word_changed_bit[i]    <=  stage1_quad_changed_flags[i*4 + 0] ? { 2'b00, stage1_quad_changed_bit[i*4 + 0] }
                                               :  stage1_quad_changed_flags[i*4 + 1] ? { 2'b01, stage1_quad_changed_bit[i*4 + 1] }
                                               :  stage1_quad_changed_flags[i*4 + 2] ? { 2'b10, stage1_quad_changed_bit[i*4 + 2] }
                                               :                                       { 2'b11, stage1_quad_changed_bit[i*4 + 3] };
            end
        end
    end

endgenerate

logic stage3_change_flag;
logic [5:0] stage3_changed_bit;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        stage3_change_flag <= 'b0;
        stage3_changed_bit <= 'b0;
    end else begin
        stage3_change_flag    <=  stage2_word_changed_flags[0] 
                                | stage2_word_changed_flags[1] 
                                | stage2_word_changed_flags[2] 
                                | stage2_word_changed_flags[3];
        stage3_changed_bit    <=  stage2_word_changed_flags[0] ? { 2'b00, stage2_word_changed_bit[0] }
                                : stage2_word_changed_flags[1] ? { 2'b01, stage2_word_changed_bit[1] }
                                : stage2_word_changed_flags[2] ? { 2'b10, stage2_word_changed_bit[2] }
                                :                                { 2'b11, stage2_word_changed_bit[3] };
    end
end

// 1 for one cycle if state is changed
always_comb CHANGED_FLAG <= stage3_change_flag;

// when CHANGED_FLAG==1, contains number of changed bit
always_comb CHANGED_BIT <= stage3_changed_bit;


endmodule
