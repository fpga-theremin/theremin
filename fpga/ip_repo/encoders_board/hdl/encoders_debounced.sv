`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2019 03:10:39 PM
// Design Name: 
// Module Name: encoders_debounced
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


module encoders_debounced
#(
    parameter CLK_DIV = 31
)
(
    input logic clk,
    input logic reset,
    output logic [3:0] mux_addr,
    input logic mux_out,
    output logic [15:0] debounced
);

typedef struct packed {
    logic out_state;
    logic[6:0] counter;
} debounce_state_t;

logic [4:0] clk_div_reg;
logic [3:0] mux_addr_reg;
always_comb mux_addr = mux_addr_reg;

// clock divider
always_ff @(posedge clk) begin
    if (reset) begin
        mux_addr_reg <= 4'b0;
        clk_div_reg <= CLK_DIV;
    end else begin
        if (clk_div_reg == 'b0) begin
            // last cycle
            mux_addr_reg <= mux_addr_reg + 1; 
            clk_div_reg <= CLK_DIV;
        end else begin
            clk_div_reg <= clk_div_reg - 1;
        end
    end
end

logic rd_en;
logic wr_en;

always_comb rd_en = (clk_div_reg == 5'b00011);
always_comb wr_en = (clk_div_reg == 5'b00001);

logic mux_out_reg;
// update mux_out register
always_ff @(posedge clk) begin
    if (reset) begin
        mux_out_reg <= 'b0;
    end else begin
        if (rd_en) begin
            mux_out_reg <= mux_out;
        end
    end
end


debounce_state_t prev_state;
debounce_state_t new_state;

// state memory
(* ram_style = "distributed" *) debounce_state_t debounce_states[16];
// distributed RAM read, async read
always_comb prev_state = debounce_states[mux_addr_reg];
// distributed RAM write, sync write
always_ff @(posedge clk) begin
    if (wr_en) begin
        debounce_states[mux_addr_reg] <= new_state;
    end
end

always_ff @(posedge clk) begin
    if (reset) begin
        debounced <= 'b0;
    end else if (wr_en) begin
        debounced[mux_addr_reg] <= new_state.out_state;
    end
end

always_comb begin
    if (mux_out_reg == prev_state.out_state) begin
        // not changed - reset counter
        new_state.counter = 7'b1111111;
        new_state.out_state = prev_state.out_state;
    end else begin
        // state is not equal
        if (prev_state.counter == 'b0) begin
            new_state.out_state = mux_out_reg;
            new_state.counter = 7'b1111111;
        end else begin
            new_state.out_state = prev_state.out_state;
            new_state.counter = prev_state.counter - 1;
        end
    end
end



endmodule
