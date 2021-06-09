`timescale 1ns / 1ps


//`define OSCILLATOR_DDR_DEBUG

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

`ifdef OSCILLATOR_DDR_DEBUG
logic signed [PERIOD_INT_PART+PERIOD_FRAC_PART:0] debug_phase;
`endif

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
    //PERIOD_IN = 30'b0000000111_0101100000_0000000000;
    #150 @(posedge CLK) RESET = 0;
    #15 @(posedge CLK) CE = 1;
    
end

real lastposedge = 0;
real lastnegedge = 0;
always @(posedge OUT) begin
`ifndef OSCILLATOR_DDR_DEBUG
    $display("/ %t \t  period %f \t  half %f", $realtime, $realtime - lastposedge, $realtime - lastnegedge);
`endif
    lastposedge = $time;
end

always @(negedge OUT) begin
`ifndef OSCILLATOR_DDR_DEBUG
    $display("\\ %t \t  period %f \t  half %f", $realtime, $realtime - lastnegedge, $realtime - lastposedge);
`endif
    lastnegedge = $time;
end

always @(posedge CLK) begin
`ifdef OSCILLATOR_DDR_DEBUG
    #3 $display("    phase %031b    %d     period=%b", debug_phase, debug_phase, PERIOD_IN);
`endif    
end

always begin    
    PERIOD_IN = 30'b0000001000_0000000000_0000000000;
    @(posedge CE);
    repeat (300) @(posedge CLK);    
    PERIOD_IN = 30'b0000001000_0001010010_0001001100;
    repeat (300) @(posedge CLK);    
    //#100 $finish();
    PERIOD_IN = 30'b0000000111_0000000000_0000000000;
    repeat (200) @(posedge CLK);    
    PERIOD_IN = 30'b0000000111_0101100000_0000000000;
    repeat (275) @(posedge CLK);    
    PERIOD_IN = 30'b0000000101_1101111000_0011110000;
    repeat (275) @(posedge CLK);    
    PERIOD_IN = 30'b0000001011_0101111011_0011110000;
    repeat (275) @(posedge CLK);    
    PERIOD_IN = 30'b0000001010_1101111011_0011110000;
    repeat (275) @(posedge CLK);    
    PERIOD_IN = 30'b0000001010_0001111011_0011110000;
    repeat (275) @(posedge CLK);    
    PERIOD_IN = 30'b0000000100_0000000000_0000000000;
    repeat (100) @(posedge CLK);    
    #100 $finish();
end

endmodule
