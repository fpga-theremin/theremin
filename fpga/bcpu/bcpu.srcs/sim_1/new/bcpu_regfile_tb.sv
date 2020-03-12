`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2020 09:54:15 AM
// Design Name: 
// Module Name: bcpu_regfile_tb
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


module bcpu_regfile_tb(

    );


localparam DATA_WIDTH = 16;           // 16, 17, 18
localparam REG_ADDR_WIDTH = 5;        // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5 


// input clock: write operation is done synchronously using this clock
logic CLK;

//=========================================
// Synchronous write port
// when WR_EN == 1, write value WR_DATA to address WR_ADDR on raising edge of CLK 
logic REG_WR_EN;
logic [REG_ADDR_WIDTH-1:0] WR_REG_ADDR;
logic [DATA_WIDTH-1:0] WR_REG_DATA;

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


bcpu_regfile
#(
    .DATA_WIDTH(DATA_WIDTH),          // 16, 17, 18
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)   // (1<<REG_ADDR_WIDTH) values: 32 values for addr width 5 
)
bcpu_regfile_inst
(
    .*
);

always begin
    // 200MHz
    #2.5 CLK = 1;
    #2.5 CLK = 0;
end

`define readA(addr) \
    RD_REG_ADDR_A = addr; #4 $display("A[%2x] = %x", addr, RD_REG_DATA_A);
`define readB(addr) \
    RD_REG_ADDR_B = addr; #4 $display("B[%2x] = %x", addr, RD_REG_DATA_B);
`define write(addr, data) \
    $display("write [%2x] <= %x", addr, data); \
    @(posedge CLK) #2 WR_REG_ADDR = addr; WR_REG_DATA = data; REG_WR_EN = 1; \
    @(posedge CLK) #2 REG_WR_EN = 0;

initial begin

    #3 REG_WR_EN = 0;
    #44 RD_REG_ADDR_A = 0;
    #33 RD_REG_ADDR_B = 1;
    #14 WR_REG_ADDR = 2;
    #15 WR_REG_DATA = 16'h1234;

    `readA(0)
    `readA(3)
    `write(3, 16'h0133)        
    `readB(3)
    `write(1, 16'h0111)        
    `write(3, 16'habcd)        
    `write(4, 16'h4123)        
    `readA(0)
    `readA(1)
    `readA(2)
    `readA(3)
    `readB(4)
    `write(31, 16'h1123)        
    `write(1, 16'hdead)        
    `readA(31)
    `readB(0)
    `readB(1)
    
    $finish();
    
end



endmodule
