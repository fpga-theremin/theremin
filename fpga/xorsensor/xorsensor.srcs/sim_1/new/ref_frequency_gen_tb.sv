`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2020 11:18:56 AM
// Design Name: 
// Module Name: ref_frequency_gen_tb
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


module ref_frequency_gen_tb(

    );

// power of two of output size (3 for 8, 4 for 16, 5 for 32) 
localparam OVERSAMPLING = 5;
// oversampling bits
localparam OVERSAMPLING_BITS = (1<<OVERSAMPLING);
// base counter size - w/o oversampling bits, e.g. 8 for min frequency 600KHz with 150MHz bus and x8 oversampling 
localparam BASE_COUNTER_BITS = 8;
// full counter size, for 300KHz min frequency, should be 12 for OVERSAMPLING=3, 13 for OVERSAMPLING=4, 14 for OVERSAMPLING=5
localparam COUNTER_BITS = BASE_COUNTER_BITS + OVERSAMPLING;

// 150MHz 
logic CLK;
// reset, active 1, must be synchronous to CLK_SHIFT !!!
logic RESET;

// 1 to write new period value    
logic WR_PERIOD;
// reference frequency period value in CLK*OVERSAMPLING_BITS (1200MHz for CLK=150MHz and x8 oversampling) clock cycles
// min possible frequency with 12 bit counter: 300KHz
// period resolution near 1MHz: 
logic [COUNTER_BITS-1:0] PERIOD_VALUE;
// parallel output
logic [OVERSAMPLING_BITS-1:0] OUT;

logic debug_phase_index;
logic debug_phase_end;
logic [COUNTER_BITS-1:0] debug_counter;

ref_frequency_gen
#(
    .OVERSAMPLING(OVERSAMPLING),
    .OVERSAMPLING_BITS(OVERSAMPLING_BITS),
    .BASE_COUNTER_BITS(BASE_COUNTER_BITS),
    .COUNTER_BITS(COUNTER_BITS)  
) ref_frequency_gen_inst
(
    .*
);

initial begin
    // reset, active 1
    WR_PERIOD = 0;
    PERIOD_VALUE = 'd12345;
    #33 RESET = 1;
    #150 RESET = 0;
    #30
    @(posedge CLK) #1 PERIOD_VALUE = 'd129;
    @(posedge CLK) #1 WR_PERIOD = 1;
    @(posedge CLK) #1 WR_PERIOD = 0;
    #1000
    @(posedge CLK) #1 PERIOD_VALUE = 'd235;
    @(posedge CLK) #1 WR_PERIOD = 1;
    @(posedge CLK) #1 WR_PERIOD = 0;
    
end

always begin
    // 150MHz for CLK
    #3.3333333333333 CLK=0;
    #3.3333333333333 CLK=1;
end


endmodule
