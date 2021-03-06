`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
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
    parameter DELAY_VALUE=0
)
(
    // 600MHz
    input CLK_SHIFT,
    // 600MHz phase inverted CLK_SHIFT 
    input CLK_SHIFTB,
    // 150MHz must be phase aligned CLK_SHIFT/4 
    input CLK_PARALLEL,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    input logic CE,

    // serial input
    input IN,
    // parallel output
    output logic [7:0] OUT
);

wire d;
wire ddly;

generate
    if (DELAY_VALUE > 0) begin
        assign d = 'b0;
        //assign ddly = IN;
        (* IODELAY_GROUP="GROUP_FQM" *)
        IDELAYE2 #(
            .IDELAY_TYPE("FIXED"),
            .DELAY_SRC("DATAIN"),
            .IDELAY_VALUE(2 + DELAY_VALUE),
            .HIGH_PERFORMANCE_MODE("TRUE"),
            .SIGNAL_PATTERN("CLOCK"),
            .REFCLK_FREQUENCY(196.615),
            .CINVCTRL_SEL("FALSE"),
            .PIPE_SEL("FALSE")
        ) ch1_delay_instance (
            .C(),
            //.REGRST(0),
            .LD(1'b0),
            //.CE(CE),
            //.INC(0),
            .CINVCTRL(1'b0),
            .CNTVALUEIN('b0),
            //.IDATAIN(freq1_buf),
            .IDATAIN(),
            //.DATAIN(0),
            .DATAIN(IN),
            .LDPIPEEN(1'b0),
            .DATAOUT(ddly)
        );

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
    .IOBDELAY(DELAY_VALUE > 0 ? "BOTH" : "NONE")
) iserdes_inst (
    .RST(RESET), // RESET
    .CE1(CE), // ce
    .CE2(1'b0), // ce
    .CLK(CLK_SHIFT),
    .OCLK(1'b0), //'b0
    .CLKB(CLK_SHIFTB),
    .OCLKB(1'b0), // 'b0
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
    .CLKDIVP('b0), //'b0
    .BITSLIP('b0),
    .SHIFTIN1('b0),
    .SHIFTIN2('b0)
);


endmodule
