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
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    parameter BUS_OP_WIDTH = 3,
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

    // stage0 inputs
    // 1 if instruction is BUS operation (stage1)
    input logic BUS_EN,
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

localparam MAX_BUS_BITS = IBUS_BITS > OBUS_BITS ? IBUS_BITS : OBUS_BITS;
// if both IBUS and OBUS sizes less than DATA_WIDTH, use reduced INTERNAL_DATA_WIDTH to minimize resources
localparam INTERNAL_DATA_WIDTH = MAX_BUS_BITS > DATA_WIDTH ? DATA_WIDTH : MAX_BUS_BITS;

localparam IBUS_ADDR_WIDTH = IBUS_BITS <= 16  ? 0
                           : IBUS_BITS <= 32  ? 1
                           : IBUS_BITS <= 64  ? 2
                           : IBUS_BITS <= 128 ? 3
                           :                    4;

localparam OBUS_ADDR_WIDTH = OBUS_BITS <= 16  ? 0
                           : OBUS_BITS <= 32  ? 1
                           : OBUS_BITS <= 64  ? 2
                           : OBUS_BITS <= 128 ? 3
                           :                    4;

localparam MAX_BUS_ADDR_WIDTH  = IBUS_ADDR_WIDTH > OBUS_ADDR_WIDTH ? IBUS_ADDR_WIDTH : OBUS_ADDR_WIDTH;

logic [(MAX_BUS_ADDR_WIDTH > 0 ? MAX_BUS_ADDR_WIDTH-1 : 0):0] bus_addr_stage1;
always_comb bus_addr_stage1 <= MAX_BUS_ADDR_WIDTH > 0 ? BUS_ADDR[MAX_BUS_ADDR_WIDTH-1:0] : 'b0;


// slice of address truncated to IBUS size in words
logic [(IBUS_ADDR_WIDTH > 0 ? IBUS_ADDR_WIDTH-1 : 0) : 0] ibus_addr;
assign ibus_addr = IBUS_ADDR_WIDTH > 0 ? bus_addr_stage1[IBUS_ADDR_WIDTH-1:0] : 'b0;
// slice of address truncated to OBUS size in words
logic [(OBUS_ADDR_WIDTH > 0 ? OBUS_ADDR_WIDTH-1 : 0) : 0] obus_addr;
assign obus_addr = OBUS_ADDR_WIDTH > 0 ? bus_addr_stage1[OBUS_ADDR_WIDTH-1:0] : 'b0;

logic [IBUS_BITS-1:0] ibus_regs;
logic [OBUS_BITS-1:0] obus_regs;

assign OBUS = obus_regs;
always_ff @(posedge CLK)
    if (RESET)
        ibus_regs <= 'b0;
    else if (CE)
        ibus_regs <= IBUS;

// input bus register sliced into INTERNAL_DATA_WIDTH words, unused bits are set to 0
logic [INTERNAL_DATA_WIDTH-1:0] ibus_buf[1<<IBUS_ADDR_WIDTH];
// address mapping for easy reading if IBUS
always_comb
    for (int i = 0; i < (1<<IBUS_ADDR_WIDTH); i++)
        for (int j = 0; j < INTERNAL_DATA_WIDTH; j++) begin
            if ((i * INTERNAL_DATA_WIDTH + j) < IBUS_BITS)
                ibus_buf[i][j] <= ibus_regs[(i * INTERNAL_DATA_WIDTH + j)];
            else
                ibus_buf[i][j] <= 'b0;
        end

// output bus register sliced into INTERNAL_DATA_WIDTH words, unused bits are set to 0
logic [INTERNAL_DATA_WIDTH-1:0] obus_buf[1<<OBUS_ADDR_WIDTH];
// address mapping for easy reading if OBUS
always_comb
    for (int i = 0; i < (1<<OBUS_ADDR_WIDTH); i++)
        for (int j = 0; j < INTERNAL_DATA_WIDTH; j++) begin
            if ((i * INTERNAL_DATA_WIDTH + j) < OBUS_BITS)
                obus_buf[i][j] <= obus_regs[(i * INTERNAL_DATA_WIDTH + j)];
            else
                obus_buf[i][j] <= 'b0;
        end

// result of bus value update operation
// will be saved to register and/or to OBUS
logic [INTERNAL_DATA_WIDTH-1:0] new_value;
// 1 when op should read value from IBUS, 0 for OBUS
logic is_obus_stage1;
// 1 when need to update OBUS
logic is_write_stage1;

// OBUS write operation
always_ff @(posedge CLK)
    for (int i = 0; i < (1<<OBUS_ADDR_WIDTH); i++)
        for (int j = 0; j < INTERNAL_DATA_WIDTH; j++) begin
            if ((i * INTERNAL_DATA_WIDTH + j) < OBUS_BITS) begin
                if (RESET)
                    obus_regs[i * INTERNAL_DATA_WIDTH + j] <= 'b0;
                else if (is_write_stage1 && (obus_addr == i)) 
                    obus_regs[i * INTERNAL_DATA_WIDTH + j] <= new_value[j];
            end
        end

// bus read mux at stage1: both input and output
logic [INTERNAL_DATA_WIDTH-1:0] bus_rd_mux;

always_comb bus_rd_mux <= is_obus_stage1 ? obus_buf[obus_addr] : ibus_buf[ibus_addr];


// ==============================
// latch inputs for stage1

