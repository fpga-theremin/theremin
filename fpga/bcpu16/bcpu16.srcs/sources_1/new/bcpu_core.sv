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
    parameter PC_WIDTH = 11,
    // address width (limited by DATA_WIDTH, ADDR_WIDTH <= DATA_WIDTH)
    // when PC_WIDTH == ADDR_WIDTH, no shared mem extension of number of threads is supported
    // when PC_WIDTH < ADDR_WIDTH, higher address space can be used for shared mem of two 4-core CPUs
    //      and for higher level integration in multicore CPU
    parameter ADDR_WIDTH = 11,

    // number of bits in register index (number of registers is 1<<REG_INDEX_WIDT)
    parameter REG_INDEX_WIDTH = 3,

    // number of bits in ALU opcode
    parameter ALU_OP_WIDTH = 4,
    
    // bus address width
    parameter BUS_ADDR_WIDTH = 5,
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    parameter BUS_OP_WIDTH = 2,
    // size of input bus, in bits, addressable by DATA_WIDTH words
    parameter IBUS_BITS = 6,
    // size of output bus, in bits, addressable by DATA_WIDTH words
    parameter OBUS_BITS = 4,
    
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

logic [INSTR_WIDTH-1:0] instr_stage0;
logic [1:0] thread_id_stage0;
logic [1:0] thread_id_stage3;
logic [PC_WIDTH-1:0] pc_stage0;
logic [3:0] flags_stage0;
logic [3:0] flags_stage3;

// destination register index
logic [REG_INDEX_WIDTH-1:0] dst_reg_index_stage0;
logic [REG_INDEX_WIDTH-1:0] dst_reg_index_stage1;
logic [REG_INDEX_WIDTH-1:0] dst_reg_index_stage2;
logic [REG_INDEX_WIDTH-1:0] dst_reg_index_stage3;
// data source mux index for writing to register
logic [1:0] dst_reg_source_stage0;
logic [1:0] dst_reg_source_stage1;
logic [1:0] dst_reg_source_stage2;
logic [1:0] dst_reg_source_stage3;
// 1 to enable writing of operation result to destination register
logic dst_reg_wren_stage0;
logic dst_reg_wren_stage1;
logic dst_reg_wren_stage2;
logic dst_reg_wren_stage3;

// stage2 output
// 1 to repeat current instruction, 0 to allow moving to next instruction
logic bus_wait_request_stage2;

logic reg_wr_en;
logic [DATA_WIDTH-1:0] reg_wr_data;

logic [DATA_WIDTH-1:0] reg_rd_data_a;
logic [DATA_WIDTH-1:0] reg_rd_data_a_stage1;
always_ff @(posedge CLK) if (RESET) reg_rd_data_a_stage1 <= 'b0; else if (CE) reg_rd_data_a_stage1 <= reg_rd_data_a; 

//=========================================
// asynchronous read port B 
// always exposes value from address RD_ADDR_B to RD_DATA_B
logic [DATA_WIDTH-1:0] reg_rd_data_b;
logic [DATA_WIDTH-1:0] reg_rd_data_b_stage1;
always_ff @(posedge CLK) if (RESET) reg_rd_data_b_stage1 <= 'b0; else if (CE) reg_rd_data_b_stage1 <= reg_rd_data_b; 



logic [DATA_WIDTH-1:0] reg_b_or_const_stage0;
logic [DATA_WIDTH-1:0] reg_b_or_const_stage1;
always_ff @(posedge CLK) if (RESET) reg_b_or_const_stage1 <= 'b0; else if (CE) reg_b_or_const_stage1 <= reg_b_or_const_stage0; 

// decoded instruction outputs
// register A index : to register file
logic [REG_INDEX_WIDTH-1:0] a_index;
// register B or immediate index : to register file 
logic [REG_INDEX_WIDTH-1:0] b_index;

// calculated address value (for LOAD,STORE,CALL,JUMP)
logic [ADDR_WIDTH-1:0] addr_stage0;
logic [ADDR_WIDTH-1:0] addr_stage1;
always_ff @(posedge CLK) if (RESET) addr_stage1 <= 'b0; else if (CE) addr_stage1 <= addr_stage0; 

