
/*
    PWM_REG[31:20] led1 r,g,b
    PWM_REG[19:8] led0 r,g,b
    PWM_REG[7:0] LCD backlight brightness
*/


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

    parameter integer PITCH_PERIOD_BITS = 16,
    parameter integer VOLUME_PERIOD_BITS = 16,
    parameter integer FILTER_OUT_BITS = 32,
    parameter integer FILTER_SHIFT_BITS = 8,

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
    parameter integer C_M00_AXI_DATA_WIDTH	= 32,
    parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_WUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_RUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_BUSER_WIDTH	= 0
)
(
    // Users to add ports here
    
    // Clocks:
    
    // ~600MHz = 589.844MHz - ISERDESE2 DDR mode shift clock
    input logic CLK_SHIFT,
    
    // ~600MHz = 589.844MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
    input logic CLK_SHIFTB,
    
    // ~200MHz  = 196.615MHz input for driving IDELAYE2
    input logic CLK_DELAY,

    // CLK = s00_axi_aclk = m00_axi_aclk = CLK_SHIFT/4 = ~150MHz = 147.461MHz : main clock for buses
    
    // CLK_SHIFT/16 = CLK/4 = 36.865MHz - pixel clock for LCD
    input logic CLK_PXCLK,

    // MCLK = CLK / 8 = CLK_PXCLK / 2 = 18.432625
    // LRCK = MCLK / 384 = ~48000 = 48001.627 : audio sample clock
    // CLK / LRCK = 3072 = 1024*3

    // RGB interface
    // pixel clock = CLK_PXCLK
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


    inout TOUCH_I2C_DATA,
    inout TOUCH_I2C_CLK,        // 400KHz
    input logic TOUCH_INTERRUPT,
    output logic TOUCH_RESET,

    // theremin sensor interface
    // serial input of pitch signal
    input logic PITCH_FREQ_IN,
    // serial input of volume signal
    input logic VOLUME_FREQ_IN,


    // audio interface
    // MCLK = CLK / 8 = 18.4375MHz
    output logic MCLK,
    // LRCK(WS) = MCLK / 384 = BCLK / 48 = 48014.32
    output logic LRCK,
    // BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
    output logic BCLK,
    // serial output for channel 0 (Line Out)
    output logic I2S_DATA_OUT0,
    // serial output for channel 1 (Phones Out)
    output logic I2S_DATA_OUT1,
    // I2S data input for Line In
    input logic I2S_DATA_IN,
    // audio interrupt request, set to 1 in the beginning of new sample cycle, reset to 0 afer ACK
    output logic AUDIO_IRQ,

    inout AUDIO_I2C_DATA,
    inout AUDIO_I2C_CLK,        // 400KHz

    // encoders board interface
    // MUX address for multiplexing N buttons into one MUX_OUT
    output logic [3:0] MUX_ADDR,
    // input value from MUX (MUX_OUT <= button[MUX_ADDR])
    input logic MUX_OUT,

    output logic led0_r,
    output logic led0_g,
    output logic led0_b,
    output logic led1_r,
    output logic led1_g,
    output logic led1_b,
    
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


/*
   offset  name                          read                         write
   0:     REG_STATUS                     [31] audio irq enabled       [31] audio irq enabled
                                         [30] audio irq 1=pending     [30] audio irq ack write 0 to ack
                                         [29:10] reserved             [29:10] reserved
                                         [9:0] current screen y       [9:0] reserved
   1:     REG_LCD_FRAMEBUFFER_ADDR       [31:0] PITCH_PERIOD          [31:0] lcd framebuffer start address (0=disabled)
   2:     REG_PWM                        [31:0] VOLUME_PERIOD         [31:20] led1 color
                                                                      [19:8] led0 color
                                                                      [7:0] LCD backlight brightness
   3:     REG_ENCODER_0                  [31:0] encoder 0             [31:0] reserved                                                                   
   4:     REG_LINE_OUT_L/LINE_IN_L       [23:0] line in L             [23:0] line out L                                                                      
   5:     REG_LINE_OUT_R/LINE_IN_R       [23:0] line in R             [23:0] line out R                                                                      
   6:     REG_PHONES_OUT_L               [31:0] encoder 1             [23:0] phones out L                                                                      
   7:     REG_PHONES_OUT_R               [31:0] encoder 2             [23:0] phones out R
                                                                         
   8:     REG_TOUCH_I2C                  [31:0] I2C touch             [31:0] I2C touch                                                                      
   9:     REG_AUDIO_I2C                  [31:0] I2C audio             [31:0] I2C audio                                                                      

   12:    REG_AUDIO_STATUS               [31] audio irq enabled       [31] audio irq enabled
                                         [30] audio irq 1=pending     [30] audio irq ack write 0 to ack
                                         [29:12] sample counter       [29:0] reserved
                                         [11:0] subsample counter     [29:0] reserved
*/

typedef enum logic [3:0] {
    RD_REG_STATUS = 0,
    RD_REG_PITCH_PERIOD = 1,
    RD_REG_VOLUME_PERIOD = 2,
    RD_REG_ENCODER_0 = 3,
    RD_REG_LINE_IN_L = 4,
    RD_REG_LINE_IN_R = 5,
    RD_REG_ENCODER_1 = 6,
    RD_REG_ENCODER_2 = 7,
    RD_REG_AUDIO_I2C = 8,
    RD_REG_TOUCH_I2C = 9,
    RD_REG_AUDIO_STATUS = 12    // [31] Audio IRQ enable [30] Audio IRQ pending
} reg_rd_addr_t;

typedef enum logic [3:0] {
    WR_REG_STATUS = 0,
    WR_REG_LCD_FRAMEBUFFER_ADDR = 1,
    WR_REG_PWM = 2,
    WR_REG_LINE_OUT_L = 4,
    WR_REG_LINE_OUT_R = 5,
    WR_REG_PHONES_OUT_L = 6,
    WR_REG_PHONES_OUT_R = 7,
    WR_REG_AUDIO_I2C = 8,
    WR_REG_TOUCH_I2C = 9,    
    WR_REG_AUDIO_STATUS = 12    // [31] Audio IRQ enable [30] Audio IRQ ack (write 0)
} reg_wr_addr_t;



wire RESET;
wire CLK;
assign RESET = ~s00_axi_aresetn;
assign CLK = s00_axi_aclk;

always_comb TOUCH_RESET <= 1'b0;

//============================
// AXI3 DMA signals

// read interface fixed settings
assign m00_axi_arburst = 2'b01;     // INCR
assign m00_axi_arsize = 3'b010;     // 4 bytes transfers
//assign m00_axi_arlen = BURST_SIZE - 1; //4'b0000;     // ****** AXI3: [3:0] AXI4: [7:0] == burst size = 1

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
assign m00_axi_awaddr = {C_M00_AXI_ADDR_WIDTH{1'b0}};
assign m00_axi_awqos = 4'b0;

assign m00_axi_arid = 6'b0;
assign m00_axi_awid = 6'b0;

assign m00_axi_wid = 6'b0; // ****************** no WID in AXI4

assign m00_axi_wdata = 32'h0;
assign m00_axi_wstrb = 4'h0;
assign m00_axi_bready = 1'b0;


localparam Y_BITS = ( (VPIXELS+VBP+VSW+VFP) <= 256 ? 8
                       : (VPIXELS+VBP+VSW+VFP) <= 512 ? 9
                       : (VPIXELS+VBP+VSW+VFP) <= 1024 ? 10
                       :                                 11 );

// writeable IP register
logic [29:0] lcd_buffer_start_address_reg;
// writeable IP register
logic [7:0] lcd_backlight_brightness_reg;
// color of LED0 (4 bits per R, G, B)    
logic [11:0] rbg_led_color0_reg;
// color of LED0 (4 bits per R, G, B)    
logic [11:0] rbg_led_color1_reg;

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
    
    // color of LED0 (4 bits per R, G, B)    
    .RGB_LED_COLOR0(rbg_led_color0_reg),
    // color of LED0 (4 bits per R, G, B)    
    .RGB_LED_COLOR1(rbg_led_color1_reg),
    
    // color led0 control output {r,g,b}
    .LED0_PWM,
    // color led1 control output {r,g,b}
    .LED1_PWM,
    
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

// when 1, audio IRQ is enabled
logic AUDIO_INTERRUPT_EN;
always_comb AUDIO_INTERRUPT_EN <= 1'b1;
// audio IRQ acknowlegement
logic AUDIO_IRQ_ACK;

// Audio Out Channel 0 (Line Out) data
// left
logic [23:0] OUT_LEFT_CHANNEL0;
// right
logic [23:0] OUT_RIGHT_CHANNEL0;

// Audio Out Channel 1 (Phones Out) data
// left
logic [23:0] OUT_LEFT_CHANNEL1;
// right
logic [23:0] OUT_RIGHT_CHANNEL1;

// Audio Input channel 0 (Line In)
// left
logic [23:0] IN_LEFT_CHANNEL;
// right
logic [23:0] IN_RIGHT_CHANNEL;

// 1 for one CLK cycle when new sample is being started (I2S shift registers load) - once per ~48KHz
logic SAMPLE_START;
// increments each CLK cycle, resets to 0 each sample start
logic [11:0] SUBSAMPLE_COUNT;
// increments each sample
logic [17:0] SAMPLE_COUNT;

theremin_audio_io theremin_audio_io_inst (
    // Source clock near to 147.457MHz -> =147.500MHz from PLL
    .CLK,
    // Reset, active 1
    .RESET,
    
    // generated audio clocks
    
    // MCLK = CLK / 8 = 18.4375MHz
    .MCLK,
    // LRCK(WS) = MCLK / 384 = BCLK / 48 = 48014.32
    .LRCK,
    // BCLK = MCLK / 8 = LRCK * 48 = 2304687.5Hz
    .BCLK,
    // serial output for channel 0 (Line Out)
    .I2S_DATA_OUT0,
    // serial output for channel 1 (Phones Out)
    .I2S_DATA_OUT1,
    // I2S data input for Line In
    .I2S_DATA_IN,


    // when 1, audio IRQ is enabled
    .INTERRUPT_EN(AUDIO_INTERRUPT_EN),
    // audio interrupt request, set to 1 in the beginning of new sample cycle, reset to 0 afer ACK
    .IRQ(AUDIO_IRQ),
    // audio IRQ acknowlegement
    .ACK(AUDIO_IRQ_ACK),

    // 1 for one CLK cycle when new sample is being started (I2S shift registers load) - once per ~48KHz
    .SAMPLE_START,
    // increments each CLK cycle, resets to 0 each sample start
    .SUBSAMPLE_COUNT,
    // increments each sample
    .SAMPLE_COUNT,

    // Audio Out Channel 0 (Line Out) data
    // left
    .OUT_LEFT_CHANNEL0,
    // right
    .OUT_RIGHT_CHANNEL0,
    
    // Audio Out Channel 1 (Phones Out) data
    // left
    .OUT_LEFT_CHANNEL1,
    // right
    .OUT_RIGHT_CHANNEL1,

    // Audio Input channel 0 (Line In)
    // left
    .IN_LEFT_CHANNEL,
    // right
    .IN_RIGHT_CHANNEL
    
);

// packed state of encoders 0, 1
// [31]    encoder1 button state
// [30:24] encoder1 button state duration
// [23:20] encoder1 pressed state position
// [19:16] encoder1 normal state position
// [15]    encoder0 button state
// [14:8]  encoder0 button state duration
// [7:4]   encoder0 pressed state position
// [3:0]   encoder0 normal state position
logic[31:0] ENCODERS_R0;
// packed state of encoders 2, 3
// [31]    encoder3 button state
// [30:24] encoder3 button state duration
// [23:20] encoder3 pressed state position
// [19:16] encoder3 normal state position
// [15]    encoder2 button state
// [14:8]  encoder2 button state duration
// [7:4]   encoder2 pressed state position
// [3:0]   encoder2 normal state position
logic[31:0] ENCODERS_R1;
// packed state of encoder 4, button and last change counter
// [31]    button state
// [30:24] button state duration
// [23:16] duration (in 100ms intervals) since last change of any control
// [15]    encoder4 button state
// [14:8]  encoder4 button state duration
// [7:4]   encoder4 pressed state position
// [3:0]   encoder4 normal state position
logic[31:0] ENCODERS_R2;

encoders_board encoders_board_inst (
    .CLK,
    .RESET,
    
    // for reading encoders and button signals using MUX
    
    // MUX address for multiplexing N buttons into one MUX_OUT
    .MUX_ADDR,
    // input value from MUX (MUX_OUT <= button[MUX_ADDR])
    .MUX_OUT,

    // exposing processed state as controller registers
    
    // packed state of encoders 0, 1
    // [31]    encoder1 button state
    // [30:24] encoder1 button state duration
    // [23:20] encoder1 pressed state position
    // [19:16] encoder1 normal state position
    // [15]    encoder0 button state
    // [14:8]  encoder0 button state duration
    // [7:4]   encoder0 pressed state position
    // [3:0]   encoder0 normal state position
    .R0(ENCODERS_R0),
    // packed state of encoders 2, 3
    // [31]    encoder3 button state
    // [30:24] encoder3 button state duration
    // [23:20] encoder3 pressed state position
    // [19:16] encoder3 normal state position
    // [15]    encoder2 button state
    // [14:8]  encoder2 button state duration
    // [7:4]   encoder2 pressed state position
    // [3:0]   encoder2 normal state position
    .R1(ENCODERS_R1),
    // packed state of encoder 4, button and last change counter
    // [31]    button state
    // [30:24] button state duration
    // [23:16] duration (in 100ms intervals) since last change of any control
    // [15]    encoder4 button state
    // [14:8]  encoder4 button state duration
    // [7:4]   encoder4 pressed state position
    // [3:0]   encoder4 normal state position
    .R2(ENCODERS_R2)
);


// output value for channel A (in CLK clock domain)
logic [FILTER_OUT_BITS-1:0] PITCH_PERIOD_FILTERED;
// output value for channel B (in CLK clock domain)
logic [FILTER_OUT_BITS-1:0] VOLUME_PERIOD_FILTERED;

logic [2:0] IIR_MAX_STAGE;

theremin_oversampling_iserdes_period_measure
#(
    .PITCH_PERIOD_BITS(PITCH_PERIOD_BITS),
    .VOLUME_PERIOD_BITS(VOLUME_PERIOD_BITS),
    .DATA_BITS(FILTER_OUT_BITS),
    .FILTER_SHIFT_BITS(FILTER_SHIFT_BITS)
) theremin_oversampling_iserdes_period_measure_inst
(
    // 600MHz - ISERDESE2 DDR mode shift clock
    .CLK_SHIFT,
    // 600MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
    .CLK_SHIFTB,
    // 150MHz - ISERDESE2 parallel output clock - clock should be 1/4 of CLK_SHIFT, phase aligned 
    .CLK_PARALLEL(CLK),

    // 200MHz input for driving IDELAYE2
    .CLK_DELAY,
    
    // main clock ~100MHz for measured value outputs
    .CLK,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET,

    // serial input of pitch signal
    .PITCH_FREQ_IN,
    // serial input of volume signal
    .VOLUME_FREQ_IN,

    .IIR_MAX_STAGE,
    
    // measured pitch period value - number of 1.2GHz*oversampling ticks since last change  (in CLK clock domain)
    //output logic [PITCH_PERIOD_BITS-1:0] PITCH_PERIOD_NOFILTER,
    // measured volume period value - number of 1.2GHz*oversampling ticks since last change (in CLK clock domain)
    //output logic [VOLUME_PERIOD_BITS-1:0] VOLUME_PERIOD_NOFILTER,

    // output value for channel A (in CLK clock domain)
    .PITCH_PERIOD_FILTERED,
    // output value for channel B (in CLK clock domain)
    .VOLUME_PERIOD_FILTERED

);


logic REG_WREN;                              // write enable for control register
logic [C_S00_AXI_DATA_WIDTH-1:0] REG_WR_DATA;  // new data for writing to control register -- in CLK_IN_BUS clock domain
logic [C_S00_AXI_ADDR_WIDTH-1 - ((C_S00_AXI_DATA_WIDTH/32) + 1):0] REG_WR_ADDR;  // write address of control register
logic REG_RDEN;                              // read enable for control register
logic [C_S00_AXI_ADDR_WIDTH-1 - ((C_S00_AXI_DATA_WIDTH/32) + 1):0] REG_RD_ADDR;  // read address of control register
logic [C_S00_AXI_DATA_WIDTH-1:0] REG_RD_DATA;  // read value of control register



logic audio_i2c_start;
always_comb audio_i2c_start <= REG_WREN & (REG_WR_ADDR == WR_REG_AUDIO_I2C); 
logic [9:0] audio_i2c_status;

theremin_i2c theremin_i2c_audio_inst (
    .CLK,
    .RESET,
    
    .COMMAND(REG_WR_DATA[23:0]),  // [23:16] - device address/op, [15:8] register address, [7:0] data to write
    .START(audio_i2c_start),           // 1 for one CLK to start operation according to COMMAND
    .DATA_OUT(audio_i2c_status[7:0]), // data read from I2C
    .READY(audio_i2c_status[8]),
    .ERROR(audio_i2c_status[9]),
    
    .I2C_DATA(AUDIO_I2C_DATA),
    .I2C_CLK(AUDIO_I2C_CLK)        // 400KHz
);

logic touch_i2c_start;
always_comb touch_i2c_start <= REG_WREN & (REG_WR_ADDR == WR_REG_TOUCH_I2C); 
logic [10:0] touch_i2c_status;
assign touch_i2c_status[10] = TOUCH_INTERRUPT;

theremin_i2c theremin_i2c_touch_inst (
    .CLK,
    .RESET,
    
    .COMMAND(REG_WR_DATA[23:0]),  // [23:16] - device address/op, [15:8] register address, [7:0] data to write
    .START(touch_i2c_start),           // 1 for one CLK to start operation according to COMMAND
    .DATA_OUT(touch_i2c_status[7:0]), // data read from I2C
    .READY(touch_i2c_status[8]),
    .ERROR(touch_i2c_status[9]),
    
    .I2C_DATA(TOUCH_I2C_DATA),
    .I2C_CLK(TOUCH_I2C_CLK)        // 400KHz
);


// color led0 control output {r,g,b}
logic [2:0] LED0_PWM;
// color led1 control output {r,g,b}
logic [2:0] LED1_PWM;

always_comb led0_r <= LED0_PWM[2];
always_comb led0_g <= LED0_PWM[1];
always_comb led0_b <= LED0_PWM[0];
always_comb led1_r <= LED1_PWM[2];
always_comb led1_g <= LED1_PWM[1];
always_comb led1_b <= LED1_PWM[0];

axi4_lite_slave_reg #
(
    // Width of S_AXI data bus
    .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
    // Width of S_AXI address bus
    .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
)
axi4_lite_slave_reg_impl
(
    // Users to add ports here
    
    // interface access peripherial registers
    .REG_WREN,                              // write enable for control register
    .REG_WR_DATA,  // new data for writing to control register -- in CLK_IN_BUS clock domain
    .REG_WR_ADDR,  // write address of control register
    .REG_RDEN,                              // read enable for control register
    .REG_RD_ADDR,  // read address of control register
    .REG_RD_DATA,  // read value of control register
    
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    .S_AXI_ACLK(s00_axi_aclk),
    // Global Reset Signal. This Signal is Active LOW
    .S_AXI_ARESETN(s00_axi_aresetn),
    
    // WRITE
    // Write address (issued by master, acceped by Slave)
    .S_AXI_AWADDR(s00_axi_awaddr),
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    .S_AXI_AWPROT(s00_axi_awprot),
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    .S_AXI_AWVALID(s00_axi_awvalid),
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    .S_AXI_AWREADY(s00_axi_awready),
    // Write data (issued by master, acceped by Slave) 
    .S_AXI_WDATA(s00_axi_wdata),
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    .S_AXI_WSTRB(s00_axi_wstrb),
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    .S_AXI_WVALID(s00_axi_wvalid),
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    .S_AXI_WREADY(s00_axi_wready),
    // Write response. This signal indicates the status
        // of the write transaction.
    .S_AXI_BRESP(s00_axi_bresp),
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    .S_AXI_BVALID(s00_axi_bvalid),
    // Response ready. This signal indicates that the master
        // can accept a write response.
    .S_AXI_BREADY(s00_axi_bready),

    // READ
    // Read address (issued by master, acceped by Slave)
    .S_AXI_ARADDR(s00_axi_araddr),
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    .S_AXI_ARPROT(s00_axi_arprot),
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    .S_AXI_ARVALID(s00_axi_arvalid),
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    .S_AXI_ARREADY(s00_axi_arready),
    // Read data (issued by slave)
    .S_AXI_RDATA(s00_axi_rdata),
    // Read response. This signal indicates the status of the
        // read transfer.
    .S_AXI_RRESP(s00_axi_rresp),
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    .S_AXI_RVALID(s00_axi_rvalid),
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    .S_AXI_RREADY(s00_axi_rready)
);


logic [31:0] status_reg;
always_comb status_reg[31] <= 'b0; //audio_irq_enabled; // audio irq enabled
always_comb status_reg[30] <= 'b0; //AUDIO_IRQ;         // audio irq pending
always_comb status_reg[29:27] <= IIR_MAX_STAGE;  // read max IIR filter stage 1..7
always_comb status_reg[26:10] <= 'b0;
always_comb status_reg[9:0] <= {{(10 - Y_BITS){1'b0}}, lcd_row_index};

logic audio_irq_enabled;
logic [31:0] audio_status_reg;
always_comb audio_status_reg[31] <= audio_irq_enabled; // audio irq enabled
always_comb audio_status_reg[30] <= AUDIO_IRQ;         // audio irq pending
always_comb audio_status_reg[11:0] <= SUBSAMPLE_COUNT; // audio subsample counter
always_comb audio_status_reg[29:12] <= SAMPLE_COUNT; // audio sample counter

always_ff @(posedge CLK) begin
    if (RESET) begin
        audio_status_reg[11:0] <= 'b0;
    end else begin
        audio_status_reg[11:0] <= 'b0;
    end
end

// Registers read

// write 0 to bit 30 of audio status reg to send audio IRQ ACK
assign AUDIO_IRQ_ACK = (REG_WREN & (REG_WR_ADDR == WR_REG_AUDIO_STATUS) & ~REG_WR_DATA[30]);

assign REG_RD_DATA = (REG_RD_ADDR == RD_REG_STATUS) ? status_reg
                   : (REG_RD_ADDR == RD_REG_PITCH_PERIOD) ? PITCH_PERIOD_FILTERED
                   : (REG_RD_ADDR == RD_REG_VOLUME_PERIOD) ? VOLUME_PERIOD_FILTERED
                   : (REG_RD_ADDR == RD_REG_ENCODER_0) ? ENCODERS_R0
                   : (REG_RD_ADDR == RD_REG_LINE_IN_L) ? {IN_LEFT_CHANNEL[23], IN_LEFT_CHANNEL}
                   : (REG_RD_ADDR == RD_REG_LINE_IN_R) ? {IN_RIGHT_CHANNEL[23], IN_RIGHT_CHANNEL}
                   : (REG_RD_ADDR == RD_REG_ENCODER_1) ? ENCODERS_R1
                   : (REG_RD_ADDR == RD_REG_ENCODER_2) ? ENCODERS_R2
                   : (REG_RD_ADDR == RD_REG_AUDIO_I2C) ? { 22'b0, audio_i2c_status}
                   : (REG_RD_ADDR == RD_REG_TOUCH_I2C) ? { 22'b0, touch_i2c_status}
                   : (REG_RD_ADDR == RD_REG_AUDIO_STATUS) ? { audio_status_reg }
                   :                                                 0;

// Registers write

always_ff @(posedge m00_axi_aclk) begin
    if (~m00_axi_aresetn) begin
        audio_irq_enabled <= 'b0;
        lcd_buffer_start_address_reg <= 'b0;
        lcd_backlight_brightness_reg <= 8'b11111111;
        rbg_led_color0_reg <= 'b0;
        rbg_led_color1_reg <= 'b0;
        OUT_LEFT_CHANNEL0 <= 'b0;
        OUT_RIGHT_CHANNEL0 <= 'b0;
        OUT_LEFT_CHANNEL1 <= 'b0;
        OUT_RIGHT_CHANNEL1 <= 'b0;
        IIR_MAX_STAGE <= 3'b011; // 4 stages
    end else if (REG_WREN) begin
        case (REG_WR_ADDR)
            WR_REG_STATUS: IIR_MAX_STAGE <= REG_WR_DATA[29:27]; // 4 stages
            WR_REG_LCD_FRAMEBUFFER_ADDR: lcd_buffer_start_address_reg <= REG_WR_DATA[C_S00_AXI_DATA_WIDTH-1:2];
            WR_REG_PWM: begin
                    lcd_backlight_brightness_reg <= REG_WR_DATA[7:0];
                    rbg_led_color0_reg <= REG_WR_DATA[19:8];
                    rbg_led_color1_reg <= REG_WR_DATA[31:20];
                end
            WR_REG_LINE_OUT_L: OUT_LEFT_CHANNEL0 <= REG_WR_DATA[23:0];
            WR_REG_LINE_OUT_R: OUT_RIGHT_CHANNEL0 <= REG_WR_DATA[23:0];
            WR_REG_PHONES_OUT_L: OUT_LEFT_CHANNEL1 <= REG_WR_DATA[23:0];
            WR_REG_PHONES_OUT_R: AUDIO_OUT_1_R: OUT_RIGHT_CHANNEL1 <= REG_WR_DATA[23:0];
            WR_REG_AUDIO_STATUS: audio_irq_enabled <= REG_WR_DATA[31];
        endcase
    end
end

endmodule
