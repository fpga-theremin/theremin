`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 15:19:16
// Design Name: 
// Module Name: clock_domain_adapter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Converts value from one clock domain to another.
//      Change is marked with toggling of IN_CHANGE / OUT_CHANGE value. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_domain_adapter
#(
    parameter VALUE_BITS = 16
)
(
    // reset, active 1
    input logic RESET,
    
    // toggled if IN_VALUE is changed (in CLK_IN clock domain, asynchronous to CLK_OUT)
    input logic IN_CHANGE,
    
    // input value, in CLK_IN clock domain, asynchronous to CLK_OUT
    input logic [VALUE_BITS - 1 : 0] IN_VALUE,

    // clock signal for outputs: outputs are being changed on raising edge of this clock 
    input logic CLK_OUT,

    // toggled if OUT_VALUE is changed (CLK_OUT clock posedge)
    output logic OUT_CHANGE,

    // output value, in CLK_OUT clock domain - changes with toggling of OUT_CHANGE  (CLK_OUT clock posedge)
    output logic [VALUE_BITS - 1 : 0] OUT_VALUE
);

logic in_change_clkout;
logic in_change_clkout_delay1;

always_ff @(posedge CLK_OUT) begin
    if (RESET) begin
        in_change_clkout <= 'b0;
        in_change_clkout_delay1 <= 'b0;
        OUT_CHANGE <= 'b0;
    end else begin
        if (in_change_clkout_delay1 != in_change_clkout)
            OUT_VALUE <= IN_VALUE;
        OUT_CHANGE <= in_change_clkout_delay1;
        in_change_clkout_delay1 <= in_change_clkout;
        in_change_clkout <= IN_CHANGE;
    end
end

endmodule
