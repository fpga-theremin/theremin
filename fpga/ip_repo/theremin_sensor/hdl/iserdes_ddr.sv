`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2019 11:08:18 AM
// Design Name: 
// Module Name: iserdes_ddr
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


module iserdes_ddr
#(
    parameter DELAY_INPUT=0
)
(
    // 800MHz
    input CLK_SHIFT,
    input CLK_SHIFTB,
    // 200MHz
    input CLK_PARALLEL,
    // reset, active 1
    input RESET,
    // serial input
    input IN,
    // parallel output
    output logic [7:0] OUT
);

wire d;
wire ddly;

generate
    if (DELAY_INPUT == 1) begin
        assign d = 'b0;
        assign ddly = IN;
    end else begin
        assign d = IN;
        assign ddly = 'b0;
    end
endgenerate

// SERDES in SDR mode: reduce frequency by 4 times
ISERDESE2 #(
    .DATA_RATE("DDR"),
    .DATA_WIDTH(8),
    .INTERFACE_TYPE("NETWORKING"),
    .NUM_CE(1),
    .IOBDELAY(DELAY_INPUT ? "BOTH" : "NONE")
) iserdes_inst (
    .RST(RESET),
    .CE1(1'b1), // ce
    .CLK(CLK_SHIFT),
    .OCLK('b0),
    .CLKB(CLK_SHIFTB),
    .OCLKB('b0),
    .D(d),
    .DDLY(ddly),
    .Q1(OUT[7]),
    .Q2(OUT[6]),
    .Q3(OUT[5]),
    .Q4(OUT[4]),
    .Q5(OUT[3]),
    .Q6(OUT[2]),
    .Q7(OUT[1]),
    .Q8(OUT[0]),
    .CLKDIV(CLK_PARALLEL),
    .CLKDIVP('b0),
    .BITSLIP('b0),
    .SHIFTIN1('b0),
    .SHIFTIN2('b0)
);


endmodule
