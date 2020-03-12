`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2020 05:14:52 PM
// Design Name: 
// Module Name: bcpu_dualport_bram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Dual port BRAM.
//      Synchronous read and write operations.
//      Optional register on each port output.
//      If output reg is disabled, latency is 1 clock cycle 
//      If output reg is enabled, latency is 2 clock cycles 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcpu_dualport_bram
#(
    parameter DATA_WIDTH = 18,
    parameter ADDR_WIDTH = 10,
    // 1 to disable writing to port A
    parameter USE_PORTA_READONLY = 1,
    // 1 to enable output register on port A read data
    parameter USE_PORTA_REG = 1,
    // 1 to enable output register on port B read data
    parameter USE_PORTB_REG = 1
)
(
    // clock
    input logic CLK,
    // reset, active 1
    input logic RESET,
    // clock enable
    input logic CE,

    //====================================
    // Port A    
    // 1 to start port A read or write operation
    input logic PORT_A_EN, 
    // enable port A write
    input logic PORT_A_WREN,
    // port A address 
    input logic [ADDR_WIDTH-1:0] PORT_A_ADDR, 
    // port A write data 
    input logic [DATA_WIDTH-1:0] PORT_A_WRDATA, 
    // port A read data 
    output logic [ADDR_WIDTH-1:0] PORT_A_RDDATA, 
    //====================================
    // Port B    
    // 1 to start port B read or write operation
    input logic PORT_B_EN, 
    // enable port B write
    input logic PORT_B_WREN,
    // port B address 
    input logic [ADDR_WIDTH-1:0] PORT_B_ADDR, 
    // port B write data 
    input logic [DATA_WIDTH-1:0] PORT_B_WRDATA, 
    // port B read data 
    output logic [ADDR_WIDTH-1:0] PORT_B_RDDATA 
);

localparam MEMSIZE = 1 << ADDR_WIDTH;
logic [DATA_WIDTH-1:0] memory[MEMSIZE];

logic [DATA_WIDTH-1:0] port_a_rddata;
logic [DATA_WIDTH-1:0] port_b_rddata;


always_ff @(posedge CLK)
    if (CE & PORT_A_EN) begin
        port_a_rddata <= memory[PORT_A_ADDR];
        if (PORT_A_WREN)
            memory[PORT_A_ADDR] <= PORT_A_WRDATA;
    end 

always_ff @(posedge CLK)
    if (CE & PORT_B_EN) begin
        port_b_rddata <= memory[PORT_B_ADDR];
        if (PORT_B_WREN)
            memory[PORT_B_ADDR] <= PORT_B_WRDATA;
    end 

generate
    if (USE_PORTA_REG == 1) begin
        always_ff @(posedge CLK)
            if (RESET & CE)
                PORT_A_RDDATA <= 'b0;
            else if (CE)
                PORT_A_RDDATA <= port_a_rddata;
    end else begin
        assign PORT_A_RDDATA = port_a_rddata;
    end

    if (USE_PORTB_REG == 1) begin
        always_ff @(posedge CLK)
            if (RESET & CE)
                PORT_B_RDDATA <= 'b0;
            else if (CE)
                PORT_B_RDDATA <= port_b_rddata;
    end else begin
        assign PORT_B_RDDATA = port_b_rddata;
    end
endgenerate

endmodule
