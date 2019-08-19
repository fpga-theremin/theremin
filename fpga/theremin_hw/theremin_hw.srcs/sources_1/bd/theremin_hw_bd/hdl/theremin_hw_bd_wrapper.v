//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1.1 (win64) Build 2580384 Sat Jun 29 08:12:21 MDT 2019
//Date        : Mon Aug 19 10:45:33 2019
//Host        : DTNN-VLOPATIN running 64-bit major release  (build 9200)
//Command     : generate_target theremin_hw_bd_wrapper.bd
//Design      : theremin_hw_bd_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module theremin_hw_bd_wrapper
   (AUDIO_I2C_0_scl,
    AUDIO_I2C_0_sda,
    AUDIO_I2S_0_bclk,
    AUDIO_I2S_0_i2s_data_in,
    AUDIO_I2S_0_i2s_data_out0,
    AUDIO_I2S_0_i2s_data_out1,
    AUDIO_I2S_0_lrck,
    AUDIO_I2S_0_mclk,
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    ENC_MUX_0_mux_addr,
    ENC_MUX_0_mux_data,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    LCD_0_b,
    LCD_0_backlight,
    LCD_0_de,
    LCD_0_g,
    LCD_0_hsync,
    LCD_0_pxclk,
    LCD_0_r,
    LCD_0_vsync,
    PITCH_FREQ_IN_0,
    RGBLED0_0_b,
    RGBLED0_0_g,
    RGBLED0_0_r,
    RGBLED1_0_b,
    RGBLED1_0_g,
    RGBLED1_0_r,
    TOUCH_I2C_0_scl,
    TOUCH_I2C_0_sda,
    TOUCH_INTERRUPT_0,
    TOUCH_RESET_0,
    VOLUME_FREQ_IN_0,
    sys_clock);
  inout AUDIO_I2C_0_scl;
  inout AUDIO_I2C_0_sda;
  output AUDIO_I2S_0_bclk;
  input AUDIO_I2S_0_i2s_data_in;
  output AUDIO_I2S_0_i2s_data_out0;
  output AUDIO_I2S_0_i2s_data_out1;
  output AUDIO_I2S_0_lrck;
  output AUDIO_I2S_0_mclk;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output [3:0]ENC_MUX_0_mux_addr;
  input ENC_MUX_0_mux_data;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [3:0]LCD_0_b;
  output LCD_0_backlight;
  output LCD_0_de;
  output [3:0]LCD_0_g;
  output LCD_0_hsync;
  output LCD_0_pxclk;
  output [3:0]LCD_0_r;
  output LCD_0_vsync;
  input PITCH_FREQ_IN_0;
  output RGBLED0_0_b;
  output RGBLED0_0_g;
  output RGBLED0_0_r;
  output RGBLED1_0_b;
  output RGBLED1_0_g;
  output RGBLED1_0_r;
  inout TOUCH_I2C_0_scl;
  inout TOUCH_I2C_0_sda;
  input TOUCH_INTERRUPT_0;
  output TOUCH_RESET_0;
  input VOLUME_FREQ_IN_0;
  input sys_clock;

  wire AUDIO_I2C_0_scl;
  wire AUDIO_I2C_0_sda;
  wire AUDIO_I2S_0_bclk;
  wire AUDIO_I2S_0_i2s_data_in;
  wire AUDIO_I2S_0_i2s_data_out0;
  wire AUDIO_I2S_0_i2s_data_out1;
  wire AUDIO_I2S_0_lrck;
  wire AUDIO_I2S_0_mclk;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire [3:0]ENC_MUX_0_mux_addr;
  wire ENC_MUX_0_mux_data;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [3:0]LCD_0_b;
  wire LCD_0_backlight;
  wire LCD_0_de;
  wire [3:0]LCD_0_g;
  wire LCD_0_hsync;
  wire LCD_0_pxclk;
  wire [3:0]LCD_0_r;
  wire LCD_0_vsync;
  wire PITCH_FREQ_IN_0;
  wire RGBLED0_0_b;
  wire RGBLED0_0_g;
  wire RGBLED0_0_r;
  wire RGBLED1_0_b;
  wire RGBLED1_0_g;
  wire RGBLED1_0_r;
  wire TOUCH_I2C_0_scl;
  wire TOUCH_I2C_0_sda;
  wire TOUCH_INTERRUPT_0;
  wire TOUCH_RESET_0;
  wire VOLUME_FREQ_IN_0;
  wire sys_clock;

  theremin_hw_bd theremin_hw_bd_i
       (.AUDIO_I2C_0_scl(AUDIO_I2C_0_scl),
        .AUDIO_I2C_0_sda(AUDIO_I2C_0_sda),
        .AUDIO_I2S_0_bclk(AUDIO_I2S_0_bclk),
        .AUDIO_I2S_0_i2s_data_in(AUDIO_I2S_0_i2s_data_in),
        .AUDIO_I2S_0_i2s_data_out0(AUDIO_I2S_0_i2s_data_out0),
        .AUDIO_I2S_0_i2s_data_out1(AUDIO_I2S_0_i2s_data_out1),
        .AUDIO_I2S_0_lrck(AUDIO_I2S_0_lrck),
        .AUDIO_I2S_0_mclk(AUDIO_I2S_0_mclk),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .ENC_MUX_0_mux_addr(ENC_MUX_0_mux_addr),
        .ENC_MUX_0_mux_data(ENC_MUX_0_mux_data),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .LCD_0_b(LCD_0_b),
        .LCD_0_backlight(LCD_0_backlight),
        .LCD_0_de(LCD_0_de),
        .LCD_0_g(LCD_0_g),
        .LCD_0_hsync(LCD_0_hsync),
        .LCD_0_pxclk(LCD_0_pxclk),
        .LCD_0_r(LCD_0_r),
        .LCD_0_vsync(LCD_0_vsync),
        .PITCH_FREQ_IN_0(PITCH_FREQ_IN_0),
        .RGBLED0_0_b(RGBLED0_0_b),
        .RGBLED0_0_g(RGBLED0_0_g),
        .RGBLED0_0_r(RGBLED0_0_r),
        .RGBLED1_0_b(RGBLED1_0_b),
        .RGBLED1_0_g(RGBLED1_0_g),
        .RGBLED1_0_r(RGBLED1_0_r),
        .TOUCH_I2C_0_scl(TOUCH_I2C_0_scl),
        .TOUCH_I2C_0_sda(TOUCH_I2C_0_sda),
        .TOUCH_INTERRUPT_0(TOUCH_INTERRUPT_0),
        .TOUCH_RESET_0(TOUCH_RESET_0),
        .VOLUME_FREQ_IN_0(VOLUME_FREQ_IN_0),
        .sys_clock(sys_clock));
endmodule
