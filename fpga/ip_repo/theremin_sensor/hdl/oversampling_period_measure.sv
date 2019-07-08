`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 01:52:45 PM
// Design Name: 
// Module Name: oversampling_period_measure
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


module oversampling_period_measure
#(
    parameter COUNTER_BITS=12,
    // oversampling options: 0=no oversampling, 1=x2 oversampling, 2=x4 oversampling 3=x8 oversampling
    parameter OVERSAMPLING_BITS=3
)
(
    // 100MHz
    input logic CLK,
    // 800MHz
    input logic CLK_SHIFT,
    // 800MHz inverted
    input logic CLK_SHIFTB,
    // 200MHz
    input logic CLK_PARALLEL,
    // reset, active 1
    input logic RESET,
    // input frequency
    input logic FREQ_IN,
    
    output logic EDGE_FLAG,
    
    output logic [OVERSAMPLING_BITS + COUNTER_BITS-1:0] DURATION
    
);

localparam DELAY_CHANNEL_COUNT = (1<<OVERSAMPLING_BITS);
logic [DELAY_CHANNEL_COUNT-1:0] delay_out;

localparam DELAY_PER_CHANNEL = OVERSAMPLING_BITS == 1 ? 4
                             : OVERSAMPLING_BITS == 2 ? 2
                             : OVERSAMPLING_BITS == 3 ? 1
                             : 0;

logic channel_change_flag [DELAY_CHANNEL_COUNT];
logic [COUNTER_BITS-1:0] channel_period [DELAY_CHANNEL_COUNT];

logic [OVERSAMPLING_BITS + COUNTER_BITS-1:0] duration_adder; 
logic change_flag; 

generate
    genvar i;
    
    if (OVERSAMPLING_BITS==0) begin
    
        assign delay_out[0] = FREQ_IN;
    
    end else begin
    
        for (i = 0; i < DELAY_CHANNEL_COUNT; i++) begin
            (* IODELAY_GROUP="GROUP_FQM" *)
            IDELAYE2 #(
                .IDELAY_TYPE("FIXED"),
                .DELAY_SRC("DATAIN"),
                .IDELAY_VALUE(2 + DELAY_PER_CHANNEL*i),
                .HIGH_PERFORMANCE_MODE("TRUE"),
                .SIGNAL_PATTERN("CLOCK"),
                .REFCLK_FREQUENCY(200),
                .CINVCTRL_SEL("FALSE"),
                .PIPE_SEL("FALSE")
            ) ch1_delay1 (
                .C(CLK_PARALLEL),
                //.REGRST(0),
                .LD(1'b0),
                //.CE(CE),
                //.INC(0),
                .CINVCTRL(1'b0),
                .CNTVALUEIN('b0),
                //.IDATAIN(freq1_buf),
                .IDATAIN(),
                //.DATAIN(0),
                .DATAIN(FREQ_IN),
                .LDPIPEEN(1'b0),
                .DATAOUT(delay_out[i])
            );
        end

    end

    for (i = 0; i < DELAY_CHANNEL_COUNT; i++) begin
        iserdes_period_measure
        #(
            .COUNTER_BITS(COUNTER_BITS),
            .DELAY_INPUT(OVERSAMPLING_BITS == 0 ? 0 : 1)
        ) iserdes_period_measure_inst
        (
            // 100MHz
            .CLK,
            // 800MHz
            .CLK_SHIFT,
            // 800MHz inverted
            .CLK_SHIFTB,
            // 200MHz
            .CLK_PARALLEL,
            // reset, active 1
            .RESET,
            // input frequency
            .FREQ_IN(delay_out[i]),
            .EDGE_FLAG(channel_change_flag[i]),
            .DURATION(channel_period[i])
        );
    end

    if (OVERSAMPLING_BITS == 0) begin
        always_comb duration_adder <= channel_period[0];
        always_comb change_flag <= channel_change_flag[0];
    end else if (OVERSAMPLING_BITS == 1) begin
        always_comb duration_adder <= channel_period[0] + channel_period[1];
        always_comb change_flag <= channel_change_flag[0] | channel_change_flag[1];
    end else if (OVERSAMPLING_BITS == 2) begin
        always_comb duration_adder <= 
                (channel_period[0] + channel_period[1]) + (channel_period[2] + channel_period[3]);
        always_comb change_flag <= 
                channel_change_flag[0] | channel_change_flag[1] | channel_change_flag[2] | channel_change_flag[3];
    end else begin // OVERSAMPLING_BITS == 3
        always_comb duration_adder <= ((channel_period[0] + channel_period[1]) + (channel_period[2] + channel_period[3]))
            + ((channel_period[4] + channel_period[5]) + (channel_period[6] + channel_period[7]));
        always_comb change_flag <= 
                    channel_change_flag[0] | channel_change_flag[1] | channel_change_flag[2] | channel_change_flag[3] |
                    channel_change_flag[4] | channel_change_flag[5] | channel_change_flag[6] | channel_change_flag[7];
    end


endgenerate

logic change_flag_delay1;
logic change_flag_delay2;

always_ff @(posedge CLK)
    if (RESET) begin
        change_flag_delay1 <= 'b0;
        change_flag_delay2 <= 'b0;
    end else begin 
        change_flag_delay1 <= change_flag;
        change_flag_delay2 <= change_flag_delay1;
    end

logic edge_flag_reg;
logic [OVERSAMPLING_BITS + COUNTER_BITS-1:0] duration_reg;
 
always_ff @(posedge CLK) begin
    if (RESET) begin
        edge_flag_reg <= 'b0;
        duration_reg <= 'b0;
    end else begin
        if (~change_flag_delay2 & change_flag_delay1) begin
            edge_flag_reg <= 'b1;
            duration_reg <= duration_adder;
        end else begin
            edge_flag_reg <= 'b0;
        end
    end
end

always_comb EDGE_FLAG <= edge_flag_reg;
always_comb DURATION <= duration_reg;

endmodule
