`timescale 1ns / 1ps


//`define OSCILLATOR_DDR_DEBUG

module int_uint_divider_tb();

localparam OPERAND_BITS = 30;
localparam RESULT_BITS = 25;

logic CLK;
logic RESET;
logic CE;
// operand A
logic signed [OPERAND_BITS-1:0] A_IN;
// operand B
logic [OPERAND_BITS-1:0] B_IN;

logic IN_READY;
logic RESULT_READY;
// current filtered and limited period value
logic signed [RESULT_BITS-1:0] DIV_RESULT;

int_uint_divider
#(
    .OPERAND_BITS(OPERAND_BITS),
    .RESULT_BITS(RESULT_BITS)
)
int_uint_divider_inst
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

task test_divide( input logic signed [OPERAND_BITS-1:0] a, input logic [OPERAND_BITS-1:0] b );
    @(posedge IN_READY);
    A_IN = a;
    B_IN = b;
    repeat (2) @(posedge CLK);
    @(posedge RESULT_READY) #3 $display(" %d / %d = %d  %b  %f", a, b, DIV_RESULT, DIV_RESULT, (DIV_RESULT + 0.0) / (1<<(RESULT_BITS-1)));
endtask


always begin
    @(posedge CE);
    test_divide(10000, 123456);
    test_divide(10000, 1234567);
    test_divide(10000, 12345689);
    test_divide(1000, 10000);
    test_divide(1000, 5000);
    test_divide(1000, 3000);
    test_divide(1000, 1200);
    test_divide(-10000, 123456);
    test_divide(-10000, 1234567);
    test_divide(-10000, 12345689);
    test_divide(-1000, 12345);
    test_divide(-1000, 10000);
    test_divide(-1000, 5000);
    test_divide(-1000, 3000);
    test_divide(-1000, 1200);
    #100 $finish();
end

endmodule
