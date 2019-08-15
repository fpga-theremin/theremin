`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2019 10:25:24 AM
// Design Name: 
// Module Name: axi4_lite_slave_reg_tb
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


module axi4_lite_slave_reg_tb();


localparam C_S_AXI_DATA_WIDTH	= 32;
    // Width of S_AXI address bus
localparam C_S_AXI_ADDR_WIDTH	= 6;


// interface access peripherial registers
logic REG_WREN;                              // write enable for control register
logic [C_S_AXI_DATA_WIDTH-1:0] REG_WR_DATA;  // new data for writing to control register -- in CLK_IN_BUS clock domain
logic [C_S_AXI_ADDR_WIDTH-1 - ((C_S_AXI_DATA_WIDTH/32) + 1):0] REG_WR_ADDR;  // write address of control register
logic REG_RDEN;                              // read enable for control register
logic [C_S_AXI_ADDR_WIDTH-1 - ((C_S_AXI_DATA_WIDTH/32) + 1):0] REG_RD_ADDR;  // read address of control register
logic [C_S_AXI_DATA_WIDTH-1:0] REG_RD_DATA;  // read value of control register

// User ports ends
// Do not modify the ports beyond this line

// Global Clock Signal
logic S_AXI_ACLK;
// Global Reset Signal. This Signal is Active LOW
logic S_AXI_ARESETN;

// WRITE
// Write address (issued by master, acceped by Slave)
logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR;
// Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
logic [2 : 0] S_AXI_AWPROT;
// Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
logic S_AXI_AWVALID;
// Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
logic S_AXI_AWREADY;
// Write data (issued by master, acceped by Slave) 
logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA;
// Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB;
// Write valid. This signal indicates that valid write
    // data and strobes are available.
logic S_AXI_WVALID;
// Write ready. This signal indicates that the slave
    // can accept the write data.
logic S_AXI_WREADY;
// Write response. This signal indicates the status
    // of the write transaction.
logic [1 : 0] S_AXI_BRESP;
// Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
logic S_AXI_BVALID;
// Response ready. This signal indicates that the master
    // can accept a write response.
logic S_AXI_BREADY;

// READ
// Read address (issued by master, acceped by Slave)
logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR;
// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
logic [2 : 0] S_AXI_ARPROT;
// Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
logic S_AXI_ARVALID;
// Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
logic S_AXI_ARREADY;
// Read data (issued by slave)
logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA;
// Read response. This signal indicates the status of the
    // read transfer.
logic [1 : 0] S_AXI_RRESP;
// Read valid. This signal indicates that the channel is
    // signaling the required read data.
logic S_AXI_RVALID;
// Read ready. This signal indicates that the master can
    // accept the read data and response information.
logic S_AXI_RREADY;

//logic debug_read_transaction_started;

axi4_lite_slave_reg axi4_lite_slave_reg_inst
(
    .*
);

initial begin
    REG_RD_DATA = 'b0;
    S_AXI_ACLK = 'b0;
    S_AXI_ARESETN = 'b0;
    S_AXI_AWADDR = 'b0;
    S_AXI_AWPROT = 'b0;
    S_AXI_AWVALID = 'b0;
    S_AXI_WDATA = 'b0;
    S_AXI_WSTRB = 'b0;
    S_AXI_WVALID = 'b0;
    S_AXI_BREADY = 'b0;
    S_AXI_ARADDR = 'b0;
    S_AXI_ARPROT = 'b0;
    S_AXI_ARVALID = 'b0;
    S_AXI_RREADY = 'b0;

    #15 S_AXI_ARESETN = 'b0;
    #150 S_AXI_ARESETN = 'b1;
end

always begin
    #3.333 S_AXI_ACLK = 'b0;
    #3.333 S_AXI_ACLK = 'b1;
end

always @(posedge REG_RDEN) begin
    case (REG_RD_ADDR)
    0: REG_RD_DATA = 32'hffffffff;
    1: REG_RD_DATA = 32'h11111111;
    2: REG_RD_DATA = 32'h22222222;
    3: REG_RD_DATA = 32'h33333333;
    4: REG_RD_DATA = 32'h44444444;
    5: REG_RD_DATA = 32'h55555555;
    6: REG_RD_DATA = 32'h66666666;
    7: REG_RD_DATA = 32'h77777777;
    8: REG_RD_DATA = 32'h88888888;
    9: REG_RD_DATA = 32'h99999999;
    10: REG_RD_DATA = 32'haaaaaaaa;
    11: REG_RD_DATA = 32'hbbbbbbbb;
    12: REG_RD_DATA = 32'hcccccccc;
    13: REG_RD_DATA = 32'hdddddddd;
    14: REG_RD_DATA = 32'heeeeeeee;
    15: REG_RD_DATA = 32'hffffffff;
    default: REG_RD_DATA = 32'hbadbadee;
    endcase
end

`define doAxi4Read(addr) \
    @(posedge S_AXI_ACLK) #1 S_AXI_ARADDR = addr; \
    @(posedge S_AXI_ACLK) #1 S_AXI_ARVALID = 1; \
    @(negedge S_AXI_ARREADY) #1 S_AXI_ARVALID = 0; S_AXI_RREADY = 1; \
    @(negedge S_AXI_RVALID) S_AXI_RREADY = 0; $display("doAxi4Read(%2h) result=%h", addr, S_AXI_RDATA);

`define doAxi4Write(addr, value) \
    @(posedge S_AXI_ACLK) #1 S_AXI_AWADDR = addr; \
    @(posedge S_AXI_ACLK) #1 S_AXI_AWVALID = 1; S_AXI_WDATA = value; S_AXI_WSTRB  = 4'b1111; S_AXI_WVALID = 1; \
    @(negedge S_AXI_WREADY) #1 S_AXI_AWVALID = 0; S_AXI_WDATA = 0; S_AXI_WSTRB  = 4'b0000; S_AXI_WVALID = 0; \
    S_AXI_BREADY = 1; \
    @(negedge S_AXI_BVALID) S_AXI_RREADY = 0; S_AXI_BREADY = 0; $display("doAxi4Write(%2h, %h) response=%h", addr, value, S_AXI_BRESP);

initial begin
    @(posedge S_AXI_ARESETN) ;
    #30;
    `doAxi4Read(5*4);
    `doAxi4Read(2*4);
    `doAxi4Read(1*4);
    `doAxi4Write(1*4, 32'h12345678);
    `doAxi4Write(1*4, 32'habcdef12);
    #100
    $finish();
end

endmodule
