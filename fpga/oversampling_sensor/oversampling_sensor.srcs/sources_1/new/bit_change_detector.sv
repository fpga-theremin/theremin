`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vadim Lopatin
// 
// Create Date: 07/30/2019 10:16:44 AM
// Design Name: 
// Module Name: oversampling_iserdes_bit_detector
// Project Name: 
// Target Devices: Xilinx Series 7 
// Tool Versions: 
// Description: 
//     Detects changed in deserialized input signal.
//     Converts parallel input into changed bit number, edge flag and edge type
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    parameter OVERSAMPLING = 6
) 
(
    // 150MHz
    input logic CLK,

    // reset, active 1, must be synchronous to CLK !!!
    input logic RESET,
    
    // parallel oversampled deserialized input    
    input logic [(1 << OVERSAMPLING) - 1 : 0] PARALLEL_IN,

    // 1 for one cycle if state is changed
    output logic CHANGE_FLAG,

    // 1 if change is raising edge, 0 if falling edge
    output logic CHANGE_EDGE,
    
    // when CHANGED_FLAG==1, contains number of changed bit
    output logic [OVERSAMPLING - 1 : 0] CHANGED_BIT
);

// returns index of changed bit; 0 if input_bits[0] != previous_state, otherwise 1 if input_bits[1] != previous_state... etc
//         0 when no change detected
function logic[1:0] changedBitIndex4;
    // input bits
    input logic [3:0] input_bits;
    // previous value - index of first bit != previous_state will be reported as function result 
    input logic previous_state;
    
    if (input_bits[0] != previous_state)
        changedBitIndex4 = 2'b00;
    else if (input_bits[1] != previous_state)
        changedBitIndex4 = 2'b01;
    else if (input_bits[2] != previous_state)
        changedBitIndex4 = 2'b10;
    else if (input_bits[3] != previous_state)
        changedBitIndex4 = 2'b11;
    else
        changedBitIndex4 = 2'b00;
endfunction

// returns index of changed bit; 0 if input_bits[0] != previous_state, otherwise 1 if input_bits[1] != previous_state... etc
//         0 when no change detected
function logic changedBitIndex2;
    // input bits
    input logic [1:0] input_bits;
    // previous value - index of first bit != previous_state will be reported as function result 
    input logic previous_state;
    
    if (input_bits[0] != previous_state)
        changedBitIndex2 = 1'b0;
    else if (input_bits[1] != previous_state)
        changedBitIndex2 = 1'b1;
    else
        changedBitIndex2 = 1'b0;
endfunction

// tracking last state
logic state;
logic state_delay1;
logic changed;
logic changed_delay1;
always_ff @(posedge CLK) begin
    if (RESET) begin
        state <= 'b0;
        //new_state <= 'b0;
        state_delay1 <= 'b0;
        changed <= 'b0;
        changed_delay1 <= 'b0;
    end else begin
        changed_delay1 <= changed;
        changed <= (state != PARALLEL_IN[(1 << OVERSAMPLING) - 1]);
        state_delay1 <= state; //new_state;
        state <= PARALLEL_IN[(1 << OVERSAMPLING) - 1];
    end
end

localparam QUAD_COUNT = 1 << (OVERSAMPLING-2);

generate

    // stage1
    // calculate indexes per quads
    logic [1:0] stage1[QUAD_COUNT];


    if (OVERSAMPLING == 3) begin
        logic stage1_quad_index;
        always_ff @(posedge CLK) begin
            if (RESET) begin
                CHANGE_EDGE <= 'b0;
                CHANGE_FLAG <= 'b0;
                CHANGED_BIT <= 'b0;
                stage1_quad_index <= 'b0;
            end else begin

                CHANGE_EDGE <= state;
                CHANGE_FLAG <= changed;
                CHANGED_BIT <= {stage1_quad_index, stage1[stage1_quad_index]};

                // index of first changed quad for each (8/2) group of 4 bits
                stage1_quad_index <= changedBitIndex2({PARALLEL_IN[7],PARALLEL_IN[3]}, state);
            end
        end

    end else if (OVERSAMPLING == 4) begin
        logic [1:0] stage1_quad_index;
        always_ff @(posedge CLK) begin
            if (RESET) begin
                CHANGE_EDGE <= 'b0;
                CHANGE_FLAG <= 'b0;
                CHANGED_BIT <= 'b0;
                stage1_quad_index <= 'b0;
            end else begin

                CHANGE_EDGE <= state;
                CHANGE_FLAG <= changed;
                CHANGED_BIT <= {stage1_quad_index, stage1[stage1_quad_index]};

                // index of first changed quad for each (16/4) group of 4 bits
                stage1_quad_index <= changedBitIndex4({PARALLEL_IN[15],PARALLEL_IN[11],PARALLEL_IN[7],PARALLEL_IN[3]}, state);
            end
        end
    end else if (OVERSAMPLING == 5) begin


        logic [1:0] stage1_quad_index[4];
        logic stage1_16_index;

        logic [3:0] stage2[4];
        logic stage2_16_index;

        always_ff @(posedge CLK) begin
            if (RESET) begin
                CHANGED_BIT <= 'b0;
                CHANGE_FLAG <= 'b0;
                CHANGE_EDGE <= 'b0;
                
                for (int i = 0; i < 4; i++)
                    stage1_quad_index[i] <= 'b0;

                stage1_16_index <= 'b0;
                
                for (int i = 0; i < 4; i++)
                    stage2[i] <= 'b0;

                stage2_16_index <= 'b0;
                
            end else begin
                CHANGE_EDGE <= state_delay1;
                CHANGE_FLAG <= changed_delay1;

                CHANGED_BIT <= { stage2_16_index, stage2[stage2_16_index] };

                // stage2 : muxes inside 16-bit groups
                for (int i = 0; i < 4; i++) begin
                    stage2[i] <= {stage1_quad_index[i], stage1[{i, stage1_quad_index[i]}]};
                end
                
                // index of first changed 16bit group - delayed by 1 cycle
                stage2_16_index <= stage1_16_index;
                            
                // index of first changed quad for each (64/16) group of 16 bits
                for (int i = 0; i < 4; i++) begin
                    stage1_quad_index[i] <= changedBitIndex4({PARALLEL_IN[i*16+15],PARALLEL_IN[i*16+11],PARALLEL_IN[i*16+7],PARALLEL_IN[i*16+3]}, state);
                end

                // index of first changed 16bit group
                stage1_16_index <= changedBitIndex2({PARALLEL_IN[31],PARALLEL_IN[15]}, state);
            end
        end

    end else if (OVERSAMPLING == 6) begin

        logic [1:0] stage1_quad_index[4];
        logic [1:0] stage1_16_index;

        logic [3:0] stage2[4];
        logic [1:0] stage2_16_index;

        always_ff @(posedge CLK) begin
            if (RESET) begin
                CHANGED_BIT <= 'b0;
                CHANGE_FLAG <= 'b0;
                CHANGE_EDGE <= 'b0;
                
                for (int i = 0; i < 4; i++)
                    stage1_quad_index[i] <= 'b0;

                stage1_16_index <= 'b0;
                
                for (int i = 0; i < 4; i++)
                    stage2[i] <= 'b0;

                stage2_16_index <= 'b0;
                
            end else begin
                CHANGE_EDGE <= state_delay1;
                CHANGE_FLAG <= changed_delay1;

                CHANGED_BIT <= { stage2_16_index, stage2[stage2_16_index] };

                // stage2 : muxes inside 16-bit groups
                for (int i = 0; i < 4; i++) begin
                    stage2[i] <= {stage1_quad_index[i], stage1[{i, stage1_quad_index[i]}]};
                end
                
                // index of first changed 16bit group - delayed by 1 cycle
                stage2_16_index <= stage1_16_index;
                            
                // index of first changed quad for each (64/16) group of 16 bits
                for (int i = 0; i < 4; i++) begin
                    stage1_quad_index[i] <= changedBitIndex4({PARALLEL_IN[i*16+15],PARALLEL_IN[i*16+11],PARALLEL_IN[i*16+7],PARALLEL_IN[i*16+3]}, state);
                end

                // index of first changed 16bit group
                stage1_16_index <= changedBitIndex4({PARALLEL_IN[63],PARALLEL_IN[47],PARALLEL_IN[31],PARALLEL_IN[15]}, state);
            end
        end


    end else begin
        $error("The only OVERSAMPLING parameter values supported are 3, 4, 5, and 6 (x8, x16, x32, x64), but %d is specified", OVERSAMPLING);
    end


    // first stage: bit index inside quads
    always_ff @(posedge CLK) begin
        if (RESET) begin
            for (int i = 0; i < QUAD_COUNT; i++)
                stage1[i] <= 'b0;
        end else begin
            // index of first changed bit for each of (64/4) quad 
            for (int i = 0; i < QUAD_COUNT; i++) begin
                stage1[i] = changedBitIndex4(PARALLEL_IN[i*4 +: 4], state);
            end
        end
    end

endgenerate


endmodule
