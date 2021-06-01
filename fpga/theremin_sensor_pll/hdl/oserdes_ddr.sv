`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    oserdes_ddr is a wrapper around OSERDESE2 Xilinx primitive - takes 8 parallel bits each CLK cycle (150MHz) and serializes them at CLK*8 rate.
    
    Resources: 1 OSERDESE2
*/

module oserdes_ddr(
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    input logic RESET,
    input logic CE,
    // parallel input
    input logic [7:0] IN,
    // serial output
    output logic OUT
);



   // OSERDESE2: Output SERial/DESerializer with bitslip
   //            Artix-7
   // Xilinx HDL Language Template, version 2019.1

   OSERDESE2 #(
      .DATA_RATE_OQ("DDR"),   // DDR, SDR
      .DATA_RATE_TQ("DDR"),   // DDR, BUF, SDR
      .DATA_WIDTH(8),         // Parallel data width (2-8,10,14)
      .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
      .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
      .SERDES_MODE("MASTER"), // MASTER, SLAVE
      .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
      .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
      .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
      .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
      .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
   )
   OSERDESE2_inst (
      .OFB(),             // 1-bit output: Feedback path for data
      .OQ(OUT),               // 1-bit output: Data path output
      // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .TBYTEOUT(),   // 1-bit output: Byte group tristate
      .TFB(),             // 1-bit output: 3-state control
      .TQ(),               // 1-bit output: 3-state control
      .CLK(CLK_X4),             // 1-bit input: High speed clock
      .CLKDIV(CLK),       // 1-bit input: Divided clock
      // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      .D1(IN[0]),
      .D2(IN[1]),
      .D3(IN[2]),
      .D4(IN[3]),
      .D5(IN[4]),
      .D6(IN[5]),
      .D7(IN[6]),
      .D8(IN[7]),
      .OCE(CE),             // 1-bit input: Output data clock enable
      .RST(RESET),             // 1-bit input: Reset
      // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      .SHIFTIN1(),
      .SHIFTIN2(),
      // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      .T1(),
      .T2(),
      .T3(),
      .T4(),
      .TBYTEIN(),     // 1-bit input: Byte group tristate
      .TCE()              // 1-bit input: 3-state clock enable
   );

   // End of OSERDESE2_inst instantiation


endmodule
