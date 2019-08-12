module theremin_io_ip #
(
    // Users to add parameters here

    // DMA parameters
    parameter integer BURST_SIZE = 8,
    // LCD
    parameter integer HPIXELS = 800,
    parameter integer VPIXELS = 480,
    parameter integer HBP = 2,
    parameter integer VBP = 2,
    parameter integer HSW = 10,
    parameter integer VSW = 2,
    parameter integer HFP = 2,
    parameter integer VFP = 2,
    parameter integer HSYNC_POLARITY = 0,
    parameter integer VSYNC_POLARITY = 0,

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH	= 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	= 6,
    
    // Parameters of Axi Master Bus Interface M00_AXI
    parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
    parameter integer C_M00_AXI_BURST_LEN	= 16,
    parameter integer C_M00_AXI_ID_WIDTH	= 6,
    parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
    parameter integer C_M00_AXI_DATA_WIDTH	= 64,
    parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_WUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_RUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_BUSER_WIDTH	= 0
)
(
    // Users to add ports here

    input logic CLK_PXCLK,

    // RGB interface
    // pixel clock
    output logic PXCLK,
    // horizontal sync
    output logic HSYNC,
    // vertical sync
    output logic VSYNC,
    // data enable
    output logic DE,
    // pixel color component Red
    output logic [3:0] R,
    // pixel color component Green
    output logic [3:0] G,
    // pixel color component Blue
    output logic [3:0] B,
    
    // backlight PWM control output
    output logic BACKLIGHT_PWM,
    
    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,

    // Ports of Axi Master Bus Interface M00_AXI
    input wire  m00_axi_arready,
    input wire  m00_axi_awready,
    input wire  m00_axi_bvalid,
    input wire  m00_axi_rlast,
    input wire  m00_axi_rvalid,
    input wire  m00_axi_wready,
    input wire [1 : 0] m00_axi_bresp,
    input wire [1 : 0] m00_axi_rresp,
    input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
    input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
    input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
    output wire  m00_axi_arvalid,
    output wire  m00_axi_awvalid,
    output wire  m00_axi_bready,
    output wire  m00_axi_rready,
    output wire  m00_axi_wlast,
    output wire  m00_axi_wvalid,
    output wire [1 : 0] m00_axi_arburst,
    output wire [1 : 0] m00_axi_arlock,    /// ***** AXI3: [1:0] AXI4: []
    output wire [2 : 0] m00_axi_arsize,
    output wire [1 : 0] m00_axi_awburst,
    output wire [1 : 0] m00_axi_awlock,    /// ***** AXI3: [1:0] AXI4: []
    output wire [2 : 0] m00_axi_awsize,
    output wire [2 : 0] m00_axi_arprot,
    output wire [2 : 0] m00_axi_awprot,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
    output wire [3 : 0] m00_axi_arcache,
    output wire [3 : 0] m00_axi_arlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    output wire [3 : 0] m00_axi_arqos,
    output wire [3 : 0] m00_axi_awcache,
    output wire [3 : 0] m00_axi_awlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    output wire [3 : 0] m00_axi_awqos,
    output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
    output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,

    output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_wid, // ****************** no WID in AXI4

    output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
    output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,

    input wire  m00_axi_aclk,
    input wire  m00_axi_aresetn
    /*
    // AXI4 master signals which are not supported in AXI3
    ,
    input wire  m00_axi_init_axi_txn,
    output wire  m00_axi_txn_done,
    output wire  m00_axi_error,
    output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
    output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
    input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
    output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
    input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser
    */

);

wire RESET;
wire CLK;
assign RESET = s00_axi_aclk;
assign CLK = s00_axi_aclk;

//============================
// AXI3 DMA signals

// read interface fixed settings
assign m00_axi_arburst = 2'b01;     // INCR
assign m00_axi_arsize = 3'b010;     // 4 bytes transfers
assign m00_axi_arlen = BURST_SIZE - 1; //4'b0000;     // ****** AXI3: [3:0] AXI4: [7:0] == burst size = 1

