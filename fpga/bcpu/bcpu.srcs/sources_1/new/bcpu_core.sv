`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2020 12:02:05 PM
// Design Name: 
// Module Name: bcpu_core
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

module bcpu_core
#(
    // data width
    parameter DATA_WIDTH = 16,
    // instruction width
    parameter INSTR_WIDTH = 18,
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    parameter PC_WIDTH = 10,
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    parameter ADDR_WIDTH = 10,

    // register file address width, 3 + 2 == 8 registers * 4 threads
    parameter REG_ADDR_WIDTH = 5,  // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5
    
    // bus address width
    parameter BUS_ADDR_WIDTH = 4,
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    parameter BUS_OP_WIDTH = 3,
    // size of input bus, in bits, addressable by DATA_WIDTH words
    parameter IBUS_BITS = 16,
    // size of output bus, in bits, addressable by DATA_WIDTH words
    parameter OBUS_BITS = 16,
    
    // when 1, two bits from offset are used for immediate mode to allow using constant table value instead of register
    //         Reduces offset range from 8 to 6 bits, but allows simple addressing of address (1<<n)+(0..63)   
    parameter USE_IMM_MODE_FOR_BASE_ADDRESS = 1,
    // when 1, offset for R_imm+offs (non-PC) address formats is signed (+31..-32 or +127..-128), when 0 - unsigned offset
    parameter USE_SIGNED_REG_BASE_OFFSET = 1,

    // specify init file to fill program ram with
    parameter LOCAL_RAM_INIT_FILE = ""
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // bus connections
    // input bus
    input logic [IBUS_BITS-1:0] IBUS,
    // output bus
    output logic [OBUS_BITS-1:0] OBUS
);


// 1 to enable ALU operation
logic alu_en;
// 1 if instruction is BUS operation
logic bus_en;
// 1 if instruction is LOAD operation
logic load_en;
// 1 if instruction is STORE operation
logic store_en;
// 1 if instruction is LOAD_OP, STORE_OP, or WAIT_OP
logic memory_en;
// 1 if instruction is JUMP, CALL or conditional jump operation
logic jmp_en;
// 1 if instruction is CALL operation and we need to save return address
logic call_en;



// ======================================================================
// memory OP signals

// memory or jump address calculated as base+offset
logic [ADDR_WIDTH-1:0] mem_addr;
// register A operand value: write data for STORE
logic [DATA_WIDTH-1:0] mem_write_data;
// value read from memory, 0 if not a LOAD operation 
logic [DATA_WIDTH-1:0] mem_read_data;
// address of instruction to read (always enabled when CE=1)
logic [PC_WIDTH-1:0] instr_read_addr;
// instruction read from memory, delayed by 2 clock cycles with CE=1 
logic [INSTR_WIDTH-1:0] instr_read_data;

bcpu_memory_op
#(
    // data width
    .DATA_WIDTH(DATA_WIDTH),
    // instruction width
    .INSTR_WIDTH(INSTR_WIDTH),
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    .PC_WIDTH(PC_WIDTH),
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    .ADDR_WIDTH(ADDR_WIDTH),
    // specify init file to fill program ram with
    .LOCAL_RAM_INIT_FILE(LOCAL_RAM_INIT_FILE)
)
bcpu_memory_op_inst
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,
    // 1 if instruction is LOAD operation
    .LOAD_EN(load_en),
    // 1 if instruction is STORE
    .STORE_EN(store_en),
    // memory or jump address calculated as base+offset
    .ADDR(mem_addr),
    // register A operand value: write data for STORE
    .WR_DATA(mem_write_data),
    // value read from memory, 0 if not a LOAD operation 
    .RD_VALUE_STAGE3(mem_read_data),
    // address of instruction to read (always enabled when CE=1)
    .INSTR_READ_ADDR(instr_read_addr),
    // instruction read from memory, delayed by 2 clock cycles with CE=1 
    .INSTR_READ_DATA(instr_read_data)
);

// current program counter (address of this instruction)
logic [PC_WIDTH-1:0] pc_stage0;
// id of current thread in barrel CPU
logic [1:0] thread_id_stage0;
// input flags {V, S, Z, C}
logic [3:0] flags_stage0;

// ALU operation code (valid if ALU_EN==1)
logic [3:0] alu_op;
logic [1:0] imm_mode;
// register A index, e.g. for ALU 
logic [2:0] a_index;
// register B or immediate index, e.g. for ALU 
logic [2:0] b_index;

// BUS operation code (valid if BUS_EN==1)
logic [BUS_OP_WIDTH-1:0] bus_op;
// BUS address (valid if BUS_EN==1)
logic [BUS_ADDR_WIDTH-1:0] bus_addr;

// register A operand value, e.g. for ALU operand A, write data for memory, or mask for WAIT
logic [DATA_WIDTH-1:0] a_value;
// register B or immediate operand value, e.g. for ALU operand B
logic [DATA_WIDTH-1:0] b_value;

// memory or jump address calculated as base+offset
logic [ADDR_WIDTH-1:0] addr_value;
// dest reg address, xx000 to disable writing
logic [REG_ADDR_WIDTH-1:0] dest_reg_addr;

//=========================================
// REGISTER FILE READ ACCESS
// connect to register file
//=========================================
// asynchronous read port A
// always exposes value from address RD_ADDR_A to RD_DATA_A
logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_A;
logic [DATA_WIDTH-1:0] RD_REG_DATA_A;
//=========================================
// asynchronous read port B 
// always exposes value from address RD_ADDR_B to RD_DATA_B
logic [REG_ADDR_WIDTH-1:0] RD_REG_ADDR_B;
logic [DATA_WIDTH-1:0] RD_REG_DATA_B;


bcpu_instr_decoder
#(
    // data width
    .DATA_WIDTH(DATA_WIDTH),
    // instruction width
    .INSTR_WIDTH(INSTR_WIDTH),
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    .PC_WIDTH(PC_WIDTH),
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    .ADDR_WIDTH(ADDR_WIDTH),

    // register file address width, 3 + 2 == 8 registers * 4 threads
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH),  // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5
    
    // bus address width
    .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    .BUS_OP_WIDTH(BUS_OP_WIDTH),
    
    // when 1, two bits from offset are used for immediate mode to allow using constant table value instead of register
    //         Reduces offset range from 8 to 6 bits, but allows simple addressing of address (1<<n)+(0..63)   
    .USE_IMM_MODE_FOR_BASE_ADDRESS(USE_IMM_MODE_FOR_BASE_ADDRESS),
    // when 1, offset for R_imm+offs (non-PC) address formats is signed (+31..-32 or +127..-128), when 0 - unsigned offset
    .USE_SIGNED_REG_BASE_OFFSET(USE_SIGNED_REG_BASE_OFFSET)
)
bcpu_instr_decoder_inst
(
    // INPUTS
    // instruction to decode
    .INSTR_IN(instr_read_data),
    // current program counter (address of this instruction)
    .PC_IN(pc_stage0),
    // id of current thread in barrel CPU
    .THREAD_ID(thread_id_stage0),
    // input flags {V, S, Z, C}
    .FLAGS_IN(flags_stage0),

    // ALU operation code (valid if ALU_EN==1)
    .ALU_OP(alu_op),
    
    .IMM_MODE(imm_mode),

    // register A index, e.g. for ALU 
    .A_INDEX(a_index),
    // register B or immediate index, e.g. for ALU 
    .B_INDEX(b_index),

    // BUS operation code (valid if BUS_EN==1)
    .BUS_OP(bus_op),
    // BUS address (valid if BUS_EN==1)
    .BUS_ADDR(bus_addr),

    // register A operand value, e.g. for ALU operand A, write data for memory, or mask for WAIT
    .A_VALUE(a_value),
    // register B or immediate operand value, e.g. for ALU operand B
    .B_VALUE(b_value),

    // 1 to enable ALU operation
    .ALU_EN(alu_en),
    // 1 if instruction is BUS operation
    .BUS_EN(bus_en),
    // 1 if instruction is LOAD operation
    .LOAD_EN(load_en),
    // 1 if instruction is STORE operation
    .STORE_EN(store_en),
    // 1 if instruction is LOAD_OP, STORE_OP, or WAIT_OP
    .MEMORY_EN(memory_en),
    // 1 if instruction is JUMP, CALL or conditional jump operation
    .JMP_EN(jmp_en),
    // 1 if instruction is CALL operation and we need to save return address
    .CALL_EN(call_en),

    // memory or jump address calculated as base+offset
    .ADDR_VALUE(addr_value),

    // dest reg address, xx000 to disable writing
    .DEST_REG_ADDR(dest_reg_addr),

    //=========================================
    // REGISTER FILE READ ACCESS
    // connect to register file
    //=========================================
    // asynchronous read port A
    // always exposes value from address RD_ADDR_A to RD_DATA_A
    .RD_REG_ADDR_A,
    .RD_REG_DATA_A,
    //=========================================
    // asynchronous read port B 
    // always exposes value from address RD_ADDR_B to RD_DATA_B
    .RD_REG_ADDR_B,
    .RD_REG_DATA_B
);

//=========================================
// Synchronous write port
// when WR_EN == 1, write value WR_DATA to address WR_ADDR on raising edge of CLK 
logic reg_wr_en_stage3;
logic [REG_ADDR_WIDTH-1:0] reg_wr_addr_stage3;
logic [DATA_WIDTH-1:0] reg_wr_data_stage3;

bcpu_regfile
#(
    .DATA_WIDTH(DATA_WIDTH),          // 16, 17, 18
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)   // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5 
)
bcpu_regfile_inst
(
    // input clock: write operation is done synchronously using this clock
    .CLK,
    //=========================================
    // Synchronous write port
    // when WR_EN == 1, write value WR_DATA to address WR_ADDR on raising edge of CLK 
    .REG_WR_EN(reg_wr_en_stage3),
    .WR_REG_ADDR(reg_wr_addr_stage3),
    .WR_REG_DATA(reg_wr_data_stage3),
    
    //=========================================
    // asynchronous read port A
    // always exposes value from address RD_ADDR_A to RD_DATA_A
    .RD_REG_ADDR_A,
    .RD_REG_DATA_A,

    //=========================================
    // asynchronous read port B 
    // always exposes value from address RD_ADDR_B to RD_DATA_B
    .RD_REG_ADDR_B,
    .RD_REG_DATA_B
);


// 1 if we are going to reexecute current instruction, don't increase instruction address
// can be done only at stage 2, because latency of instruction fetch from memory is 2 cycles
// wait cannot be initiated for 
logic wait_request_stage2;

// return address to store into register, for CALL operations only, should return 0 if not a call instruction
logic [PC_WIDTH-1:0] return_address_stage3;


bcpu_program_counter
#(
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    .PC_WIDTH(PC_WIDTH)
)
bcpu_program_counter_inst
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,

    // current program counter (address of this instruction)
    .PC_STAGE0(pc_stage0),
    // id of current thread in barrel CPU
    .THREAD_ID_STAGE0(thread_id_stage0),
    

    // Jump/Call controls from instruction decoder
    // jmp address (valid only if JMP_EN_STAGE0 == 1)
    .JMP_ADDRESS_STAGE0(addr_value[PC_WIDTH-1:0]),
    // 1 if need to jump to new address (JMP, CALL, or conditional JMP with TRUE condition) 
    .JMP_EN_STAGE0(jmp_en),
    // 1 if instruction is CALL operation and we need to know return address
    .CALL_EN_STAGE0(call_en),
    
    // 1 if we are going to reexecute current instruction, don't increase instruction address
    // can be done only at stage 2, because latency of instruction fetch from memory is 2 cycles
    // wait cannot be initiated for 
    .WAIT_REQUEST_STAGE2(wait_request_stage2),

    // ===============================================
    // program memory read request signals
    // 1 to initiate read operation
    .PROGRAM_MEM_RDEN(), 
    // address of instruction to read
    .PROGRAM_MEM_ADDR(instr_read_addr), 

    // return address to store into register, for CALL operations only, should return 0 if not a call instruction
    .RETURN_ADDRESS_STAGE3(return_address_stage3)
);


// read value, to store into register
logic [DATA_WIDTH-1:0] bus_read_value;
// 1 to write OUT_VALUE to register
//logic bus_save_value;
// Z flag value output
logic bus_zflag;
// 1 to replace ALU's Z flag with OUT_ZFLAG 
logic bus_save_zflag;


bcpu_bus_op
#(
    // data width
    .DATA_WIDTH(DATA_WIDTH),
    // bus address width
    .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    .BUS_OP_WIDTH(BUS_OP_WIDTH),
    // size of input bus, in bits, addressable by DATA_WIDTH words
    .IBUS_BITS(IBUS_BITS),
    // size of output bus, in bits, addressable by DATA_WIDTH words
    .OBUS_BITS(OBUS_BITS)
)
bcpu_bus_op_inst
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,

    // stage0 inputs
    // 1 if instruction is BUS operation
    .BUS_EN(bus_en),
    // bus operation code
    .BUS_OP(bus_op),
    // ibus or obus address
    .BUS_ADDR(bus_addr),
    
    // register A operand value
    .A_VALUE(a_value),
    // register B operand value or immediate constant
    .B_VALUE(b_value),

    // stage2 output
    // 1 to repeat current instruction, 0 to allow moving to next instruction
    .WAIT_REQUEST(wait_request_stage2),
    
    // stage3 outputs
    // read value, to store into register
    .OUT_VALUE(bus_read_value),
    // 1 to write OUT_VALUE to register
    //.SAVE_VALUE(bus_save_value),
    // Z flag value output
    .OUT_ZFLAG(bus_zflag),
    // 1 to replace ALU's Z flag with OUT_ZFLAG 
    .SAVE_ZFLAG(bus_save_zflag),

    // bus connections
    // input bus
    .IBUS,
    // output bus
    .OBUS
    
);



// output flags {V, S, Z, C}
logic [3:0] flags_stage3;
    
// alu result output    
logic [DATA_WIDTH-1 : 0] alu_out_value;

bcpu_alu
#(
    .DATA_WIDTH(DATA_WIDTH)
)
bcpu_alu_inst
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,
    // enable ALU (when disabled it should force output to 0 and flags should be kept unchanged)
    .EN(alu_en),


    // Operand A inputs:
    
    // when A_REG_INDEX==000 (RA is R0), use 0 instead of A_IN for operand A
    .A_REG_INDEX(a_index),
    // operand A input
    .A_IN(a_value),

    // Operand B inputs:
    
    // B_CONST_OR_REG_INDEX and B_IMM_MODE are needed to implement special cases for shifts and MOV
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    //.B_CONST_OR_REG_INDEX(b_index),
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    // when B_IMM_MODE == 00 and B_CONST_OR_REG_INDEX == 000, use 0 instead of B_IN as operand B value
    //.B_IMM_MODE(imm_mode),
    // operand B input
    .B_IN(b_value),

    // alu operation code    
    .ALU_OP(alu_op),
    
    // input flags {V, S, Z, C}
    .FLAGS_IN(flags_stage0),
    // 1 to override Z flags on stage2
    .FLAG_Z_OVERRIDE_STAGE2(bus_zflag),
    // Z flags value to use in case of override == 1
    .FLAG_Z_OVERRIDE_VALUE_STAGE2(bus_zflag),
    
    // input flags {V, S, Z, C}
    .FLAGS_OUT(flags_stage3),
    
    // alu result output    
    .ALU_OUT(alu_out_value)
);

//// input flags {V, S, Z, C}
//logic [3:0] new_flags_stage3;

//assign new_flags_stage3[FLAG_V] = flags_stage3[FLAG_V];
//assign new_flags_stage3[FLAG_S] = flags_stage3[FLAG_S];
//assign new_flags_stage3[FLAG_Z] = bus_save_zflag ? bus_zflag : flags_stage3[FLAG_Z];
//assign new_flags_stage3[FLAG_C] = flags_stage3[FLAG_C];

always_ff @(posedge CLK)
    if (RESET)
        flags_stage0 <= 'b0;
    else if (CE)
        flags_stage0 <= flags_stage3;

logic [REG_ADDR_WIDTH-1:0] dest_reg_addr_stage1;
logic [REG_ADDR_WIDTH-1:0] dest_reg_addr_stage2;
logic [REG_ADDR_WIDTH-1:0] dest_reg_addr_stage3;

always_ff @(posedge CLK)
    if (RESET) begin
        dest_reg_addr_stage3 <= 'b0;
        dest_reg_addr_stage2 <= 'b0;
        dest_reg_addr_stage1 <= 'b0;
    end else if (CE) begin
        dest_reg_addr_stage3 <= dest_reg_addr_stage2;
        dest_reg_addr_stage2 <= dest_reg_addr_stage1;
        dest_reg_addr_stage1 <= dest_reg_addr;
    end

assign reg_wr_en_stage3 = (dest_reg_addr_stage3[2:0] != 3'b000) & CE;
assign reg_wr_addr_stage3 = dest_reg_addr_stage3;
assign reg_wr_data_stage3 = 
            alu_out_value | bus_read_value | return_address_stage3 | mem_read_data;

/*
dest_reg_addr
logic reg_wr_en_stage3;
logic [REG_ADDR_WIDTH-1:0] reg_wr_addr_stage3;
logic [DATA_WIDTH-1:0] reg_wr_data_stage3;
// read value, to store into register
logic [DATA_WIDTH-1:0] bus_read_value;
// 1 to write OUT_VALUE to register
logic bus_save_value;
*/


endmodule
