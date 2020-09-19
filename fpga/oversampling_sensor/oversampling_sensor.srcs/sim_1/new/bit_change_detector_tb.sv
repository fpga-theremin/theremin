`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 12:54:19 PM
// Design Name: 
// Module Name: bit_change_detector_tb
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


module bit_change_detector_tb(

    );

localparam OVERSAMPLING = 6;
// 200MHz
logic CLK;
// reset, active 1, must be synchronous to CLK !!!
logic RESET;
// parallel oversampled deserialized input    
logic [(1 << OVERSAMPLING) - 1 : 0] PARALLEL_IN;
// 1 for one cycle if state is changed
logic CHANGE_FLAG;
// 1 if change is raising edge, 0 if falling edge
logic CHANGE_EDGE;
// when CHANGED_FLAG==1, contains number of changed bit
logic [OVERSAMPLING - 1 : 0] CHANGED_BIT;


bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    .OVERSAMPLING(OVERSAMPLING)
) 
bit_change_detector_inst_6
(
    // 150MHz
    .CLK,
    // reset, active 1, must be synchronous to CLK !!!
    .RESET,
    // parallel oversampled deserialized input    
    .PARALLEL_IN,
    // 1 for one cycle if state is changed
    .CHANGE_FLAG,
    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE,
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT
);


// parallel oversampled deserialized input    
logic [(1 << 5) - 1 : 0] PARALLEL_IN5;
// 1 for one cycle if state is changed
logic CHANGE_FLAG5;
// 1 if change is raising edge, 0 if falling edge
logic CHANGE_EDGE5;
// when CHANGED_FLAG==1, contains number of changed bit
logic [5 - 1 : 0] CHANGED_BIT5;


bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    .OVERSAMPLING(5)
) 
bit_change_detector_inst_5
(
    // 150MHz
    .CLK,
    // reset, active 1, must be synchronous to CLK !!!
    .RESET,
    // parallel oversampled deserialized input    
    .PARALLEL_IN(PARALLEL_IN5),
    // 1 for one cycle if state is changed
    .CHANGE_FLAG(CHANGE_FLAG5),
    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(CHANGE_EDGE5),
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT(CHANGED_BIT5)
);



// parallel oversampled deserialized input    
logic [(1 << 4) - 1 : 0] PARALLEL_IN4;
// 1 for one cycle if state is changed
logic CHANGE_FLAG4;
// 1 if change is raising edge, 0 if falling edge
logic CHANGE_EDGE4;
// when CHANGED_FLAG==1, contains number of changed bit
logic [4 - 1 : 0] CHANGED_BIT4;


bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    .OVERSAMPLING(4)
) 
bit_change_detector_inst_4
(
    // 150MHz
    .CLK,
    // reset, active 1, must be synchronous to CLK !!!
    .RESET,
    // parallel oversampled deserialized input    
    .PARALLEL_IN(PARALLEL_IN4),
    // 1 for one cycle if state is changed
    .CHANGE_FLAG(CHANGE_FLAG4),
    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(CHANGE_EDGE4),
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT(CHANGED_BIT4)
);


// parallel oversampled deserialized input    
logic [(1 << 3) - 1 : 0] PARALLEL_IN3;
// 1 for one cycle if state is changed
logic CHANGE_FLAG3;
// 1 if change is raising edge, 0 if falling edge
logic CHANGE_EDGE3;
// when CHANGED_FLAG==1, contains number of changed bit
logic [3 - 1 : 0] CHANGED_BIT3;


bit_change_detector
#(
    // number of input bits is 1 << OVERSAMPLING
    .OVERSAMPLING(3)
) 
bit_change_detector_inst_3
(
    // 150MHz
    .CLK,
    // reset, active 1, must be synchronous to CLK !!!
    .RESET,
    // parallel oversampled deserialized input    
    .PARALLEL_IN(PARALLEL_IN3),
    // 1 for one cycle if state is changed
    .CHANGE_FLAG(CHANGE_FLAG3),
    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(CHANGE_EDGE3),
    // when CHANGED_FLAG==1, contains number of changed bit
    .CHANGED_BIT(CHANGED_BIT3)
);


initial begin
    // 150MHz
    repeat (100000) begin
        #3.333333333333333 CLK = 0;
        #3.333333333333333 CLK = 1;
    end;
end

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value (%h != %h)", signal, value); \
            $finish; \
        end

int i;
initial begin
    #1 PARALLEL_IN = 0;
    #1 PARALLEL_IN3 = 0;
    #1 PARALLEL_IN4 = 0;
    #1 PARALLEL_IN5 = 0;
    #33 RESET = 1;
    #120 RESET = 0;
    #40 $display("*** Testing x64 oversampling");
    for (i = 0; i < 64; i++) begin
        $display("x64 oversampling posedge bit %d", i);
        #50 @(posedge CLK) #3 PARALLEL_IN = {64{1'b1}} << i; `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN = {64{1'b1}} << 0; `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b1 ); `assert( CHANGE_EDGE, 1'b1 ); `assert( CHANGED_BIT, i );
        $display("x64 oversampling negedge bit %d", i);
        #33 @(posedge CLK) #3 PARALLEL_IN = {64{1'b1}} >> (64-i); `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN = {64{1'b0}} >> 0; `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b1 ); `assert( CHANGE_EDGE, 1'b0 ); `assert( CHANGED_BIT, i );
    end
    #40 $display("*** Testing x32 oversampling");
    for (i = 0; i < 32; i++) begin
        $display("x32 oversampling posedge bit %d", i);
        #50 @(posedge CLK) #3 PARALLEL_IN5 = {32{1'b1}} << i; `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN5 = {32{1'b1}} << 0; `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG5, 1'b1 ); `assert( CHANGE_EDGE5, 1'b1 ); `assert( CHANGED_BIT5, i );
        $display("x32 oversampling negedge bit %d", i);
        #33 @(posedge CLK) #3 PARALLEL_IN5 = {32{1'b1}} >> (32-i); `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN5 = {32{1'b0}} >> 0; `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG5, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG5, 1'b1 ); `assert( CHANGE_EDGE5, 1'b0 ); `assert( CHANGED_BIT5, i );
    end
    #40 $display("*** Testing x16 oversampling");
    for (i = 0; i < 16; i++) begin
        $display("x16 oversampling posedge bit %d", i);
        #50 @(posedge CLK) #3 PARALLEL_IN4 = {16{1'b1}} << i; `assert( CHANGE_FLAG4, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN4 = {16{1'b1}} << 0; `assert( CHANGE_FLAG4, 1'b0 );
        //@(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG4, 1'b1 ); `assert( CHANGE_EDGE4, 1'b1 ); `assert( CHANGED_BIT4, i );
        $display("x16 oversampling negedge bit %d", i);
        #33 @(posedge CLK) #3 PARALLEL_IN4 = {16{1'b1}} >> (16-i); `assert( CHANGE_FLAG4, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN4 = {16{1'b0}} >> 0; `assert( CHANGE_FLAG4, 1'b0 );
        //@(posedge CLK) #3 `assert( CHANGE_FLAG3, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG4, 1'b1 ); `assert( CHANGE_EDGE4, 1'b0 ); `assert( CHANGED_BIT4, i );
    end
    #40 $display("*** Testing x8 oversampling");
    for (i = 0; i < 8; i++) begin
        $display("x8 oversampling posedge bit %d", i);
        #50 @(posedge CLK) #3 PARALLEL_IN3 = {8{1'b1}} << i; `assert( CHANGE_FLAG3, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN3 = {8{1'b1}} << 0; `assert( CHANGE_FLAG3, 1'b0 );
        //@(posedge CLK) #3 `assert( CHANGE_FLAG, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG3, 1'b1 ); `assert( CHANGE_EDGE3, 1'b1 ); `assert( CHANGED_BIT3, i );
        $display("x8 oversampling negedge bit %d", i);
        #33 @(posedge CLK) #3 PARALLEL_IN3 = {8{1'b1}} >> (8-i); `assert( CHANGE_FLAG3, 1'b0 );
        @(posedge CLK) #3 PARALLEL_IN3 = {8{1'b0}} >> 0; `assert( CHANGE_FLAG3, 1'b0 );
        //@(posedge CLK) #3 `assert( CHANGE_FLAG3, 1'b0 );
        @(posedge CLK) #3 `assert( CHANGE_FLAG3, 1'b1 ); `assert( CHANGE_EDGE3, 1'b0 ); `assert( CHANGED_BIT3, i );
    end
    #40 $display("*** Done");
    #40 $finish;
end

endmodule
