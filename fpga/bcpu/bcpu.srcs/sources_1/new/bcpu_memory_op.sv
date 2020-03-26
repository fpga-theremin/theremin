`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2020 02:50:16 PM
// Design Name: 
// Module Name: bcpu_memory_op
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     BCPU memory interface: Load and Store implementation, instruction fetch, shared memory support
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcpu_memory_op
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

    // 1 if instruction is LOAD or STORE operation (stage1)
    input logic MEM_EN,
    // 1 if instruction is STORE (stage1)
    input logic STORE_EN,

    // memory or jump address calculated as base+offset (stage1)
    input logic [ADDR_WIDTH-1:0] ADDR,

    // register A operand value: write data for STORE (stage1)
    input logic [DATA_WIDTH-1:0] WR_DATA,

    // value read from memory, 0 if not a LOAD operation 
    output logic [DATA_WIDTH-1:0] RD_VALUE_STAGE3,

    // address of instruction to read (always enabled when CE=1)
    input logic [PC_WIDTH-1:0] INSTR_READ_ADDR,
    // instruction read from memory, delayed by 2 clock cycles with CE=1 
    output logic [INSTR_WIDTH-1:0] INSTR_READ_DATA

);


logic [DATA_WIDTH-1:0] local_rd_value_stage3;
logic local_mem_op;
logic local_mem_store_op;

localparam HAS_EXT_MEM = (ADDR_WIDTH > PC_WIDTH) ? 1 : 0;
logic is_local_addr;
if (HAS_EXT_MEM == 1) begin
    always_comb is_local_addr <= ~ (&ADDR[ADDR_WIDTH-1 : INSTR_WIDTH]); // local == zeroes at higher bits
    always_comb local_mem_op <= MEM_EN & is_local_addr;
    always_comb local_mem_store_op <= STORE_EN & is_local_addr;
end else begin
    always_comb is_local_addr <= 1'b1;                                         // only local addresses
    always_comb local_mem_op <= MEM_EN;
    always_comb local_mem_store_op <= STORE_EN;
end


//// output value pipeline
//always_ff @(posedge CLK) begin
//    if (RESET || (CE & ~local_mem_load_op)) begin
//        RD_VALUE_STAGE3 <= 'b0;
//    end else if (CE) begin
//    end
//end
// TODO: add external memory support
assign RD_VALUE_STAGE3 = local_rd_value_stage3;

//====================================
// Port A    
// 1 to start port A read or write operation
logic PORT_A_EN;
// enable port A write
logic PORT_A_WREN;
// port A address 
logic [PC_WIDTH-1:0] PORT_A_ADDR;
// port A write data 
logic [INSTR_WIDTH-1:0] PORT_A_WRDATA; 
// port A read data 
logic [INSTR_WIDTH-1:0] PORT_A_RDDATA; 
//====================================
// Port B: for reading of instructions from local program memory    
// 1 to start port B read or write operation
logic PORT_B_EN;
// enable port B write
logic PORT_B_WREN;
// port B address 
logic [PC_WIDTH-1:0] PORT_B_ADDR; 
// port B write data 
logic [INSTR_WIDTH-1:0] PORT_B_WRDATA; 
// port B read data 
logic [INSTR_WIDTH-1:0] PORT_B_RDDATA;

// port A is for data read/write
assign PORT_A_EN = local_mem_op;
assign PORT_A_WREN = local_mem_store_op;
assign PORT_A_WRDATA = { {INSTR_WIDTH-DATA_WIDTH{1'b0}}, WR_DATA }; // padding with 0s
assign PORT_A_ADDR = ADDR;

// port B is for instruction read only
assign PORT_B_EN = 1'b1;
assign PORT_B_WREN = 1'b0;
assign PORT_B_WRDATA = {INSTR_WIDTH{1'b0}};

// address of instruction to read (always enabled when CE=1)
assign PORT_B_ADDR = INSTR_READ_ADDR;
// instruction read from memory, delayed by 2 clock cycles with CE=1 
assign INSTR_READ_DATA = PORT_B_RDDATA;

assign local_rd_value_stage3 = PORT_A_RDDATA[DATA_WIDTH-1:0];


bcpu_dualport_bram
#(
    // data width
    .DATA_WIDTH(INSTR_WIDTH),
    // address width
    .ADDR_WIDTH(PC_WIDTH),
    // 1 to enable output register on port A read data
    .USE_PORTA_REG(1),
    // 1 to enable output register on port B read data
    .USE_PORTB_REG(1),
    // specify init file to fill ram with
    .INIT_FILE(LOCAL_RAM_INIT_FILE)
)
localmem_bcpu_dualport_bram_ins
(
    // clock
    .CLK,
    // reset, active 1
    .RESET,
    // clock enable
    .CE,

    //====================================
    // Port A    
    // 1 to start port A read or write operation
    .PORT_A_EN, 
    // enable port A write
    .PORT_A_WREN,
    // port A address 
    .PORT_A_ADDR, 
    // port A write data 
    .PORT_A_WRDATA, 
    // port A read data 
    .PORT_A_RDDATA, 
    //====================================
    // Port B    
    // 1 to start port B read or write operation
    .PORT_B_EN, 
    // enable port B write
    .PORT_B_WREN,
    // port B address 
    .PORT_B_ADDR, 
    // port B write data 
    .PORT_B_WRDATA, 
    // port B read data 
    .PORT_B_RDDATA 
);


endmodule
