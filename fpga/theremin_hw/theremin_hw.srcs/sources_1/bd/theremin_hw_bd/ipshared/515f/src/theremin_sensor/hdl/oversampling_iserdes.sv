`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin
// 
// Create Date: 07/25/2019 10:03:39 AM
// Design Name: 
// Module Name: oversampling_iserdes
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

module oversampling_iserdes
(
    // 600MHz
    input logic CLK_SHIFT,
    // 600MHz inverted
    input logic CLK_SHIFTB,
    // 150MHz
    input logic CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    input logic CLK_DELAY,
    
    // reset, active 1, must be synchronous to CLK_PARALLEL !!!
    input logic RESET,
    input logic CE,
    
    // input frequency
    input logic FREQ_IN,

    // parallel oversampled deserialized output    
    output logic [63:0] PARALLEL_OUT
);

localparam DELAY_PER_CHANNEL = 1;

// reset / ce sequence for ISERDESE2
//logic reset_sync;
//logic ce_sync;
//logic [3:0] ce_counter;
//always_ff @(posedge CLK_PARALLEL) begin
//    if (reset_sync) begin
//        ce_counter <= 'b0;
//        ce_sync <= 'b0;
//    end else begin
//        if (~ce_sync) begin
//            if (ce_counter == 4'b1111)
//                ce_sync <= 1'b1;
//            ce_counter <= ce_counter + 1;
//        end
//    end
//    reset_sync <= RESET;
//end


//// IDELAYCTRL is required for using of IDELAYE2
//(* IODELAY_GROUP="GROUP_FQM" *)
//IDELAYCTRL delayctrl_instance (
//    .REFCLK(CLK_DELAY),
//    .RST(RESET),
//    .RDY()
//);


logic serial_in;

//BUFG serial_in_buf_inst ( .I(FREQ_IN), .O(serial_in) );
always_comb serial_in <= FREQ_IN; 

genvar i, j;
generate
    for (i = 0; i < 8; i = i + 1) begin
        logic [7:0] iserdes_out;
        
   
        iserdes_ddr
        #(
            .DELAY_VALUE(4 + DELAY_PER_CHANNEL*(7 - i))
        )
        iserdes_ddr_inst
        (
            // 800MHz
            .CLK_SHIFT,
            .CLK_SHIFTB,
            // 200MHz
            .CLK_PARALLEL,

            .CLK_DELAY,

            // reset, active 1
            .RESET,
            // count enable    
            .CE, //ce_sync),
            // serial input
            .IN(serial_in),
            // parallel output
            .OUT(iserdes_out)
        );
        
        for (j = 0; j < 8; j = j + 1) begin
            always_comb PARALLEL_OUT[i + j * 8] <= iserdes_out[j];
        end
    end
endgenerate

endmodule
