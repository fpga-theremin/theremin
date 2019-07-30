`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2019 12:17:42 PM
// Design Name: 
// Module Name: oversampling_iserdes_detector
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


module oversampling_iserdes_detector(
    // 200MHz
    input logic CLK_PARALLEL,

    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    
    // parallel oversampled deserialized output    
    input logic [63:0] PARALLEL_IN,

    // 1 for one cycle if state is changed
    output logic CHANGED_FLAG,
    
    // when CHANGED_FLAG==1, contains number of changed bit
    output logic [5:0] CHANGED_BIT
);

logic last_state;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        last_state <= 'b0;
    end else begin
        last_state <= PARALLEL_IN[63];
    end
end

`define ALWAYS_OVS_ISERDES_DETECTOR_INTERMEDIATE_STAGE  always_ff @(posedge CLK_PARALLEL)
//`define ALWAYS_OVS_ISERDES_DETECTOR_INTERMEDIATE_STAGE  always_comb

logic last_state_delay1;
logic change_flg_delay1;
logic [63:0] parallel_in_delay1;
logic [1:0] changed_quarter_delay1;

`ALWAYS_OVS_ISERDES_DETECTOR_INTERMEDIATE_STAGE begin
    if (RESET) begin
        last_state_delay1 <= 'b0;
        change_flg_delay1 <= 'b0;
        parallel_in_delay1 <= 'b0;
        changed_quarter_delay1 <= 'b0;
    end else begin
        if (PARALLEL_IN[15] != last_state)
            changed_quarter_delay1 <= 2'b00;
        else if (PARALLEL_IN[31] != last_state)
            changed_quarter_delay1 <= 2'b01;
        else if (PARALLEL_IN[47] != last_state)
            changed_quarter_delay1 <= 2'b10;
        else
            changed_quarter_delay1 <= 2'b11;
        last_state_delay1 <= last_state;
        change_flg_delay1 <= last_state ^ PARALLEL_IN[63];
        parallel_in_delay1 <= PARALLEL_IN;
    end
end

// delay1 inputs:
//     change_flg_delay1 is 1 if state is changed
//     last_state_delay1 is previous state
//     changed_quarter_delay1 is quarter of 64 bits which is changed: 00=[15:0], 01=[31:16], 10:[]
//     parallel_in_delay1 is input delayed by 1 cycle

logic last_state_delay2;
logic change_flg_delay2;
logic [15:0] parallel_in_quarter_delay2;
logic [1:0] changed_quarter_delay2;


always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        last_state_delay2 <= 'b0;
        change_flg_delay2 <= 'b0;
        parallel_in_quarter_delay2 <= 'b0;
        changed_quarter_delay2 <= 'b0;
    end else begin
        last_state_delay2 <= last_state_delay1;
        change_flg_delay2 <= change_flg_delay1;
        parallel_in_quarter_delay2 <=
              (changed_quarter_delay1 == 2'b00) ? parallel_in_delay1[15:0]
            : (changed_quarter_delay1 == 2'b01) ? parallel_in_delay1[31:16]
            : (changed_quarter_delay1 == 2'b10) ? parallel_in_delay1[47:32]
            :                                     parallel_in_delay1[63:48];
        changed_quarter_delay2 <= changed_quarter_delay1;
    end
end

// delay2 inputs:
//     change_flg_delay2 is 1 if state is changed
//     last_state_delay2 is previous state
//     changed_quarter_delay2 is quarter of 64 bits which is changed: 00=[15:0], 01=[31:16], 10:[]
//     parallel_in_quarter_delay2 is input delayed by 1 cycle

logic last_state_delay3;
logic change_flg_delay3;
logic [15:0] parallel_in_quarter_delay3;
logic [1:0] changed_quarter_delay3;
logic [1:0] changed_quarter_quad_delay3;


`ALWAYS_OVS_ISERDES_DETECTOR_INTERMEDIATE_STAGE begin
    if (RESET) begin
        last_state_delay3 <= 'b0;
        change_flg_delay3 <= 'b0;
        parallel_in_quarter_delay3 <= 'b0;
        changed_quarter_delay3 <= 'b0;
        changed_quarter_quad_delay3 <= 'b0;
    end else begin
        last_state_delay3 <= last_state_delay2;
        change_flg_delay3 <= change_flg_delay2;
        parallel_in_quarter_delay3 <= parallel_in_quarter_delay2;
        
        if (parallel_in_quarter_delay2[3] != last_state_delay2)
            changed_quarter_quad_delay3 <= 2'b00;
        else if (parallel_in_quarter_delay2[7] != last_state_delay2)
            changed_quarter_quad_delay3 <= 2'b01;
        else if (parallel_in_quarter_delay2[11] != last_state_delay2)
            changed_quarter_quad_delay3 <= 2'b10;
        else
            changed_quarter_quad_delay3 <= 2'b11;
        changed_quarter_delay3 <= changed_quarter_delay2;
    end