always_ff @(posedge CLK)
    if (RESET) begin
        dst_reg_index_stage1 <= 'b0;
        dst_reg_index_stage2 <= 'b0;
        dst_reg_index_stage3 <= 'b0;
        dst_reg_source_stage1 <= 'b0;
        dst_reg_source_stage2 <= 'b0;
        dst_reg_source_stage3 <= 'b0;
        dst_reg_wren_stage1 <= 'b0;
        dst_reg_wren_stage2 <= 'b0;
        dst_reg_wren_stage3 <= 'b0;
    end else if (CE) begin
        dst_reg_index_stage1 <= dst_reg_index_stage0;
        dst_reg_index_stage2 <= dst_reg_index_stage1;
        dst_reg_index_stage3 <= dst_reg_index_stage2;
        dst_reg_source_stage1 <= dst_reg_source_stage0;
        dst_reg_source_stage2 <= dst_reg_source_stage1;
        dst_reg_source_stage3 <= dst_reg_source_stage2;
        dst_reg_wren_stage1 <= dst_reg_wren_stage0;
        dst_reg_wren_stage2 <= dst_reg_wren_stage1;
        dst_reg_wren_stage3 <= dst_reg_wren_stage2 & ~bus_wait_request_stage2;
    end

// 1 for ALU op
logic alu_en;
// 1 for BUS read op
logic bus_rd_en;
logic bus_rd_en_stage1;
always_ff @(posedge CLK) if (RESET) bus_rd_en_stage1 <= 'b0; else if (CE) bus_rd_en_stage1 <= bus_rd_en; 
// 1 for BUS write op
logic bus_wr_en;
logic bus_wr_en_stage1;
always_ff @(posedge CLK) if (RESET) bus_wr_en_stage1 <= 'b0; else if (CE) bus_wr_en_stage1 <= bus_wr_en; 
// 1 for LOAD and STORE ops
logic mem_en;
logic mem_en_stage1;
always_ff @(posedge CLK) if (RESET) mem_en_stage1 <= 'b0; else if (CE) mem_en_stage1 <= mem_en; 
// 1 for STORE op
logic mem_write_en;
logic mem_write_en_stage1;
always_ff @(posedge CLK) if (RESET) mem_write_en_stage1 <= 'b0; else if (CE) mem_write_en_stage1 <= mem_write_en; 

// 1 for CALL and JMP with condition met
logic jmp_en;
logic jmp_en_stage1;
always_ff @(posedge CLK) if (RESET) jmp_en_stage1 <= 'b0; else if (CE) jmp_en_stage1 <= jmp_en; 

// ALU operation code (valid if ALU_EN==1)
logic [3:0] alu_op;

// bus operation
logic [BUS_OP_WIDTH-1:0] bus_op;
logic [BUS_OP_WIDTH-1:0] bus_op_stage1;
always_ff @(posedge CLK) if (RESET) bus_op_stage1 <= 'b0; else if (CE) bus_op_stage1 <= bus_op; 
// bus address
logic [BUS_ADDR_WIDTH-1:0] bus_addr;
logic [BUS_ADDR_WIDTH-1:0] bus_addr_stage1;
always_ff @(posedge CLK) if (RESET) bus_addr_stage1 <= 'b0; else if (CE) bus_addr_stage1 <= bus_addr; 

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
    .REG_INDEX_WIDTH(REG_INDEX_WIDTH),
    // number of bits in ALU opcode
    .ALU_OP_WIDTH(ALU_OP_WIDTH),
    // bus address width
    .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
    // number of bits in bus opcode, see bus_op_t in bcpu_defs
    .BUS_OP_WIDTH(BUS_OP_WIDTH)
)
bcpu_instr_decoder_instr
(
    // INPUTS
    // instruction to decode - from program memory
    .INSTR_IN(instr_stage0),
    // current program counter (address of this instruction)
    .PC_IN(pc_stage0),
    // input flags {V, S, Z, C}
    .FLAGS_IN(flags_stage0),

    // decoded instruction outputs
    // register A index : to register file
    .A_INDEX(a_index),
    // register B or immediate index : to register file 
    .B_INDEX(b_index),
    
    // register B value from register file -- for address and ALU operand calculations 
    .B_VALUE_IN(reg_rd_data_b),
    // register B or const for ALU and IOBUS ops
    .B_VALUE_OUT(reg_b_or_const_stage0),
    
    // calculated address value (for LOAD,STORE,CALL,JUMP)
    .ADDR_VALUE(addr_stage0),

    // destination register index
    .DST_REG_INDEX(dst_reg_index_stage0),
    // data source mux index for writing to register
    .DST_REG_SOURCE(dst_reg_source_stage0),
    // 1 to enable writing of operation result to destination register
    .DST_REG_WREN(dst_reg_wren_stage0),

    // 1 for ALU op
    .ALU_EN(alu_en),
    // 1 for BUS read op
    .BUS_RD_EN(bus_rd_en),
    // 1 for BUS write op
    .BUS_WR_EN(bus_wr_en),
    // 1 for LOAD and STORE ops
    .MEM_EN(mem_en),
    // 1 for STORE op
    .MEM_WRITE_EN(mem_write_en),
    // 1 for CALL and JMP with condition met
    .JMP_EN(jmp_en),

    // ALU operation code (valid if ALU_EN==1)
    .ALU_OP(alu_op),

    // bus operation
    .BUS_OP(bus_op),
    // bus address
    .BUS_ADDR(bus_addr)


);

