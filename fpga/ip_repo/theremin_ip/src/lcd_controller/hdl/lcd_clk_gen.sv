`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2019 03:01:06 PM
// Design Name: 
// Module Name: lcd_clk_gen
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


module lcd_clk_gen
#(
    parameter integer HPIXELS = 800,
    parameter integer VPIXELS = 480,
    parameter integer HBP = 13, // 2
    parameter integer VBP = 23, // 2
    parameter integer HSW = 29, // 10
    parameter integer VSW = 9, // 2
    parameter integer HFP = 12, // 2
    parameter integer VFP = 8, // 2
    parameter integer HSYNC_POLARITY = 0,
    parameter integer VSYNC_POLARITY = 0,
    parameter integer X_BITS = ( (HPIXELS+HBP+HSW+HFP) <= 256 ? 8
                               : (HPIXELS+HBP+HSW+HFP) <= 512 ? 9
                               : (HPIXELS+HBP+HSW+HFP) <= 1024 ? 10
                               :                                 11 ),
    parameter integer Y_BITS = ( (VPIXELS+VBP+VSW+VFP) <= 256 ? 8
                               : (VPIXELS+VBP+VSW+VFP) <= 512 ? 9
                               : (VPIXELS+VBP+VSW+VFP) <= 1024 ? 10
                               :                                 11 )
)
(
    input logic CLK_PXCLK,
    input logic RESET,
    
    output logic HSYNC,
    output logic VSYNC,
    output logic DE,
    output logic [X_BITS-1:0] X,
    output logic [Y_BITS-1:0] Y,
    // 1 for one cycle near before next frame begin
    output logic BEFORE_FRAME,
    // 1 for one cycle near after frame ended
    output logic AFTER_FRAME
    
//    , output logic debug_vde
//    , output logic debug_x_is_last_visible_pixel
//    , output logic debug_x_is_last_col
//    , output logic debug_x_is_sync_start
//    , output logic debug_x_is_sync_end
//    , output logic debug_y_is_last_visible_pixel
//    , output logic debug_y_is_last_row
//    , output logic debug_y_is_sync_start
//    , output logic debug_y_is_sync_end
);

localparam TOTAL_H = HPIXELS + HBP + HSW + HFP;
localparam TOTAL_V = VPIXELS + VBP + VSW + VFP;

logic [X_BITS-1:0] x_counter;
logic [Y_BITS-1:0] y_counter;
logic vsync_reg;
logic hsync_reg;
logic de_reg;
logic vde_reg;
logic before_frame_reg;
logic after_frame_reg;

always_comb X <= x_counter;
always_comb Y <= y_counter;
always_comb HSYNC <= hsync_reg;
always_comb VSYNC <= vsync_reg;
always_comb DE <= de_reg;

always_comb BEFORE_FRAME <= before_frame_reg;
always_comb AFTER_FRAME <= after_frame_reg;


logic x_is_last_visible_pixel;
logic x_is_last_col;
logic x_is_sync_start;
logic x_is_sync_end;
logic y_is_last_visible_pixel;
logic y_is_last_row;
logic y_is_sync_start;
logic y_is_sync_end;

always_comb x_is_last_visible_pixel = (x_counter == HPIXELS - 1);
always_comb x_is_last_col = (x_counter == TOTAL_H - 1);
always_comb x_is_sync_start = (x_counter == HPIXELS + HBP - 1);
always_comb x_is_sync_end = (x_counter == HPIXELS + HBP + HSW - 1);
always_comb y_is_last_visible_pixel = (y_counter == VPIXELS - 1);
always_comb y_is_last_row = (y_counter == TOTAL_V - 1);
always_comb y_is_sync_start = (y_counter == VPIXELS + VBP - 1);
always_comb y_is_sync_end = (y_counter == VPIXELS + VBP + VSW - 1);



// X loop: x_counter <= 0 .. TOTAL_H - 1
always_ff @(posedge CLK_PXCLK)
    if (RESET | x_is_last_col)
        x_counter <= 'b0;
    else
        x_counter <= x_counter + 1;

// Y loop: y_counter <= 0 .. TOTAL_V - 1 [when x_counter is last column]
always_ff @(posedge CLK_PXCLK)
    if (RESET | (x_is_last_col & y_is_last_row))
        y_counter <= 'b0;
    else if (x_is_last_col)
        y_counter <= y_counter + 1;

// hsync
always_ff @(posedge CLK_PXCLK)
    if (RESET)
        hsync_reg <= (HSYNC_POLARITY == 0 ? 1'b1 : 1'b0);
    else
        hsync_reg <= (x_is_sync_start) ? (HSYNC_POLARITY == 0 ? 1'b0 : 1'b1)
                   : (x_is_sync_end)   ? (HSYNC_POLARITY == 0 ? 1'b1 : 1'b0)
                   : hsync_reg;

// vsync
always_ff @(posedge CLK_PXCLK)
    if (RESET)
        vsync_reg <= (VSYNC_POLARITY == 0 ? 1'b1 : 1'b0);
    else
        vsync_reg <= (y_is_sync_start & x_is_last_col) ? (VSYNC_POLARITY == 0 ? 1'b0 : 1'b1)
                   : (y_is_sync_end & x_is_last_col)   ? (VSYNC_POLARITY == 0 ? 1'b1 : 1'b0)
                   : vsync_reg;

always_ff @(posedge CLK_PXCLK) begin
    if (RESET) begin
        de_reg <= 'b0;
        vde_reg <= 'b0;
        before_frame_reg <= 'b0;
        after_frame_reg <= 'b0;
    end else begin
        before_frame_reg <= x_is_last_visible_pixel & y_is_last_row;
        after_frame_reg <= x_is_last_visible_pixel & y_is_last_visible_pixel;
        // disable DE while Y is out of range
        vde_reg <= (x_is_last_visible_pixel & y_is_last_visible_pixel) ? 1'b0
                 : (x_is_last_visible_pixel & y_is_last_row)           ? 1'b1
                 :                                                       vde_reg;
        // calculate DE
        de_reg <=  (x_is_last_visible_pixel) ? 1'b0
                 : (x_is_last_col)           ? (vde_reg | y_is_last_row)
                 :                             de_reg;
    end
end

//always_comb debug_vde <= vde_reg;
//always_comb debug_x_is_last_visible_pixel <= x_is_last_visible_pixel;
//always_comb debug_x_is_last_col <= x_is_last_col;
//always_comb debug_x_is_sync_start <= x_is_sync_start;
//always_comb debug_x_is_sync_end <= x_is_sync_end;
//always_comb debug_y_is_last_visible_pixel <= y_is_last_visible_pixel;
//always_comb debug_y_is_last_row <= y_is_last_row;
//always_comb debug_y_is_sync_start <= y_is_sync_start;
//always_comb debug_y_is_sync_end <= y_is_sync_end;


endmodule
