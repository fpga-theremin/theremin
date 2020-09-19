`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2020 09:24:30 AM
// Design Name: 
// Module Name: bcpu_regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//     Register file 32x16bit registers
//     Dual asynchronous read ports
//     One synchronous write port
//     Initialized to 0
//     On Xilinx Series 7, uses 24LUTs as distributed RAM
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcpu_regfile
#(
    parameter DATA_WIDTH = 16,     // 16, 17, 18
    parameter REG_ADDR_WIDTH = 5   // (1<<REG_ADDR_WIDTH) values: 64 values for addr width 6, 32 for 5 
)
(
    // input clock: write operation is done synchronously using this clock
    input logic CLK,
    
    //=========================================
    // Synchronous write port
    // when WR_EN == 1, write value WR_DATA to address WR_ADDR on raising edge of CLK 
    input logic REG_WR_EN,
    input logic [REG_ADDR_WIDTH-1:0] WR_REG_ADDR,
    input logic [DATA_WIDTH-1:0] WR_REG_DATA,
    
    //=========================================
    // asynchronous read port A
    // always exposes value from address RD_ADDR_A to RD_DATA_A
    input logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_A,
    output logic [DATA_WIDTH-1:0] RD_REG_DATA_A,

    //=========================================
    // asynchronous read port B 
    // always exposes value from address RD_ADDR_B to RD_DATA_B
    input logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_B,
    output logic [DATA_WIDTH-1:0] RD_REG_DATA_B
);

localparam MEMSIZE = 1 << REG_ADDR_WIDTH;
logic [DATA_WIDTH-1:0] memory[MEMSIZE] = { 
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
//                            0, 0, 0, 0, 0, 0, 0, 0, 
//                            0, 0, 0, 0, 0, 0, 0, 0,
//                            0, 0, 0, 0, 0, 0, 0, 0,
//                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0 
                        };

always_ff @(posedge CLK)
    if (REG_WR_EN)
        memory[WR_REG_ADDR] <= WR_REG_DATA;

always_comb RD_REG_DATA_A <= memory[RD_REG_ADDR_A];
always_comb RD_REG_DATA_B <= memory[RD_REG_ADDR_B];

endmodule
