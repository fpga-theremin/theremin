`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    iserdes_ddr is a wrapper around ISERDESE2 Xilinx primitive - samples input signal at CLK*8 rate, returns 8 deserialized bits each CLK cycle (150MHz).
    
    Resources: 1 ISERDESE2
*/


module iserdes_ddr (
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    input logic CLK_X4B,
    input logic RESET,
    input logic CE,
    // serial input
    input logic IN,
    // parallel output
    output logic [7:0] OUT
);



   // ISERDESE2: Input SERial/DESerializer with Bitslip
   //            Artix-7
   // Xilinx HDL Language Template, version 2019.1

   ISERDESE2 #(
      .DATA_RATE("DDR"),           // DDR, SDR
      .DATA_WIDTH(8),              // Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
      // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY("NONE"),           // NONE, BOTH, IBUF, IFD
      .NUM_CE(1),                  // Number of clock enables (1,2)
      .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
      .SERDES_MODE("MASTER"),      // MASTER, SLAVE
      // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0)
   )
   ISERDESE2_inst (
      .O(),                       // 1-bit output: Combinatorial output
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1(OUT[7]),
      .Q2(OUT[6]),
      .Q3(OUT[5]),
      .Q4(OUT[4]),
      .Q5(OUT[3]),
      .Q6(OUT[2]),
      .Q7(OUT[1]),
      .Q8(OUT[0]),
      // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(1'b0),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                   // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                   // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                   // position every time Bitslip is invoked (DDR operation is different from
                                   // SDR).

      // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE1(CE),
      .CE2(0),
      .CLKDIVP(1'b0),           // 1-bit input: TBD
      // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK(CLK_X4),                   // 1-bit input: High-speed clock
      .CLKB(CLK_X4B),                 // 1-bit input: High-speed secondary clock
      .CLKDIV(CLK),             // 1-bit input: Divided clock
      .OCLK(1'b0),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
      // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL('b0), // 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL('b0),       // 1-bit input: Dynamic CLK/CLKB inversion
      // Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D(IN),                       // 1-bit input: Data input
      .DDLY('b0),                 // 1-bit input: Serial data from IDELAYE2
      .OFB(),                   // 1-bit input: Data feedback from OSERDESE2
      .OCLKB(1'b0),               // 1-bit input: High speed negative edge output clock
      .RST(RESET),                   // 1-bit input: Active high asynchronous reset
      // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1('b0),
      .SHIFTIN2('b0)
   );

   // End of ISERDESE2_inst instantiation

endmodule
