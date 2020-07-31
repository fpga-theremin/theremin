`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 09:47:57 AM
// Design Name: 
// Module Name: bcpu_bus_op
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

module bcpu_bus_op
#(
    // data width
    parameter DATA_WIDTH = 16,
    // bus address width
    parameter BUS_ADDR_WIDTH = 5,
    // number of bits in bus opcode, see bus_rd_op_t, bus_wr_op_t in bcpu_defs
    parameter BUS_OP_WIDTH = 2,
    // size of input bus, in bits, addressable by DATA_WIDTH words
    parameter IBUS_BITS = 4,
    // size of output bus, in bits, addressable by DATA_WIDTH words
    parameter OBUS_BITS = 4
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // 1 if instruction is BUS READ operation (stage1)
    input logic BUS_RD_EN,
    // 1 if instruction is BUS WRITE operation (stage1)
    input logic BUS_WR_EN,
    // bus operation code (stage1)
    input logic [BUS_OP_WIDTH-1:0] BUS_OP,
    // ibus or obus address (stage1)
    input logic [BUS_ADDR_WIDTH-1:0] BUS_ADDR,
    
    // register A operand value (stage1)
    input logic [DATA_WIDTH-1:0] A_VALUE,
    // register B operand value or immediate constant (stage1)
    input logic [DATA_WIDTH-1:0] B_VALUE,

    // stage2 output
    // 1 to repeat current instruction, 0 to allow moving to next instruction
    output logic WAIT_REQUEST,
    
    // stage3 outputs
    // read value, to store into register
    output logic [DATA_WIDTH-1:0] OUT_VALUE,
    
    // 1 to write OUT_VALUE to register
    //output logic SAVE_VALUE,
    // Z flag value output at stage2
    output logic OUT_ZFLAG,
    // 1 to replace ALU's Z flag with OUT_ZFLAG at stage2 
    output logic SAVE_ZFLAG,

    // bus connections
    // input bus
    input logic [IBUS_BITS-1:0] IBUS,
    // output bus
    output logic [OBUS_BITS-1:0] OBUS
    
);

logic [IBUS_BITS-1:0] ibus_buffered;
always_ff @(posedge CLK)
    if (RESET)
        ibus_buffered <= 'b0;
    else
        ibus_buffered <= IBUS;

localparam IBUS_ADDR_WIDTH = IBUS_BITS <= 16  ? 0
                           : IBUS_BITS <= 32  ? 1
                           : IBUS_BITS <= 64  ? 2
                           : IBUS_BITS <= 128 ? 3
                           : IBUS_BITS <= 256 ? 4
                           :                    5;

localparam IBUS_SLICE_COUNT = (1<<IBUS_ADDR_WIDTH);

// slice of address truncated to IBUS size in words
logic [(IBUS_ADDR_WIDTH > 0 ? IBUS_ADDR_WIDTH-1 : 0) : 0] ibus_addr;
always_comb ibus_addr <= (IBUS_ADDR_WIDTH > 0) ? BUS_ADDR[IBUS_ADDR_WIDTH-1:0] : 'b0;


logic [DATA_WIDTH-1 : 0] ibus_sliced[IBUS_SLICE_COUNT];

always_comb 
    for (int i = 0; i < IBUS_SLICE_COUNT; i++)
        for (int j = 0; j < DATA_WIDTH; j++)
            ibus_sliced[i][j] <= (i*DATA_WIDTH+j < IBUS_BITS) 
                ? ibus_buffered[i*DATA_WIDTH+j] 
                : 1'b0; 

logic [DATA_WIDTH-1 : 0] ibus_muxed;
always_comb ibus_muxed <= ibus_sliced[ibus_addr];

logic [DATA_WIDTH-1 : 0] ibus_masked;
always_comb ibus_masked <= ibus_muxed & B_VALUE;
logic ibus_masked_zero;
always_comb ibus_masked_zero <= ~(|ibus_masked);

logic wait_request = BUS_RD_EN && (
                         (BUS_OP == BUSOP_IBUSWAIT0 && ibus_masked_zero)
                        |(BUS_OP == BUSOP_IBUSWAIT1 && ~ibus_masked_zero) );

always_ff @(posedge CLK)
    if (RESET) begin
        OUT_VALUE <= 'b0;
        OUT_ZFLAG <= 'b0;
        WAIT_REQUEST <= 'b0;
        SAVE_ZFLAG <= 'b0;
    end else if (CE) begin
        OUT_VALUE <= ibus_masked;
        OUT_ZFLAG <= ibus_masked_zero;
        WAIT_REQUEST <= wait_request;
        SAVE_ZFLAG <= BUS_RD_EN & ~wait_request;
    end 



localparam OBUS_ADDR_WIDTH = OBUS_BITS <= 16  ? 0
                           : OBUS_BITS <= 32  ? 1
                           : OBUS_BITS <= 64  ? 2
                           : OBUS_BITS <= 128 ? 3
                           : OBUS_BITS <= 256 ? 4
                           :                    5;

localparam OBUS_SLICE_COUNT = (1<<OBUS_ADDR_WIDTH);

// slice of address truncated to IBUS size in words
logic [(OBUS_ADDR_WIDTH > 0 ? OBUS_ADDR_WIDTH-1 : 0) : 0] obus_addr;
always_comb obus_addr <= (OBUS_ADDR_WIDTH > 0) ? BUS_ADDR[OBUS_ADDR_WIDTH-1:0] : 'b0;

logic obus_slice_wren[OBUS_SLICE_COUNT];
always_comb
    if (OBUS_SLICE_COUNT == 1)
        obus_slice_wren[0] <= CE & BUS_WR_EN;
    else
        for (int i = 0; i < OBUS_SLICE_COUNT; i++)
            obus_slice_wren[i] <= CE && BUS_WR_EN && (i == obus_addr);

logic [OBUS_BITS-1 : 0] obus_reg;
always_comb OBUS <= obus_reg;

always_ff @(posedge CLK) begin
    for (int i = 0; i < OBUS_SLICE_COUNT; i++)
        for (int j = 0; j < DATA_WIDTH; j++)
            if (i * DATA_WIDTH + j < OBUS_BITS) begin
                if (RESET) begin
                    obus_reg[i * DATA_WIDTH + j] <= 'b0;
                end else if (obus_slice_wren[i]) begin
                    
                    obus_reg[i * DATA_WIDTH + j] <= B_VALUE[j] 
                            ? (
                                  (BUS_OP == BUSOP_OBUSWRITE) ? A_VALUE[j] 
                                : (BUS_OP == BUSOP_OBUSSET)   ? 1'b1 
                                : (BUS_OP == BUSOP_OBUSRESET) ? 1'b0 
                                :                               ~obus_reg[i * DATA_WIDTH + j] 
                              )
                            : obus_reg[i * DATA_WIDTH + j]
                            ;
                end
            end
end

endmodule
