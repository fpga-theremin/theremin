
`timescale 1 ns / 1 ps

module axi4_lite_slave_reg #
(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 6
)
(
    // Users to add ports here
    
    // interface access peripherial registers
    output logic REG_WREN,                              // write enable for control register
    output logic [C_S_AXI_DATA_WIDTH-1:0] REG_WR_DATA,  // new data for writing to control register -- in CLK_IN_BUS clock domain
    output logic [C_S_AXI_ADDR_WIDTH-1 - ((C_S_AXI_DATA_WIDTH/32) + 1):0] REG_WR_ADDR,  // write address of control register
    output logic REG_RDEN,                              // read enable for control register
    output logic [C_S_AXI_ADDR_WIDTH-1 - ((C_S_AXI_DATA_WIDTH/32) + 1):0] REG_RD_ADDR,  // read address of control register
    input  logic [C_S_AXI_DATA_WIDTH-1:0] REG_RD_DATA,  // read value of control register
    
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    
    // WRITE
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S_AXI_BREADY,

    // READ
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S_AXI_RREADY
);

assign S_AXI_BRESP = 2'b0; // write response is always OK
assign S_AXI_RRESP = 2'b0; // write response is always OK

// Example-specific design signals
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)
localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;

logic write_transaction_started;
logic write_transaction_starting;

logic reg_wren;
logic axi_bvalid;
assign REG_WREN = reg_wren;
assign REG_WR_ADDR = S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB];
assign REG_WR_DATA = S_AXI_WDATA;
assign S_AXI_WREADY = reg_wren;
assign S_AXI_AWREADY = reg_wren;
assign S_AXI_BVALID = axi_bvalid;

always_comb write_transaction_starting <= S_AXI_AWVALID & S_AXI_WVALID & ~write_transaction_started; 
always_ff @(posedge  S_AXI_ACLK )
begin
    if ( ~S_AXI_ARESETN ) begin
        write_transaction_started <= 'b0;
        reg_wren <= 'b0;
        axi_bvalid <= 'b0;
    end else begin
        if (write_transaction_starting) begin
            write_transaction_started <= 1'b1;
            reg_wren <= 'b1;
        end else begin
            reg_wren <= 'b0;
            if (write_transaction_started & S_AXI_BREADY) begin
                axi_bvalid <= 1'b1;
            end else if (write_transaction_started & axi_bvalid) begin
                write_transaction_started <= 'b0;
                axi_bvalid <= 1'b0;
            end
        end
    end
end

logic [C_S_AXI_DATA_WIDTH-1:0] rd_data;
logic [C_S_AXI_ADDR_WIDTH-2:0] read_address_reg;
logic read_transaction_started;
logic read_transaction_starting;

logic reg_rden;
logic axi_rvalid;
assign REG_RDEN = reg_rden;
assign REG_RD_ADDR = read_address_reg;
assign S_AXI_RDATA = rd_data;
assign S_AXI_ARREADY = reg_rden;
assign S_AXI_RVALID = axi_rvalid;

always_comb read_transaction_starting <= S_AXI_ARVALID & ~read_transaction_started & ~write_transaction_starting & ~write_transaction_started;
always_ff @(posedge  S_AXI_ACLK )
begin
    if ( ~S_AXI_ARESETN ) begin
        read_transaction_started <= 'b0;
        reg_rden <= 'b0;
        read_address_reg <= 'b0;
        axi_rvalid <= 'b0;
        rd_data <= 'b0;
    end else begin
        if (read_transaction_starting) begin
            read_transaction_started <= 1'b1;
            reg_rden <= 'b1;
            read_address_reg <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB];
        end else begin
            reg_rden <= 'b0;
            if (read_transaction_started & S_AXI_RREADY) begin
                axi_rvalid <= 1'b1;
                rd_data <= REG_RD_DATA;
            end else if (write_transaction_started & axi_rvalid) begin
                read_transaction_started <= 'b0;
                axi_rvalid <= 1'b0;
            end
        end
    end
end

// Add user logic here

// User logic ends

endmodule
