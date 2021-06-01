`timescale 1ns / 1ps


module oscillator_ddr_tb();

localparam PERIOD_INT_PART = 10;
localparam PERIOD_FRAC_PART = 20;

// parallel data clock
logic CLK;
// serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
logic CLK_X4;
logic RESET;
logic CE;
// period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] PERIOD_IN;
// serial output
logic OUT;


oscillator_ddr
#(
    .PERIOD_INT_PART(PERIOD_INT_PART),
    .PERIOD_FRAC_PART(PERIOD_FRAC_PART)
)
oscillator_ddr_inst
(
    .*
);

always begin
    // 600MHz
    #0.84333 CLK_X4=0; 
    #0.84333 CLK_X4=1;  
    #0.84333 CLK_X4=0;  
    #0.84333 CLK_X4=1; CLK = 0;
    #0.84333 CLK_X4=0;  
    #0.84333 CLK_X4=1;  
    #0.84333 CLK_X4=0;  
    #0.84333 CLK_X4=1; CLK = 1;
end

initial begin
    // reset, active 1
   CE = 0;
    #33 RESET = 1;
    PERIOD_IN = 30'b0000000111_0101100000_00000000000;
    #150 @(posedge CLK) RESET = 0;
    #15 @(posedge CLK) CE = 1;
    
end



always begin
    PERIOD_IN = 30'b0000000111_0101100000_00000000000;
    repeat (175) @(posedge CLK);    
    PERIOD_IN = 30'b0000000101_1101111000_00111100000;
    repeat (175) @(posedge CLK);    
    PERIOD_IN = 30'b0000001011_0101111011_00111100000;
    repeat (175) @(posedge CLK);    
    PERIOD_IN = 30'b0000001010_1101111011_00111100000;
    repeat (175) @(posedge CLK);    
    PERIOD_IN = 30'b0000001010_0001111011_00111100000;
    repeat (175) @(posedge CLK);    
    #100 $finish();
end

endmodule