end

logic last_state_delay4;
logic change_flg_delay4;
logic [3:0] parallel_in_quarter_quad_delay4;
logic [1:0] changed_quarter_delay4;
logic [1:0] changed_quarter_quad_delay4;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        last_state_delay4 <= 'b0;
        change_flg_delay4 <= 'b0;
        parallel_in_quarter_quad_delay4 <= 'b0;
        changed_quarter_delay4 <= 'b0;
        changed_quarter_quad_delay4 <= 'b0;
    end else begin
        last_state_delay4 <= last_state_delay3;
        change_flg_delay4 <= change_flg_delay3;
        changed_quarter_delay4 <= changed_quarter_delay3;
        changed_quarter_quad_delay4 <= changed_quarter_quad_delay3;
        parallel_in_quarter_quad_delay4 <=
              (changed_quarter_quad_delay3 == 2'b00) ? parallel_in_quarter_delay3[3:0]
            : (changed_quarter_quad_delay3 == 2'b01) ? parallel_in_quarter_delay3[7:4]
            : (changed_quarter_quad_delay3 == 2'b10) ? parallel_in_quarter_delay3[11:8]
            :                                          parallel_in_quarter_delay3[15:12];
        
    end
end


logic change_flg_delay5;
logic [5:0] changed_bit_delay5;


`ALWAYS_OVS_ISERDES_DETECTOR_INTERMEDIATE_STAGE begin
    if (RESET) begin
        changed_bit_delay5 <= 'b0;
        change_flg_delay5 <= 'b0;
    end else begin
        change_flg_delay5 <= change_flg_delay4;
        changed_bit_delay5[5:4] <= changed_quarter_delay4;  
        changed_bit_delay5[3:2] <= changed_quarter_quad_delay4;  
        changed_bit_delay5[1:0] <=  
                  (parallel_in_quarter_quad_delay4[0] != last_state_delay4) ? 2'b00
                : (parallel_in_quarter_quad_delay4[1] != last_state_delay4) ? 2'b01
                : (parallel_in_quarter_quad_delay4[2] != last_state_delay4) ? 2'b10
                :                                                             2'b11;      
    end
end

logic change_flg_delay6;
logic [5:0] changed_bit_delay6;

always_ff @(posedge CLK_PARALLEL) begin
    if (RESET) begin
        change_flg_delay6 <= 'b0;
        changed_bit_delay6 <= 'b0;
    end else begin
        change_flg_delay6 <= change_flg_delay5;
        changed_bit_delay6 <= change_flg_delay5 ? changed_bit_delay5 : 6'b0;      
    end
end

// 1 for one cycle if state is changed
always_comb CHANGED_FLAG <= change_flg_delay6;

// when CHANGED_FLAG==1, contains number of changed bit
always_comb CHANGED_BIT <= changed_bit_delay6;


endmodule
