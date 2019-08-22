
// file: theremin_hw_bd_clk_wiz_0_0.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
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
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// CLK_SHIFT___589.844______0.000______50.0_______92.486____123.861
// CLK_SHIFTB___589.844____180.000______50.0_______92.486____123.861
// CLK_DELAY___196.615______0.000______50.0______111.820____123.861
// _____CLK___147.461______0.000______50.0______117.580____123.861
// CLK_PXCLK____36.865______0.000______50.0______155.334____123.861
// CLK_MCLK____18.433______0.000______50.0______183.854____123.861
// __CLK_10_____9.216______0.000______50.0______211.190____123.861
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________125.000____________0.010

`timescale 1ps/1ps

module theremin_hw_bd_clk_wiz_0_0_clk_wiz 

 (// Clock in ports
  // Clock out ports
  output        CLK_SHIFT,
  output        CLK_SHIFTB,
  output        CLK_DELAY,
  output        CLK,
  output        CLK_PXCLK,
  output        CLK_MCLK,
  output        CLK_10,
  // Status and control signals
  input         resetn,
  output        locked,
  input         clk_in1
 );
  // Input buffering
  //------------------------------------
wire clk_in1_theremin_hw_bd_clk_wiz_0_0;
wire clk_in2_theremin_hw_bd_clk_wiz_0_0;
  IBUF clkin1_ibufg
   (.O (clk_in1_theremin_hw_bd_clk_wiz_0_0),
    .I (clk_in1));




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        CLK_SHIFT_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_SHIFTB_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_DELAY_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_PXCLK_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_MCLK_theremin_hw_bd_clk_wiz_0_0;
  wire        CLK_10_theremin_hw_bd_clk_wiz_0_0;

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_theremin_hw_bd_clk_wiz_0_0;
  wire        clkfbout_buf_theremin_hw_bd_clk_wiz_0_0;
  wire        clkfboutb_unused;
   wire clkout1_unused;
   wire clkout1b_unused;
   wire clkout2b_unused;
   wire clkout3b_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (2),
    .CLKFBOUT_MULT_F      (18.875),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (2.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (6),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKOUT3_DIVIDE       (8),
    .CLKOUT3_PHASE        (0.000),
    .CLKOUT3_DUTY_CYCLE   (0.500),
    .CLKOUT3_USE_FINE_PS  ("FALSE"),
    .CLKOUT4_DIVIDE       (32),
    .CLKOUT4_PHASE        (0.000),
    .CLKOUT4_DUTY_CYCLE   (0.500),
    .CLKOUT4_USE_FINE_PS  ("FALSE"),
    .CLKOUT5_DIVIDE       (64),
    .CLKOUT5_PHASE        (0.000),
    .CLKOUT5_DUTY_CYCLE   (0.500),
    .CLKOUT5_USE_FINE_PS  ("FALSE"),
    .CLKOUT6_DIVIDE       (128),
    .CLKOUT6_PHASE        (0.000),
    .CLKOUT6_DUTY_CYCLE   (0.500),
    .CLKOUT6_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (8.000))
  mmcm_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_theremin_hw_bd_clk_wiz_0_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (CLK_SHIFT_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT0B            (CLK_SHIFTB_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (CLK_DELAY_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (CLK_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (CLK_PXCLK_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT5             (CLK_MCLK_theremin_hw_bd_clk_wiz_0_0),
    .CLKOUT6             (CLK_10_theremin_hw_bd_clk_wiz_0_0),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_theremin_hw_bd_clk_wiz_0_0),
    .CLKIN1              (clk_in1_theremin_hw_bd_clk_wiz_0_0),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));
  assign reset_high = ~resetn; 

  assign locked = locked_int;
// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_theremin_hw_bd_clk_wiz_0_0),
    .I (clkfbout_theremin_hw_bd_clk_wiz_0_0));






  BUFG clkout1_buf
   (.O   (CLK_SHIFT),
    .I   (CLK_SHIFT_theremin_hw_bd_clk_wiz_0_0));


  BUFG clkout2_buf
   (.O   (CLK_SHIFTB),
    .I   (CLK_SHIFTB_theremin_hw_bd_clk_wiz_0_0));

  BUFG clkout3_buf
   (.O   (CLK_DELAY),
    .I   (CLK_DELAY_theremin_hw_bd_clk_wiz_0_0));

  BUFG clkout4_buf
   (.O   (CLK),
    .I   (CLK_theremin_hw_bd_clk_wiz_0_0));

  BUFG clkout5_buf
   (.O   (CLK_PXCLK),
    .I   (CLK_PXCLK_theremin_hw_bd_clk_wiz_0_0));

  BUFG clkout6_buf
   (.O   (CLK_MCLK),
    .I   (CLK_MCLK_theremin_hw_bd_clk_wiz_0_0));

  BUFG clkout7_buf
   (.O   (CLK_10),
    .I   (CLK_10_theremin_hw_bd_clk_wiz_0_0));



endmodule