assign m00_axi_arcache = 4'b0011; // recommended value - normal, non-cacheable, modifable, bufferable
assign m00_axi_arprot = 3'b0; // recommended value

// write interface: defaults, readonly
assign m00_axi_awburst = 2'b0;
assign m00_axi_awsize = 3'b0;
assign m00_axi_awprot = 3'b0;
assign m00_axi_awcache = 4'b0;
assign m00_axi_arlock = 2'b0;    /// ***** AXI3: [1:0] AXI4: []
assign m00_axi_awlock = 2'b0;    /// ***** AXI3: [1:0] AXI4: []

assign m00_axi_awvalid = 1'b0;
assign m00_axi_wlast = 1'b0;
assign m00_axi_wvalid = 1'b0;
assign m00_axi_awlen = 4'b0;     // ****** AXI3: [3:0] AXI4: [7:0]

assign m00_axi_arqos= 4'b0;
assign m00_axi_awaddr = 32'b0;
assign m00_axi_awqos = 4'b0;

assign m00_axi_arid = 6'b0;
assign m00_axi_awid = 6'b0;

assign m00_axi_wid = 6'b0; // ****************** no WID in AXI4

assign m00_axi_wdata = 64'h0;
assign m00_axi_wstrb = 8'h0;
assign m00_axi_bready = 1'b0;


localparam Y_BITS = ( (VPIXELS+VBP+VSW+VFP) <= 256 ? 8
                       : (VPIXELS+VBP+VSW+VFP) <= 512 ? 9
                       : (VPIXELS+VBP+VSW+VFP) <= 1024 ? 10
                       :                                 11 );

// writeable IP register
logic [28:0] lcd_buffer_start_address_reg;
// writeable IP register
logic [7:0] lcd_backlight_brightness_reg;
// readonly IP register
logic [Y_BITS-1:0] lcd_row_index;

logic [15:0] lcd_pixel_data;

always_comb R <= lcd_pixel_data[11:8];
always_comb G <= lcd_pixel_data[7:4];
always_comb B <= lcd_pixel_data[3:0];
always_comb PXCLK <= CLK_PXCLK;

lcd_controller_axi3_dma #(
    // burst size for single DMA read request: on single DMA_START request,  BURST_SIZE words will be written to FIFO via a sequence of DMA_RD_DATA_VALID
    .BURST_SIZE(BURST_SIZE),
    .HPIXELS(HPIXELS),
    .VPIXELS(VPIXELS),
    .HBP(HBP),
    .VBP(VBP),
    .HSW(HSW),
    .VSW(VSW),
    .HFP(HFP),
    .VFP(VFP),
    .HSYNC_POLARITY(HSYNC_POLARITY),
    .VSYNC_POLARITY(VSYNC_POLARITY)
)
lcd_controller_axi3_dma_inst
(
    // DMA clock
    .CLK,
    // reset signal, active 1
    .RESET,

    // RGB interface
    // pixel clock
    .CLK_PXCLK,
    // horizontal sync
    .HSYNC,
    // vertical sync
    .VSYNC,
    // data enable
    .DE,
    // pixel value
    .PIXEL_DATA(lcd_pixel_data),
    
    // current Y position (row index); rows 0..VPIXELS-1 are visible, in CLK_PXCLK domain
    .ROW_INDEX(lcd_row_index),
    
    // backlight brightness setting, 0=dark, 255=light
    .BACKLIGHT_BRIGHTNESS(lcd_backlight_brightness_reg),
    // backlight PWM control output
    .BACKLIGHT_PWM,


    // DMA interface, in CLK clock domain
    // start address of buffer to read: after new cycle started, BUFFER_SIZE words will be read 
    .BUFFER_START_ADDRESS(lcd_buffer_start_address_reg),
    
    // AXI3 reader
    // address channel
    .m00_axi_arready,
    .m00_axi_arlen,     // ****** AXI3: [3:0] AXI4: [7:0]
    .m00_axi_araddr,
    .m00_axi_arvalid,
    // address channel
    .m00_axi_rlast,
    .m00_axi_rvalid,
    .m00_axi_rdata,
    .m00_axi_rready
);

