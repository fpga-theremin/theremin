`timescale 1ns / 1ps


//`define OSCILLATOR_DDR_DEBUG

module iir_lowpass_pow2k_filter_unsigned_tb();


localparam INPUT_BITS = 30;
localparam RESULT_BITS = 30;
localparam FILTER_SHIFT_BITS = 5;
localparam FILTER_STAGES = 2;
localparam SIGNED_DATA = 0;

logic CLK;
logic RESET;
logic CE;
// input
logic [INPUT_BITS-1:0] IN_VALUE;
// output
logic [RESULT_BITS-1:0] OUT_VALUE;

iir_lowpass_pow2k_filter
#(
    .INPUT_BITS(INPUT_BITS),
    .RESULT_BITS(RESULT_BITS),
    .FILTER_SHIFT_BITS(FILTER_SHIFT_BITS),
    .FILTER_STAGES(FILTER_STAGES),
    .SIGNED_DATA(SIGNED_DATA)
)
iir_lowpass_pow2k_filter_inst
(
    .*
);

always begin
    // 600MHz
    #0.84333 ; 
    #0.84333 ;  
    #0.84333 ;  
    #0.84333 ; CLK = 0;
    #0.84333 ;  
    #0.84333 ;  
    #0.84333 ;  
    #0.84333 ; CLK = 1;
end

initial begin
    // reset, active 1
   CE = 0;
    #33 RESET = 1;
    //PERIOD_IN = 30'b0000000111_0101100000_0000000000;
    #150 @(posedge CLK) RESET = 0;
    #15 @(posedge CLK) CE = 1;
    
end

always @(posedge CLK) begin
    if (CE) begin
        #3 $display("%d \t %b \t : %d \t %b", IN_VALUE, IN_VALUE, OUT_VALUE, OUT_VALUE);
    end
end

always begin
    IN_VALUE = 100_000_000;
    @(posedge CE);
    IN_VALUE = 100_000_000;
    repeat (500) @(posedge CLK);    
    IN_VALUE =  50_000_000;
    repeat (500) @(posedge CLK);  
    IN_VALUE =  -1_000_000;
    repeat (500) @(posedge CLK);    
    IN_VALUE = 200_000_000;
    repeat (500) @(posedge CLK);    
    IN_VALUE = -100_000_000;
    repeat (500) @(posedge CLK);    
    IN_VALUE = -200_000_000;
    repeat (500) @(posedge CLK);    
    #100 $finish();
end

endmodule
