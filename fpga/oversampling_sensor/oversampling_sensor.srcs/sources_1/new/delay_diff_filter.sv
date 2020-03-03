`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 06:37:46 PM
// Design Name: 
// Module Name: delay_diff_filter
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


module delay_diff_filter
#(
    parameter DELAY_ADDR_BITS = 7,
    parameter VALUE_BITS = 20
)
(
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    input logic CLK,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,

    input logic [VALUE_BITS - 1 : 0] IN_VALUE,

    input logic WR,
    
    output logic [VALUE_BITS - 1 : 0] OUT_VALUE
    
);

(* ram_style="distributed" *)
logic [VALUE_BITS - 1 : 0] delay_ram [(1 << DELAY_ADDR_BITS) - 1 : 0];

logic [DELAY_ADDR_BITS-1 : 0] addr_counter;
always_ff @(posedge CLK) begin
    if (RESET) begin
        addr_counter <= 'b0;
    end else begin
        if (WR)
            addr_counter <= addr_counter + 1;
    end
end

always_ff @(posedge CLK) begin
    if (WR)
        delay_ram[addr_counter] <= IN_VALUE;
end

logic [VALUE_BITS - 1 : 0] diff_value;

always_ff @(posedge CLK) begin
    if (RESET) begin
        diff_value <= 'b0;
    end else begin
        if (WR)
            diff_value <= IN_VALUE - delay_ram[addr_counter];
    end
end

always_comb OUT_VALUE <= diff_value;

/*
parameter RAM_WIDTH = <ram_width>;
   parameter RAM_ADDR_BITS = <ram_addr_bits>;

   (* ram_style="distributed" *)
   reg [RAM_WIDTH-1:0] <ram_name> [(2**RAM_ADDR_BITS)-1:0];

   wire [RAM_WIDTH-1:0] <output_data>;

   <reg_or_wire> [RAM_ADDR_BITS-1:0] <read_address>, <write_address>;
   <reg_or_wire> [RAM_WIDTH-1:0] <input_data>;

   always @(posedge <clock>)
      if (<write_enable>)
         <ram_name>[<write_address>] <= <input_data>;

   assign <output_data> = <ram_name>[<read_address>];
*/					

endmodule
