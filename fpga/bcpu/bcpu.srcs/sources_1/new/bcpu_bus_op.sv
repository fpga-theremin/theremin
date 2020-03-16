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
    parameter BUS_ADDR_WIDTH = 4,
    // numbe of bits in bus opcode, higher bit is WR/~RD
    parameter BUS_OP_WIDTH = 3,
    // size of input bus, in words
    parameter IBUS_SIZE = 2,
    // size of output bus, in words
    parameter OBUS_SIZE = 2
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // stage0 inputs
    // 1 if instruction is BUS operation
    input logic BUS_EN,
    // bus operation code
    input logic [BUS_OP_WIDTH-1:0] BUS_OP,
    // bus operation code
    input logic [BUS_ADDR_WIDTH-1:0] BUS_ADDR,
    
    // register A operand value
    input logic [DATA_WIDTH-1:0] A_VALUE,
    // register B operand value or immediate constant
    input logic [DATA_WIDTH-1:0] B_VALUE,

    // stage2 output
    // 1 to repeat current instruction, 0 to allow moving to next instruction
    output logic WAIT_REQUEST,
    
    // stage3 outputs
    // read value, to store into register
    output logic [DATA_WIDTH-1:0] OUT_VALUE,
    // 1 to write OUT_VALUE to register
    output logic SAVE_VALUE,
    // Z flag value output
    output logic OUT_ZFLAG,
    // 1 to replace ALU's Z flag with OUT_ZFLAG 
    output logic SAVE_ZFLAG,

    // bus connections
    // input bus
    input logic [DATA_WIDTH-1:0] IBUS[IBUS_SIZE],
    // output bus
    output logic [DATA_WIDTH-1:0] OBUS[OBUS_SIZE]
    
);

//localparam IBUS_ADDR_WIDTH = IBUS_SIZE <


// ==============================
// latch inputs for stage1

// register A operand value
logic [DATA_WIDTH-1:0] a_value_stage1;
// register B operand value or immediate constant
logic [DATA_WIDTH-1:0] b_value_stage1;
// bus operation code
logic [BUS_OP_WIDTH-1:0] bus_op_stage1;
// bus address
logic [BUS_ADDR_WIDTH-1:0] bus_addr_stage1;
// bus operation flag
logic bus_en_stage1;

// registers to store values for input bus
logic [DATA_WIDTH-1:0] ibus_buf[IBUS_SIZE];

// registers to store values for output bus
logic [DATA_WIDTH-1:0] obus_buf[OBUS_SIZE];

// 1 when op should read value from IBUS, 0 for OBUS
logic is_ibus;
always_comb is_ibus <= (bus_op_stage1 == BUSOP_READ_IBUS) | (bus_op_stage1 == BUSOP_WAIT_IBUS);

// 1 when need to update OBUS
logic is_write;
always_comb is_write <= bus_op_stage1[BUS_OP_WIDTH-1];

// write enable per OBUS word
logic obus_buf_wren[OBUS_SIZE];
generate 
    genvar i;
    for (i = 0; i < OBUS_SIZE; i++) begin
        always_comb obus_buf_wren[i] <= CE & is_write & (bus_addr_stage1 == i);
    end
endgenerate

assign OBUS = obus_buf;

always_ff @(posedge CLK) begin
    if (RESET) begin
        // bus opcode
        bus_op_stage1 <= 'b0;
        // bus address
        bus_addr_stage1 <= 'b0;
        // bus operation flag
        bus_en_stage1 <= 'b0;
        // register A operand value
        a_value_stage1 <= 'b0;
        // register B operand value or immediate constant
        b_value_stage1 <= 'b0;
        // initialize output bus with zero on reset
        for (int i = 0; i < OBUS_SIZE; i++)
            ibus_buf[i] <= 'b0;
    end else if (CE) begin
        // bus opcode
        bus_op_stage1 <= BUS_OP;
        // bus address
        bus_addr_stage1 <= BUS_ADDR;
        // bus operation flag
        bus_en_stage1 <= BUS_EN;
        // register A operand value
        a_value_stage1 <= A_VALUE;
        // register B operand value or immediate constant
        b_value_stage1 <= B_VALUE;
        // initialize output bus with zero on reset
        for (int i = 0; i < IBUS_SIZE; i++)
            ibus_buf[i] <= IBUS[i];
    end
end



// ibus read mux at stage1
logic [DATA_WIDTH-1:0] ibus_rd_mux;
// obus read mux at stage1
logic [DATA_WIDTH-1:0] obus_rd_mux;

always_comb ibus_rd_mux <= (bus_addr_stage1 < IBUS_SIZE) ? ibus_buf[bus_addr_stage1] : 'b0; 

