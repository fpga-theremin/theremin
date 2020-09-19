`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 06:05:30 PM
// Design Name: 
// Module Name: bcpu_bus_op_eval
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

import bcpu_defs::*;

module bcpu_bus_op_eval
#(
    // data width
    parameter DATA_WIDTH = 16,
    // numbe of bits in bus opcode, higher bit is WR/~RD
    parameter BUS_OP_WIDTH = 3
)
(
    // bus operation code
    input logic [BUS_OP_WIDTH-1:0] bus_op_stage1,
    input logic [DATA_WIDTH-1:0] a_value_stage1,
    input logic [DATA_WIDTH-1:0] b_value_stage1,
    input logic [DATA_WIDTH-1:0] bus_rd_mux,
    output logic [DATA_WIDTH-1:0] new_value
);

always_comb case (bus_op_stage1)
        // Rdest = (IBUS[addr] & mask),  update ZF
        BUSOP_READ_IBUS:   new_value <= b_value_stage1 & bus_rd_mux;
        // Rdest = (IBUS[addr] & mask),  update ZF, wait until ZF=0
        BUSOP_WAIT_IBUS:   new_value <= b_value_stage1 & bus_rd_mux;
        // Rdest = (OBUS[addr] & mask),  update ZF
        BUSOP_READ_OBUS:   new_value <= b_value_stage1 & bus_rd_mux;
        // Rdest = (OBUS[addr] & mask),  update ZF, wait until ZF=0
        BUSOP_WAIT_OBUS:   new_value <= b_value_stage1 & bus_rd_mux;
        // OBUS'[addr] =  OBUS[addr] ^ mask, Rdest = (OBUS[addr] & mask) -- read new value
        BUSOP_TOGGLE_OBUS: new_value <= bus_rd_mux ^ b_value_stage1;
        // OBUS'[addr] =  OBUS[addr] | mask, Rdest = (OBUS[addr] & mask) -- read new value
        BUSOP_SET_OBUS:    new_value <= bus_rd_mux | b_value_stage1;
        // OBUS'[addr] =  OBUS[addr] & ~mask, Rdest = (OBUS[addr] & mask) -- read new value
        BUSOP_RESET_OBUS:  new_value <= bus_rd_mux & ~b_value_stage1;
        // OBUS'[addr] = (OBUS[addr] & ~mask) | (value & mask)
        BUSOP_WRITE_OBUS:  new_value <= (bus_rd_mux & ~b_value_stage1) | (a_value_stage1 & b_value_stage1);
    endcase

endmodule
