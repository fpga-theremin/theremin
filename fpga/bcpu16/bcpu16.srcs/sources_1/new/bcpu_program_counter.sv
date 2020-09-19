`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2020 09:55:40 AM
// Design Name: 
// Module Name: bcpu_program_counter
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


module bcpu_program_counter
#(
    // program counter width (limits program memory size, PC_WIDTH <= ADDR_WIDTH)
    // PC_WIDTH should match local program/data BRAM size
    parameter PC_WIDTH = 10
)
(

    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,


    // current program counter (address of this instruction)
    output logic [PC_WIDTH-1:0] PC_STAGE0,
    // id of current thread in barrel CPU
    output logic [1:0] THREAD_ID_STAGE0,
    

    // Jump/Call controls from instruction decoder
    // jmp address (valid only if JMP_EN_STAGE0 == 1)
    input logic [PC_WIDTH-1:0] JMP_ADDRESS_STAGE1,
    // 1 if need to jump to new address (JMP, CALL, or conditional JMP with TRUE condition) 
    input logic JMP_EN_STAGE1,
    
    // 1 if we are going to reexecute current instruction, don't increase instruction address
    // can be done only at stage 2, because latency of instruction fetch from memory is 2 cycles
    // wait cannot be initiated for 
    input logic WAIT_REQUEST_STAGE2,

    // ===============================================
    // program memory read request signals
    // 1 to initiate read operation
    output logic PROGRAM_MEM_RDEN, 
    // address of instruction to read
    output logic [PC_WIDTH-1:0] PROGRAM_MEM_ADDR, 

    
    // return address to store into register, for CALL operations only, ignored otherwise
    output logic [PC_WIDTH-1:0] RETURN_ADDRESS_STAGE3

);

// 4-stage pipeline
/*
   Stage0: /CLK
         new instruction code is available at program memory output
         decode instruction, prepare input values and control signals for execution blocks
         LOAD/STORE/WAIT: prepare control signals for memory operation
   Stage1: /CLK
         operations are in progress
   Stage2: /CLK
         results from memory and bus operations are ready
         mux results from mem/bus/return_address
         now we can decide if we can move to next instruction or should wait, and reexecute the same instuction
         calculate new instruction pointer (PC), initiate reading of instruction from program memory
         initiate update PC if necessary (not in wait state) 
   Stage3: /CLK
         PC has new address
         results from ALU are ready
         mux results from ALU / mem_bus
         prepare data and control signals for saving operation result to register (if needed)
 */

logic [PC_WIDTH-1:0] pc_stage0; // instr mem out has new instruction: instruction decode
logic [PC_WIDTH-1:0] pc_stage1; // instr execution stage 1 
logic [PC_WIDTH-1:0] pc_stage2; // instr execution stage 2 MEM and WAIT results are ready
logic [PC_WIDTH-1:0] pc_stage3; // instr execution stage 3 ALU results ready

logic [1:0] thread_id_stage0;
logic [1:0] thread_id_stage1;
logic [1:0] thread_id_stage2;
logic [1:0] thread_id_stage3;

//logic ready_stage0;
//logic ready_stage1;
//logic ready_stage2;
//logic ready_stage3;


// Delay jump control information by 2 cycles
// jmp address from instruction decoder
logic [PC_WIDTH-1:0] jmp_address_stage2;
// 1 if need to jump to new address -- from instruction decoder
logic jmp_en_stage2;
//CALL_EN_STAGE0

//logic [PC_WIDTH-1:0] pc_stage2; // instr execution stage 2 MEM and WAIT results are ready
//logic [PC_WIDTH-1:0] jmp_address_stage2;

// =================================================================
// Logic for calculating next instruction address and return address
logic wait_is_requested;
always_comb wait_is_requested <= WAIT_REQUEST_STAGE2; // | ~ready_stage2;

logic [PC_WIDTH-1:0] pc_incremented_if_no_wait;
always_comb pc_incremented_if_no_wait <= pc_stage2 + ~wait_is_requested;

logic [PC_WIDTH-1:0] next_pc_value;
always_comb next_pc_value <= jmp_en_stage2 ? jmp_address_stage2 : pc_incremented_if_no_wait;

always_ff @(posedge CLK) begin
    if (RESET)
        RETURN_ADDRESS_STAGE3 <= 'b0;   // reset return address as well for all non-call instructions
    else if (CE)
        RETURN_ADDRESS_STAGE3 <= pc_incremented_if_no_wait;
end

always_comb PROGRAM_MEM_RDEN <= CE;
always_comb PROGRAM_MEM_ADDR <= next_pc_value;


always_ff @(posedge CLK) begin
    if (RESET) begin
        jmp_address_stage2 <= 'b0;
        jmp_en_stage2 <= 'b0;
    end else if (CE) begin
        jmp_address_stage2 <= JMP_ADDRESS_STAGE1;
        jmp_en_stage2 <= JMP_EN_STAGE1;
    end
end

assign PC_STAGE0 = pc_stage0;
assign THREAD_ID_STAGE0 = thread_id_stage0;

always_ff @(posedge CLK) begin
    if (RESET) begin
        // start PC addresses per thread
        // first 4 words should be JMP instructions to thread procedures
        pc_stage0 <= 'b1000;  // thread 2 start address = 8
        pc_stage1 <= 'b0100;  // thread 1 start address = 4
        pc_stage2 <= 'b0000;  // thread 0 start address = 0
        pc_stage3 <= 'b1100;  // thread 3 start address = 12
        thread_id_stage0 <= 'b10;
        thread_id_stage1 <= 'b01;
        thread_id_stage2 <= 'b00;
        thread_id_stage3 <= 'b11;
//        ready_stage0 <= 'b0;
//        ready_stage1 <= 'b0;
//        ready_stage2 <= 'b0;
//        ready_stage3 <= 'b0;
    end else if (CE) begin
        pc_stage0 <= pc_stage3;
        pc_stage1 <= pc_stage0;
        pc_stage2 <= pc_stage1;
        pc_stage3 <= next_pc_value;               // altering PC at this point
        thread_id_stage0 <= thread_id_stage3;
        thread_id_stage1 <= thread_id_stage0;
        thread_id_stage2 <= thread_id_stage1;
        thread_id_stage3 <= thread_id_stage2;
//        ready_stage0 <= ready_stage3;
//        ready_stage1 <= ready_stage0;
//        ready_stage2 <= 1'b1; //ready_stage1;
//        ready_stage3 <= ready_stage2;
    end
end

endmodule