// register A operand value
logic [INTERNAL_DATA_WIDTH-1:0] a_value_stage1;
// register B operand value or immediate constant
logic [INTERNAL_DATA_WIDTH-1:0] b_value_stage1;
// bus operation code
logic [BUS_OP_WIDTH-1:0] bus_op_stage1;
// bus operation flag
logic bus_en_stage1;




logic wait_request_stage1;
logic zflag_stage1;
logic save_zflag_stage1;
logic save_value_stage1;

always_comb 
     case(bus_op_stage1)
     BUSOP_READ_IBUS:  //       = 3'b000, //  Rdest = (IBUS[addr] & mask),  update ZF
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= bus_en_stage1 & CE;
            save_value_stage1   <= bus_en_stage1 & CE;
            is_obus_stage1      <= 'b0;
            is_write_stage1     <= 'b0;
         end
     BUSOP_WAIT_IBUS:  //       = 3'b001, //  Rdest = (IBUS[addr] & mask),  update ZF, wait until ZF=0
         begin
            wait_request_stage1 <= bus_en_stage1 & zflag_stage1;
            save_zflag_stage1   <= bus_en_stage1 & CE;
            save_value_stage1   <= bus_en_stage1 & CE;
            is_obus_stage1      <= 'b0;
            is_write_stage1     <= 'b0;
         end
     BUSOP_READ_OBUS:  //       = 3'b010, //  Rdest = (OBUS[addr] & mask),  update ZF
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= bus_en_stage1 & CE;
            save_value_stage1   <= bus_en_stage1 & CE;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= 'b0;
         end
     BUSOP_WAIT_OBUS:  //       = 3'b011, //  Rdest = (OBUS[addr] & mask),  update ZF, wait until ZF=0
         begin
            wait_request_stage1 <= bus_en_stage1 & zflag_stage1;
            save_zflag_stage1   <= bus_en_stage1 & CE;
            save_value_stage1   <= bus_en_stage1 & CE;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= 'b0;
         end
     BUSOP_TOGGLE_OBUS://       = 3'b100, //  OBUS'[addr] =  OBUS[addr] ^ mask, Rdest = (OBUS[addr] & mask) -- read new value
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= 'b0;
            save_value_stage1   <= 'b0;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= bus_en_stage1 & CE;
         end
     BUSOP_SET_OBUS:   //       = 3'b101, //  OBUS'[addr] =  OBUS[addr] | mask, Rdest = (OBUS[addr] & mask) -- read new value
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= 'b0;
            save_value_stage1   <= 'b0;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= bus_en_stage1 & CE;
         end
     BUSOP_RESET_OBUS: //       = 3'b110, //  OBUS'[addr] =  OBUS[addr] & ~mask, Rdest = (OBUS[addr] & mask) -- read new value
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= 'b0;
            save_value_stage1   <= 'b0;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= bus_en_stage1 & CE;
         end
     BUSOP_WRITE_OBUS: //       = 3'b111  //  OBUS'[addr] = (OBUS[addr] & ~mask) | (value & mask)
         begin
            wait_request_stage1 <= 'b0;
            save_zflag_stage1   <= 'b0;
            save_value_stage1   <= 'b0;
            is_obus_stage1      <= 'b1;
            is_write_stage1     <= bus_en_stage1 & CE;
         end
     endcase

always_comb zflag_stage1 <= ~(|new_value);
assign bus_en_stage1 = BUS_EN;
assign bus_op_stage1 = BUS_OP;
assign a_value_stage1 = A_VALUE[INTERNAL_DATA_WIDTH-1:0];
assign b_value_stage1 = B_VALUE[INTERNAL_DATA_WIDTH-1:0];



// stage2 for OUT_VALUE - to be written to register
logic [INTERNAL_DATA_WIDTH-1:0] out_value_stage2;

always_ff @(posedge CLK) begin
    if (RESET)
        out_value_stage2 <= 'b0;
    else if (CE) begin
        out_value_stage2 <= new_value;
    end
end

bcpu_bus_op_eval
#(
    // data width
    .DATA_WIDTH(INTERNAL_DATA_WIDTH),
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


logic zflag_stage2;
logic save_zflag_stage2;
logic save_value_stage2;
logic wait_request_stage2;

// stage3 for OUT_VALUE - to be written to register
logic [INTERNAL_DATA_WIDTH-1:0] out_value_stage3;
assign OUT_VALUE = out_value_stage3;


logic zflag_stage3;



assign OUT_ZFLAG = zflag_stage2;
assign SAVE_ZFLAG = save_zflag_stage2;
//assign SAVE_VALUE = save_value_stage3;
assign WAIT_REQUEST = wait_request_stage2;

// output pipeline
always_ff @(posedge CLK) begin
    if (RESET) begin
    
        zflag_stage3 <= 'b0;
        out_value_stage3 <= 'b0;
        
        zflag_stage2 <= 'b0;
        save_zflag_stage2 <= 'b0;
        save_value_stage2 <= 'b0;
        wait_request_stage2 <= 'b0;
        
    end else if (CE) begin
    
        zflag_stage3 <= zflag_stage2;
        out_value_stage3 <= out_value_stage2;

        wait_request_stage2 <= wait_request_stage1;
        zflag_stage2 <= zflag_stage1;
        save_zflag_stage2 <= save_zflag_stage1;
        save_value_stage2 <= save_value_stage1;
        
    end
end

endmodule