// ===============================================
// program memory read request signals
// 1 to initiate read operation
logic program_mem_rden; 
// address of instruction to read
logic [PC_WIDTH-1:0] program_mem_addr; 


// return address to store into register, for CALL operations only, ignored otherwise
logic [PC_WIDTH-1:0] return_addr_stage3;

// value read from memory, 0 if not a LOAD operation 
logic [DATA_WIDTH-1:0] mem_read_value_stage3;


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
    // THREAD_ID_STAGE0 delayed by 3 cycles
    .THREAD_ID_STAGE3(thread_id_stage3),

    

    // Jump/Call controls from instruction decoder
    // jmp address (valid only if JMP_EN_STAGE0 == 1)
    .JMP_ADDRESS_STAGE1(addr_stage1),
    // 1 if need to jump to new address (JMP, CALL, or conditional JMP with TRUE condition) 
    .JMP_EN_STAGE1(jmp_en_stage1),
    
    // 1 if we are going to reexecute current instruction, don't increase instruction address
    // can be done only at stage 2, because latency of instruction fetch from memory is 2 cycles
    // wait cannot be initiated for 
    .WAIT_REQUEST_STAGE2(bus_wait_request_stage2),

    // ===============================================
    // program memory read request signals
    // 1 to initiate read operation
    .PROGRAM_MEM_RDEN(program_mem_rden), 
    // address of instruction to read
    .PROGRAM_MEM_ADDR(program_mem_addr), 

    
    // return address to store into register, for CALL operations only, ignored otherwise
    .RETURN_ADDRESS_STAGE3(return_addr_stage3)

);

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

    // 1 if instruction is LOAD or STORE operation (stage1)
    .MEM_EN(mem_en_stage1),
    // 1 if instruction is STORE (stage1)
    .STORE_EN(mem_write_en_stage1),

    // memory or jump address calculated as base+offset (stage1)
    .ADDR(addr_stage1),

    // register A operand value: write data for STORE (stage1)
    .WR_DATA(reg_rd_data_a_stage1),

    // value read from memory, 0 if not a LOAD operation 
    .RD_VALUE_STAGE3(mem_read_value_stage3),

    // address of instruction to read (always enabled when CE=1)
    .INSTR_READ_ADDR(program_mem_addr),
    // instruction read from memory, delayed by 2 clock cycles with CE=1 
    .INSTR_READ_DATA(instr_stage0)

);



// stage3 outputs
// read value, to store into register
logic [DATA_WIDTH-1:0] bus_rd_value_stage2;
logic [DATA_WIDTH-1:0] bus_rd_value_stage3;
always_ff @(posedge CLK) if (RESET) bus_rd_value_stage3 <= 'b0; else if (CE) bus_rd_value_stage3 <= bus_rd_value_stage2; 

// 1 to write OUT_VALUE to register
//output logic SAVE_VALUE,
// Z flag value output at stage2
logic bus_zflag_stage2;
logic bus_zflag_stage3;
always_ff @(posedge CLK) if (RESET) bus_zflag_stage3 <= 'b0; else if (CE) bus_zflag_stage3 <= bus_zflag_stage2; 
// 1 to replace ALU's Z flag with OUT_ZFLAG at stage2 
logic bus_save_zflag_stage2;
logic bus_save_zflag_stage3;
always_ff @(posedge CLK) if (RESET) bus_save_zflag_stage3 <= 'b0; else if (CE) bus_save_zflag_stage3 <= bus_save_zflag_stage2; 