// AXI4 Lite Slave implementation

logic  	axi_awready;
logic  	axi_wready;
logic [1 : 0] 	axi_bresp;
logic  	axi_bvalid;
//reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
logic  	axi_arready;
//reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
logic [1 : 0] 	axi_rresp;
logic  	axi_rvalid;

assign s00_axi_awready = axi_awready;
assign s00_axi_wready = axi_wready;
assign s00_axi_bresp = axi_bresp;
assign s00_axi_bvalid = axi_bvalid;
assign s00_axi_arready = axi_arready;
assign s00_axi_rresp = axi_rresp;
assign s00_axi_rvalid = axi_rvalid;

localparam ADDR_WIDTH = C_S00_AXI_ADDR_WIDTH - 2;

logic aw_en;

// awready logic
always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
      axi_awready <= 1'b0;
      aw_en <= 1'b1;
    end else begin
        if (~axi_awready & s00_axi_awvalid & s00_axi_wvalid & aw_en) begin
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
        end else if (s00_axi_bready && axi_bvalid) begin
            aw_en <= 1'b1;
            axi_awready <= 1'b0;
        end else begin
            axi_awready <= 1'b0;
        end
    end
end

// wready logic
always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
      axi_wready <= 1'b0;
    end else begin
        if (~axi_wready & s00_axi_awvalid & s00_axi_wvalid & aw_en) begin
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_wready <= 1'b1;
            aw_en <= 1'b0;
        end else begin
            axi_wready <= 1'b0;
        end
    end
end

// bvalid, bresp
always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
    end else begin    
        if (axi_awready & s00_axi_awvalid & ~axi_bvalid & axi_wready & s00_axi_wvalid) begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
        end else begin
            if (s00_axi_bready & axi_bvalid) begin 
                //check if bready is asserted while bvalid is high) 
                //(there is a possibility that bready is always asserted high)   
                axi_bvalid <= 1'b0; 
            end  
        end
    end
end   

logic [ADDR_WIDTH-1:0] slv_rdaddr;

always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        axi_arready <= 'b0;
        slv_rdaddr <= 'b0;
    end else begin    
        if (~axi_arready & s00_axi_arvalid) begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            slv_rdaddr <= m00_axi_araddr[C_S00_AXI_ADDR_WIDTH - 1:2];
        end else begin
            axi_arready <= 1'b0;
        end
    end
end   

always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
    end else begin    
        if (axi_arready & s00_axi_arvalid & ~axi_rvalid) begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
        end else if (axi_rvalid & s00_axi_rready ) begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
        end                
    end
end    


logic slv_rden;
logic [C_S00_AXI_DATA_WIDTH-1:0] slv_rddata;
always_comb slv_rden = axi_arready;
assign s00_axi_rdata = slv_rddata;

always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        slv_rddata <= 'b0;
    end else begin
        case (slv_rdaddr)
            0: slv_rddata <= {lcd_buffer_start_address_reg, 2'b00};
            1: slv_rddata <= {24'b0, lcd_backlight_brightness_reg};
            default: slv_rddata <= 'b0;
        endcase
    end
end


logic slv_wren;
logic [ADDR_WIDTH-1:0] slv_wraddr;
logic [C_S00_AXI_DATA_WIDTH-1:0] slv_wrdata;
always_comb slv_wren = axi_wready & s00_axi_wvalid & axi_awready & s00_axi_awvalid;
always_comb slv_wraddr = m00_axi_awaddr[C_S00_AXI_ADDR_WIDTH - 1:2];
always_comb slv_wrdata = s00_axi_wdata; 

always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        lcd_buffer_start_address_reg <= 'b0;
        lcd_backlight_brightness_reg <= 'b0;
    end else begin
        case (slv_wraddr)
            0: lcd_buffer_start_address_reg <= slv_wrdata[C_S00_AXI_DATA_WIDTH-1:2];
            1: lcd_backlight_brightness_reg <= slv_wrdata[7:0];
        endcase
    end
end

endmodule