always_comb obus_rd_mux <= (bus_addr_stage1 < OBUS_SIZE) ? obus_buf[bus_addr_stage1] : 'b0; 

// bus read mux at stage1: both input and output
logic [DATA_WIDTH-1:0] bus_rd_mux;
always_comb bus_rd_mux <= is_ibus ? ibus_rd_mux : obus_rd_mux; 

logic [DATA_WIDTH-1:0] rd_value_masked;
always_comb rd_value_masked <= bus_rd_mux & b_value_stage1;

// stage2 for OUT_VALUE - to be written to register
logic [DATA_WIDTH-1:0] out_value_stage2;

always_ff @(posedge CLK) begin
    if (RESET | (CE & ~bus_en_stage1))
        out_value_stage2 <= 'b0;
    else if (CE) begin
        out_value_stage2 <= rd_value_masked;
    end
end

function logic writeOp;
    input logic prevValue;
    input logic newValue;
    input logic mask;
    input logic[2:0] opcode;
    case (opcode[1:0])
        // BUSOP_TOGGLE_OBUS      = 3'b100,   OBUS'[addr] =  OBUS[addr] ^ mask, Rdest = (OBUS[addr] & mask) -- read previous value
        2'b00: writeOp = mask ? ~prevValue : prevValue;
        // BUSOP_SET_OBUS         = 3'b101,   OBUS'[addr] =  OBUS[addr] | mask, Rdest = (OBUS[addr] & mask) -- read previous value
        2'b01: writeOp = mask ? 1'b1       : prevValue;
        // BUSOP_RESET_OBUS       = 3'b110,   OBUS'[addr] =  OBUS[addr] & ~mask, Rdest = (OBUS[addr] & mask) -- read previous value
        2'b10: writeOp = mask ? 1'b0       : prevValue;
        // BUSOP_WRITE_OBUS       = 3'b111,   OBUS'[addr] = (OBUS[addr] & ~mask) | (value & mask)
        2'b11: writeOp = mask ? newValue   : prevValue;
    endcase
endfunction


always_ff @(posedge CLK) begin
    if (RESET) begin
        // initialize output bus with zero on reset
        for (int i = 0; i < OBUS_SIZE; i++)
            obus_buf[i] <= 'b0;
    end else begin
        for (int i = 0; i < OBUS_SIZE; i++)
            for (int j = 0; j < DATA_WIDTH; j++)
                if (obus_buf_wren[i])
                    obus_buf[i][j] <= writeOp(
                            obus_rd_mux[j],                  // prev value 
                            a_value_stage1[j],               // new value
                            b_value_stage1[j],               // mask
                            bus_op_stage1[1:0]               // write opcode
                        );
    end
end

logic zflag_stage2;
logic save_zflag_stage2;
logic save_value_stage2;
logic wait_request_stage2;

// stage3 for OUT_VALUE - to be written to register
logic [DATA_WIDTH-1:0] out_value_stage3;
assign OUT_VALUE = out_value_stage3;


logic zflag_stage3;
logic save_zflag_stage3;
logic save_value_stage3;

logic zflag;
always_comb zflag <= ~(|rd_value_masked);


assign OUT_ZFLAG = zflag_stage3;
assign SAVE_ZFLAG = save_zflag_stage3;
assign SAVE_VALUE = save_value_stage3;
assign WAIT_REQUEST = wait_request_stage2;

always_ff @(posedge CLK) begin
    if (RESET) begin
    
        zflag_stage3 <= 'b0;
        save_zflag_stage3 <= 'b0;
        save_value_stage3 <= 'b0;
        out_value_stage3 <= 'b0;
        
        zflag_stage2 <= 'b0;
        save_zflag_stage2 <= 'b0;
        save_value_stage2 <= 'b0;
        wait_request_stage2 <= 'b0;
        
    end else if (CE) begin
    
        zflag_stage3 <= zflag_stage2;
        save_zflag_stage3 <= save_zflag_stage2;
        save_value_stage3 <= save_value_stage2;
        out_value_stage3 <= out_value_stage2;

        wait_request_stage2 <= bus_en_stage1 & zflag & (bus_op_stage1 == BUSOP_WAIT_IBUS || bus_op_stage1 == BUSOP_WAIT_OBUS);
        zflag_stage2 <= zflag;
        save_zflag_stage2 <= bus_en_stage1 & (bus_op_stage1[BUS_OP_WIDTH-1] == 1'b0);
        save_value_stage2 <= bus_en_stage1 & (bus_op_stage1 != BUSOP_WRITE_OBUS);
        
    end
end

endmodule