bcpu_bus_op
#(
    // data width
    .DATA_WIDTH(DATA_WIDTH),
    // bus address width
    .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
    // number of bits in bus opcode, see bus_rd_op_t, bus_wr_op_t in bcpu_defs
    .BUS_OP_WIDTH(BUS_OP_WIDTH),
    // size of input bus, in bits, addressable by DATA_WIDTH words
    .IBUS_BITS(IBUS_BITS),
    // size of output bus, in bits, addressable by DATA_WIDTH words
    .OBUS_BITS(OBUS_BITS)
)
bcpu_bus_op_instr
(
    // input clock
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,

    // 1 if instruction is BUS READ operation (stage1)
    .BUS_RD_EN(bus_rd_en_stage1),
    // 1 if instruction is BUS WRITE operation (stage1)
    .BUS_WR_EN(bus_wr_en_stage1),
    // bus operation code (stage1)
    .BUS_OP(bus_op_stage1),
    // ibus or obus address (stage1)
    .BUS_ADDR(bus_addr_stage1),
    
    // register A operand value (stage1)
    .A_VALUE(reg_rd_data_a_stage1),
    // register B operand value or immediate constant (stage1)
    .B_VALUE(reg_b_or_const_stage1),

    // stage2 output
    // 1 to repeat current instruction, 0 to allow moving to next instruction
    .WAIT_REQUEST(bus_wait_request_stage2),
    
    // read value, to store into register
    .OUT_VALUE(bus_rd_value_stage2),
    
    // 1 to write OUT_VALUE to register
    //output logic SAVE_VALUE,
    // Z flag value output at stage2
    .OUT_ZFLAG(bus_zflag_stage2),
    // 1 to replace ALU's Z flag with OUT_ZFLAG at stage2 
    .SAVE_ZFLAG(bus_save_zflag_stage2),

    // bus connections
    // input bus
    .IBUS,
    // output bus
    .OBUS
    
);

// stage3 outputs
// read value, to store into register
logic [DATA_WIDTH-1:0] alu_rd_value_stage3;

bcpu_alu_dsp48e1
#(
    .DATA_WIDTH(DATA_WIDTH)
)
bcpu_alu_dsp48e1_inst
(
    // input clock, ~200..260MHz
    .CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    .CE,
    // reset signal, active 1
    .RESET,

    // enable ALU, (when 1, inputs contain new ALU operation, result will be available after 3 CLK cycles)
    .ALU_EN(alu_en),

    // operand A input
    .A_IN(reg_rd_data_a),

    // operand B input
    .B_IN(reg_b_or_const_stage0),

    // alu operation code, see aluop_t enum 
    .ALU_OP(alu_op),

    // input flags {V, S, Z, C}
    .FLAGS_IN(flags_stage0),
        
    // output flags {V, S, Z, C} - delayed by 3 clock cycles from inputs
    .FLAGS_OUT(flags_stage3),
    
    // alu result output         - delayed by 3 clock cycles from inputs
    .ALU_OUT(alu_rd_value_stage3)
);

bcpu_regfile
#(
    .DATA_WIDTH(DATA_WIDTH),          // 16, 17, 18
    .REG_ADDR_WIDTH(REG_INDEX_WIDTH + 2)   // (1<<REG_ADDR_WIDTH) values: 64 values for addr width 6, 32 for 5 
)
bcpu_regfile_inst
(
    // input clock: write operation is done synchronously using this clock
    .CLK,
    
    //=========================================
    // Synchronous write port
    // when WR_EN == 1, write value WR_DATA to address WR_ADDR on raising edge of CLK 
    .REG_WR_EN(reg_wr_en),
    .WR_REG_ADDR({thread_id_stage3, dst_reg_index_stage3}),
    .WR_REG_DATA(reg_wr_data),
    
    //=========================================
    // asynchronous read port A
    // always exposes value from address RD_ADDR_A to RD_DATA_A
    .RD_REG_ADDR_A({ thread_id_stage0, a_index }),
    .RD_REG_DATA_A(reg_rd_data_a),

    //=========================================
    // asynchronous read port B 
    // always exposes value from address RD_ADDR_B to RD_DATA_B
    .RD_REG_ADDR_B({ thread_id_stage0, b_index }),
    .RD_REG_DATA_B(reg_rd_data_b)
);

always_ff @(posedge CLK)
    if (RESET)
        flags_stage0 <= 'b0;
    else if (CE)
        flags_stage0 <= {
            flags_stage3[FLAG_V],
            flags_stage3[FLAG_S],
            bus_save_zflag_stage3 ? bus_zflag_stage3 : flags_stage3[FLAG_Z],
            flags_stage3[FLAG_C]
        };

always_comb reg_wr_en <= dst_reg_wren_stage3;
always_comb reg_wr_data <= (dst_reg_source_stage3 == REG_WRITE_FROM_ALU) ? alu_rd_value_stage3
                         : (dst_reg_source_stage3 == REG_WRITE_FROM_BUS) ? bus_rd_value_stage3
                         : (dst_reg_source_stage3 == REG_WRITE_FROM_MEM) ? mem_read_value_stage3
                         :                                                 return_addr_stage3;

endmodule
