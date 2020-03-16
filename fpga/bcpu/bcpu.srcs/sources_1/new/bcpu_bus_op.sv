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
    parameter IBUS_SIZE = 1,
    // size of output bus, in words
    parameter OBUS_SIZE = 1
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

localparam IBUS_ADDR_WIDTH = IBUS_SIZE <= 1 ? 0
                           : IBUS_SIZE <= 2 ? 1
                           : IBUS_SIZE <= 4 ? 2
                           : IBUS_SIZE <= 8 ? 3
                           :                  4;

localparam OBUS_ADDR_WIDTH = OBUS_SIZE <= 1 ? 0
                           : OBUS_SIZE <= 2 ? 1
                           : OBUS_SIZE <= 4 ? 2
                           : OBUS_SIZE <= 8 ? 3
                           :                  4;

localparam MAX_BUS_ADDR_WIDTH  = IBUS_ADDR_WIDTH > OBUS_ADDR_WIDTH ? IBUS_ADDR_WIDTH : OBUS_ADDR_WIDTH;

// registers to store values for input bus
logic [DATA_WIDTH-1:0] ibus_buf[IBUS_SIZE];
// registers to store values for output bus
logic [DATA_WIDTH-1:0] obus_buf[OBUS_SIZE];
// write enable per OBUS word
logic obus_buf_wren[OBUS_SIZE];


// bus read mux at stage1: both input and output
logic [DATA_WIDTH-1:0] bus_rd_mux;

// 1 when op should read value from IBUS, 0 for OBUS
logic is_obus_stage1;
// 1 when need to update OBUS
logic is_write_stage1;



generate
    if (MAX_BUS_ADDR_WIDTH > 0) begin
        genvar j;
        genvar i;
 
        // registers to store values for input bus
        logic [DATA_WIDTH-1:0] bus_unrolled[2 << MAX_BUS_ADDR_WIDTH];
        for (i = 0; i < (1<<MAX_BUS_ADDR_WIDTH); i++) begin
            assign bus_unrolled[i * 2]     = (i < IBUS_SIZE) ? ibus_buf[i] : 'b0;
            assign bus_unrolled[i * 2 + 1] = (i < OBUS_SIZE) ? obus_buf[i] : 'b0;
        end

        logic [MAX_BUS_ADDR_WIDTH-1:0] bus_addr_stage1;
        always_ff @(posedge CLK) begin
            if (RESET) begin
                bus_addr_stage1 <= 'b0;
            end else if (CE) begin
                bus_addr_stage1 <= BUS_ADDR[MAX_BUS_ADDR_WIDTH-1:0];
            end
        end
        always_comb bus_rd_mux <= bus_unrolled[{bus_addr_stage1, is_obus_stage1}];
        // write enable 
        for (j = 0; j < OBUS_SIZE; j++) begin
            always_comb obus_buf_wren[j] <= is_write_stage1 & (bus_addr_stage1 == j);
        end
    end else begin
        // simple mux: take either OBUS or IBUS single element
        //always_comb bus_rd_mux <= bus_unrolled[is_obus_stage1];
        always_comb bus_rd_mux <= is_obus_stage1 ? obus_buf[0] : ibus_buf[0];
        // write enable
        always_comb obus_buf_wren[0] <= is_write_stage1;
    end


endgenerate

// ==============================
// latch inputs for stage1

// register A operand value
logic [DATA_WIDTH-1:0] a_value_stage1;
// register B operand value or immediate constant
logic [DATA_WIDTH-1:0] b_value_stage1;
// bus operation code
logic [BUS_OP_WIDTH-1:0] bus_op_stage1;
// bus operation flag
logic bus_en_stage1;


assign OBUS = obus_buf;

// result of bus value update operation (masked read value or updated write value)
logic [DATA_WIDTH-1:0] new_value;

logic wait_request_stage1;
logic zflag_stage1;
logic save_zflag_stage1;
logic save_value_stage1;

always_comb wait_request_stage1 <= bus_en_stage1 & zflag_stage1 
            & (bus_op_stage1 == BUSOP_WAIT_IBUS || bus_op_stage1 == BUSOP_WAIT_OBUS);
always_comb zflag_stage1 <= ~(|new_value);
always_comb save_zflag_stage1 <= bus_en_stage1 & (bus_op_stage1[BUS_OP_WIDTH-1] == 1'b0);
always_comb save_value_stage1 <= bus_en_stage1 & (bus_op_stage1 != BUSOP_WRITE_OBUS);
always_comb is_obus_stage1 = (bus_op_stage1 != BUSOP_READ_IBUS) & (bus_op_stage1 != BUSOP_WAIT_IBUS);
always_comb is_write_stage1 = bus_op_stage1[BUS_OP_WIDTH-1] & bus_en_stage1 & CE;


always_ff @(posedge CLK) begin
    if (RESET) begin
        // bus opcode
        bus_op_stage1 <= 'b0;
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


// stage2 for OUT_VALUE - to be written to register
logic [DATA_WIDTH-1:0] out_value_stage2;

always_ff @(posedge CLK) begin
    if (RESET | ~save_value_stage1)
        out_value_stage2 <= 'b0;
    else if (CE) begin
        out_value_stage2 <= new_value;
    end
end

bcpu_bus_op_eval
#(
    // data width
    .DATA_WIDTH(DATA_WIDTH),
    // numbe of bits in bus opcode, higher bit is WR/~RD
    .BUS_OP_WIDTH(BUS_OP_WIDTH)
)
bcpu_bus_op_eval_inst
(
    // bus operation code
    .bus_op_stage1,
    .a_value_stage1,
    .b_value_stage1,
    .bus_rd_mux,
    .new_value
);


always_ff @(posedge CLK) begin
    if (RESET) begin
        // initialize output bus with zero on reset
        for (int i = 0; i < OBUS_SIZE; i++)
            obus_buf[i] <= 'b0;
    end else begin
        for (int i = 0; i < OBUS_SIZE; i++)
            if (obus_buf_wren[i])
                obus_buf[i] <= new_value;
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

        wait_request_stage2 <= wait_request_stage1;
        zflag_stage2 <= zflag_stage1;
        save_zflag_stage2 <= save_zflag_stage1;
        save_value_stage2 <= save_value_stage1;
        
    end
end

endmodule
