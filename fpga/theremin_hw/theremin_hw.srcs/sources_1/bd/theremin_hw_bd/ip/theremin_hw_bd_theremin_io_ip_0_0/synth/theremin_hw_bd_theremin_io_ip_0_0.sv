// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: coolreader_org:user:theremin_io_ip:1.0
// IP Revision: 11

(* X_CORE_INFO = "theremin_io_ip,Vivado 2019.1.1" *)
(* CHECK_LICENSE_TYPE = "theremin_hw_bd_theremin_io_ip_0_0,theremin_io_ip,{}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module theremin_hw_bd_theremin_io_ip_0_0 (
  CLK_SHIFT,
  CLK_SHIFTB,
  CLK_DELAY,
  CLK_PXCLK,
  PXCLK,
  HSYNC,
  VSYNC,
  DE,
  R,
  G,
  B,
  BACKLIGHT_PWM,
  TOUCH_I2C_DATA,
  TOUCH_I2C_CLK,
  TOUCH_INTERRUPT,
  TOUCH_RESET,
  PITCH_FREQ_IN,
  VOLUME_FREQ_IN,
  MCLK,
  LRCK,
  BCLK,
  I2S_DATA_OUT0,
  I2S_DATA_OUT1,
  I2S_DATA_IN,
  AUDIO_IRQ,
  AUDIO_I2C_DATA,
  AUDIO_I2C_CLK,
  MUX_ADDR,
  MUX_OUT,
  led0_r,
  led0_g,
  led0_b,
  led1_r,
  led1_g,
  led1_b,
  s00_axi_aclk,
  s00_axi_aresetn,
  s00_axi_awaddr,
  s00_axi_awprot,
  s00_axi_awvalid,
  s00_axi_awready,
  s00_axi_wdata,
  s00_axi_wstrb,
  s00_axi_wvalid,
  s00_axi_wready,
  s00_axi_bresp,
  s00_axi_bvalid,
  s00_axi_bready,
  s00_axi_araddr,
  s00_axi_arprot,
  s00_axi_arvalid,
  s00_axi_arready,
  s00_axi_rdata,
  s00_axi_rresp,
  s00_axi_rvalid,
  s00_axi_rready,
  m00_axi_arready,
  m00_axi_awready,
  m00_axi_bvalid,
  m00_axi_rlast,
  m00_axi_rvalid,
  m00_axi_wready,
  m00_axi_bresp,
  m00_axi_rresp,
  m00_axi_bid,
  m00_axi_rid,
  m00_axi_rdata,
  m00_axi_arvalid,
  m00_axi_awvalid,
  m00_axi_bready,
  m00_axi_rready,
  m00_axi_wlast,
  m00_axi_wvalid,
  m00_axi_arburst,
  m00_axi_arlock,
  m00_axi_arsize,
  m00_axi_awburst,
  m00_axi_awlock,
  m00_axi_awsize,
  m00_axi_arprot,
  m00_axi_awprot,
  m00_axi_araddr,
  m00_axi_awaddr,
  m00_axi_arcache,
  m00_axi_arlen,
  m00_axi_arqos,
  m00_axi_awcache,
  m00_axi_awlen,
  m00_axi_awqos,
  m00_axi_arid,
  m00_axi_awid,
  m00_axi_wid,
  m00_axi_wdata,
  m00_axi_wstrb,
  m00_axi_aclk,
  m00_axi_aresetn
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_SHIFT, FREQ_HZ 589843750, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK_SHIFT CLK" *)
input wire CLK_SHIFT;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_SHIFTB, FREQ_HZ 589843750, PHASE 180, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK_SHIFTB CLK" *)
input wire CLK_SHIFTB;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_DELAY, FREQ_HZ 196614583, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK_DELAY CLK" *)
input wire CLK_DELAY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_PXCLK, FREQ_HZ 36865234, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK_PXCLK CLK" *)
input wire CLK_PXCLK;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD PXCLK" *)
output wire PXCLK;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD HSYNC" *)
output wire HSYNC;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD VSYNC" *)
output wire VSYNC;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD DE" *)
output wire DE;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD R" *)
output wire [3 : 0] R;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD G" *)
output wire [3 : 0] G;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD B" *)
output wire [3 : 0] B;
(* X_INTERFACE_INFO = "coolreader.org:user:lcd_rgb_12bit:1.0 LCD BACKLIGHT" *)
output wire BACKLIGHT_PWM;
(* X_INTERFACE_INFO = "coolreader.org:user:i2c:1.0 TOUCH_I2C SDA" *)
inout wire TOUCH_I2C_DATA;
(* X_INTERFACE_INFO = "coolreader.org:user:i2c:1.0 TOUCH_I2C SCL" *)
inout wire TOUCH_I2C_CLK;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME TOUCH_INTERRUPT, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 TOUCH_INTERRUPT INTERRUPT" *)
input wire TOUCH_INTERRUPT;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME TOUCH_RESET, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 TOUCH_RESET RST" *)
output wire TOUCH_RESET;
input wire PITCH_FREQ_IN;
input wire VOLUME_FREQ_IN;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S MCLK" *)
output wire MCLK;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S LRCK" *)
output wire LRCK;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S BCLK" *)
output wire BCLK;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S I2S_DATA_OUT0" *)
output wire I2S_DATA_OUT0;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S I2S_DATA_OUT1" *)
output wire I2S_DATA_OUT1;
(* X_INTERFACE_INFO = "coolreader.org:user:i2s_io:1.0 AUDIO_I2S I2S_DATA_IN" *)
input wire I2S_DATA_IN;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AUDIO_IRQ, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 AUDIO_IRQ INTERRUPT" *)
output wire AUDIO_IRQ;
(* X_INTERFACE_INFO = "coolreader.org:user:i2c:1.0 AUDIO_I2C SDA" *)
inout wire AUDIO_I2C_DATA;
(* X_INTERFACE_INFO = "coolreader.org:user:i2c:1.0 AUDIO_I2C SCL" *)
inout wire AUDIO_I2C_CLK;
(* X_INTERFACE_INFO = "coolreader.org:user:input_pin_mux:1.0 ENC_MUX MUX_ADDR" *)
output wire [3 : 0] MUX_ADDR;
(* X_INTERFACE_INFO = "coolreader.org:user:input_pin_mux:1.0 ENC_MUX MUX_DATA" *)
input wire MUX_OUT;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED0 R" *)
output wire led0_r;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED0 G" *)
output wire led0_g;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED0 B" *)
output wire led0_b;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED1 R" *)
output wire led1_r;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED1 G" *)
output wire led1_g;
(* X_INTERFACE_INFO = "coolreader.org:user:rgb_led:1.0 RGBLED1 B" *)
output wire led1_b;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aclk, ASSOCIATED_BUSIF s00_axi, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 147460937, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s00_axi_aclk CLK" *)
input wire s00_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s00_axi_aresetn RST" *)
input wire s00_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWADDR" *)
input wire [5 : 0] s00_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWPROT" *)
input wire [2 : 0] s00_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWVALID" *)
input wire s00_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWREADY" *)
output wire s00_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WDATA" *)
input wire [31 : 0] s00_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WSTRB" *)
input wire [3 : 0] s00_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WVALID" *)
input wire s00_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WREADY" *)
output wire s00_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BRESP" *)
output wire [1 : 0] s00_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BVALID" *)
output wire s00_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BREADY" *)
input wire s00_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARADDR" *)
input wire [5 : 0] s00_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARPROT" *)
input wire [2 : 0] s00_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARVALID" *)
input wire s00_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARREADY" *)
output wire s00_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RDATA" *)
output wire [31 : 0] s00_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RRESP" *)
output wire [1 : 0] s00_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RVALID" *)
output wire s00_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 147460937, ID_WIDTH 0, ADDR_WIDTH 6, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM_READ_THREADS 4, NUM_WRITE_THREADS \
4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RREADY" *)
input wire s00_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARREADY" *)
input wire m00_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWREADY" *)
input wire m00_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BVALID" *)
input wire m00_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RLAST" *)
input wire m00_axi_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RVALID" *)
input wire m00_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WREADY" *)
input wire m00_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BRESP" *)
input wire [1 : 0] m00_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RRESP" *)
input wire [1 : 0] m00_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BID" *)
input wire [5 : 0] m00_axi_bid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RID" *)
input wire [5 : 0] m00_axi_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RDATA" *)
input wire [31 : 0] m00_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARVALID" *)
output wire m00_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWVALID" *)
output wire m00_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi BREADY" *)
output wire m00_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi RREADY" *)
output wire m00_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WLAST" *)
output wire m00_axi_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WVALID" *)
output wire m00_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARBURST" *)
output wire [1 : 0] m00_axi_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARLOCK" *)
output wire [1 : 0] m00_axi_arlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARSIZE" *)
output wire [2 : 0] m00_axi_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWBURST" *)
output wire [1 : 0] m00_axi_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWLOCK" *)
output wire [1 : 0] m00_axi_awlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWSIZE" *)
output wire [2 : 0] m00_axi_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARPROT" *)
output wire [2 : 0] m00_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWPROT" *)
output wire [2 : 0] m00_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARADDR" *)
output wire [31 : 0] m00_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWADDR" *)
output wire [31 : 0] m00_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARCACHE" *)
output wire [3 : 0] m00_axi_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARLEN" *)
output wire [3 : 0] m00_axi_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARQOS" *)
output wire [3 : 0] m00_axi_arqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWCACHE" *)
output wire [3 : 0] m00_axi_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWLEN" *)
output wire [3 : 0] m00_axi_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWQOS" *)
output wire [3 : 0] m00_axi_awqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi ARID" *)
output wire [5 : 0] m00_axi_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi AWID" *)
output wire [5 : 0] m00_axi_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WID" *)
output wire [5 : 0] m00_axi_wid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WDATA" *)
output wire [31 : 0] m00_axi_wdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi, DATA_WIDTH 32, PROTOCOL AXI3, FREQ_HZ 147460937, ID_WIDTH 6, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 16, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1,\
 RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi WSTRB" *)
output wire [3 : 0] m00_axi_wstrb;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_aclk, ASSOCIATED_BUSIF m00_axi, ASSOCIATED_RESET m00_axi_aresetn, FREQ_HZ 147460937, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m00_axi_aclk CLK" *)
input wire m00_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m00_axi_aresetn RST" *)
input wire m00_axi_aresetn;

  theremin_io_ip #(
    .BURST_SIZE(8),
    .HPIXELS(800),
    .VPIXELS(480),
    .HBP(2),
    .VBP(2),
    .HSW(10),
    .VSW(2),
    .HFP(2),
    .VFP(2),
    .HSYNC_POLARITY(0),
    .VSYNC_POLARITY(0),
    .PITCH_PERIOD_BITS(16),
    .VOLUME_PERIOD_BITS(16),
    .FILTER_OUT_BITS(32),
    .FILTER_SHIFT_BITS(8),
    .C_S00_AXI_DATA_WIDTH(32),
    .C_S00_AXI_ADDR_WIDTH(6),
    .C_M00_AXI_TARGET_SLAVE_BASE_ADDR(32'H40000000),
    .C_M00_AXI_BURST_LEN(16),
    .C_M00_AXI_ID_WIDTH(6),
    .C_M00_AXI_ADDR_WIDTH(32),
    .C_M00_AXI_DATA_WIDTH(32),
    .C_M00_AXI_AWUSER_WIDTH(0),
    .C_M00_AXI_ARUSER_WIDTH(0),
    .C_M00_AXI_WUSER_WIDTH(0),
    .C_M00_AXI_RUSER_WIDTH(0),
    .C_M00_AXI_BUSER_WIDTH(0)
  ) inst (
    .CLK_SHIFT(CLK_SHIFT),
    .CLK_SHIFTB(CLK_SHIFTB),
    .CLK_DELAY(CLK_DELAY),
    .CLK_PXCLK(CLK_PXCLK),
    .PXCLK(PXCLK),
    .HSYNC(HSYNC),
    .VSYNC(VSYNC),
    .DE(DE),
    .R(R),
    .G(G),
    .B(B),
    .BACKLIGHT_PWM(BACKLIGHT_PWM),
    .TOUCH_I2C_DATA(TOUCH_I2C_DATA),
    .TOUCH_I2C_CLK(TOUCH_I2C_CLK),
    .TOUCH_INTERRUPT(TOUCH_INTERRUPT),
    .TOUCH_RESET(TOUCH_RESET),
    .PITCH_FREQ_IN(PITCH_FREQ_IN),
    .VOLUME_FREQ_IN(VOLUME_FREQ_IN),
    .MCLK(MCLK),
    .LRCK(LRCK),
    .BCLK(BCLK),
    .I2S_DATA_OUT0(I2S_DATA_OUT0),
    .I2S_DATA_OUT1(I2S_DATA_OUT1),
    .I2S_DATA_IN(I2S_DATA_IN),
    .AUDIO_IRQ(AUDIO_IRQ),
    .AUDIO_I2C_DATA(AUDIO_I2C_DATA),
    .AUDIO_I2C_CLK(AUDIO_I2C_CLK),
    .MUX_ADDR(MUX_ADDR),
    .MUX_OUT(MUX_OUT),
    .led0_r(led0_r),
    .led0_g(led0_g),
    .led0_b(led0_b),
    .led1_r(led1_r),
    .led1_g(led1_g),
    .led1_b(led1_b),
    .s00_axi_aclk(s00_axi_aclk),
    .s00_axi_aresetn(s00_axi_aresetn),
    .s00_axi_awaddr(s00_axi_awaddr),
    .s00_axi_awprot(s00_axi_awprot),
    .s00_axi_awvalid(s00_axi_awvalid),
    .s00_axi_awready(s00_axi_awready),
    .s00_axi_wdata(s00_axi_wdata),
    .s00_axi_wstrb(s00_axi_wstrb),
    .s00_axi_wvalid(s00_axi_wvalid),
    .s00_axi_wready(s00_axi_wready),
    .s00_axi_bresp(s00_axi_bresp),
    .s00_axi_bvalid(s00_axi_bvalid),
    .s00_axi_bready(s00_axi_bready),
    .s00_axi_araddr(s00_axi_araddr),
    .s00_axi_arprot(s00_axi_arprot),
    .s00_axi_arvalid(s00_axi_arvalid),
    .s00_axi_arready(s00_axi_arready),
    .s00_axi_rdata(s00_axi_rdata),
    .s00_axi_rresp(s00_axi_rresp),
    .s00_axi_rvalid(s00_axi_rvalid),
    .s00_axi_rready(s00_axi_rready),
    .m00_axi_arready(m00_axi_arready),
    .m00_axi_awready(m00_axi_awready),
    .m00_axi_bvalid(m00_axi_bvalid),
    .m00_axi_rlast(m00_axi_rlast),
    .m00_axi_rvalid(m00_axi_rvalid),
    .m00_axi_wready(m00_axi_wready),
    .m00_axi_bresp(m00_axi_bresp),
    .m00_axi_rresp(m00_axi_rresp),
    .m00_axi_bid(m00_axi_bid),
    .m00_axi_rid(m00_axi_rid),
    .m00_axi_rdata(m00_axi_rdata),
    .m00_axi_arvalid(m00_axi_arvalid),
    .m00_axi_awvalid(m00_axi_awvalid),
    .m00_axi_bready(m00_axi_bready),
    .m00_axi_rready(m00_axi_rready),
    .m00_axi_wlast(m00_axi_wlast),
    .m00_axi_wvalid(m00_axi_wvalid),
    .m00_axi_arburst(m00_axi_arburst),
    .m00_axi_arlock(m00_axi_arlock),
    .m00_axi_arsize(m00_axi_arsize),
    .m00_axi_awburst(m00_axi_awburst),
    .m00_axi_awlock(m00_axi_awlock),
    .m00_axi_awsize(m00_axi_awsize),
    .m00_axi_arprot(m00_axi_arprot),
    .m00_axi_awprot(m00_axi_awprot),
    .m00_axi_araddr(m00_axi_araddr),
    .m00_axi_awaddr(m00_axi_awaddr),
    .m00_axi_arcache(m00_axi_arcache),
    .m00_axi_arlen(m00_axi_arlen),
    .m00_axi_arqos(m00_axi_arqos),
    .m00_axi_awcache(m00_axi_awcache),
    .m00_axi_awlen(m00_axi_awlen),
    .m00_axi_awqos(m00_axi_awqos),
    .m00_axi_arid(m00_axi_arid),
    .m00_axi_awid(m00_axi_awid),
    .m00_axi_wid(m00_axi_wid),
    .m00_axi_wdata(m00_axi_wdata),
    .m00_axi_wstrb(m00_axi_wstrb),
    .m00_axi_aclk(m00_axi_aclk),
    .m00_axi_aresetn(m00_axi_aresetn)
  );
endmodule
