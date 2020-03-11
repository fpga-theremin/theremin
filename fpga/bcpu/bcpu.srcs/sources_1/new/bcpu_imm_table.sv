`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2020 10:37:12 AM
// Design Name: 
// Module Name: bxpu_imm_table
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     Immediate constants table implementation for support of replacing B operand register value with immediate constant.
//     Based on imm_mode, replace input from register with immediate constant from table.
//     imm_mode 00: pass b_value_in to output, except const_or_reg_index==000 (R0) which should be forced to 0
//
//     Useful constants:
//        single bit set
//        0 (using R0)
//        3,5,6,7,15,0xff, 0xff00, -1 (0xffff)
//
//     Resources used: 16 LUTs for 16 bits
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcpu_imm_table
#(
    parameter DATA_WIDTH = 16
)
(
    // input register value
    input [DATA_WIDTH - 1 : 0] B_VALUE_IN,
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    input [2:0] CONST_OR_REG_INDEX, 
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    input [1:0] IMM_MODE,
    
    output [DATA_WIDTH - 1 : 0] B_VALUE_OUT
);

logic [DATA_WIDTH-1:0] b_out;
assign B_VALUE_OUT = b_out;

genvar i;
generate
    if (DATA_WIDTH == 16) begin
        // imm_mode == 0: const_or_reg_index == 0 ? 0 : b_value_in

        // Immediate constants table:
        // imm_mode   const_or_reg_index      value
        //                                    == register value ==
        //   00              000              0000_0000_0000_0000   force 0 for R0
        //   00              001              B_VALUE_IN
        //   00              010              B_VALUE_IN
        //   00              011              B_VALUE_IN
        //   00              100              B_VALUE_IN
        //   00              101              B_VALUE_IN
        //   00              110              B_VALUE_IN
        //   00              111              B_VALUE_IN
        //                                    == misc constants ==
        //   01              000              1111_1111_1111_1111   -1 0xffff
        //   01              001              0000_0000_0000_0011   3
        //   01              010              0000_0000_0000_0101   5
        //   01              011              0000_0000_0000_0110   6
        //   01              100              0000_0000_0000_0111   7
        //   01              101              0000_0000_0000_1111   15
        //   01              110              0000_0000_1111_1111   0x00ff
        //   01              111              1111_1111_0000_0000   0xff00
        //                                    == single bit, part 1 ==
        //   10              000              0000_0000_0000_0001
        //   10              001              0000_0000_0000_0010
        //   10              010              0000_0000_0000_0100
        //   10              011              0000_0000_0000_1000
        //   10              100              0000_0000_0001_0000
        //   10              101              0000_0000_0010_0000
        //   10              110              0000_0000_0100_0000
        //   10              111              0000_0000_1000_0000
        //                                    == single bit, part 2 ==
        //   10              000              0000_0001_0000_0000
        //   10              001              0000_0010_0000_0000
        //   10              010              0000_0100_0000_0000
        //   10              011              0000_1000_0000_0000
        //   10              100              0001_0000_0000_0000
        //   10              101              0010_0000_0000_0000
        //   10              110              0100_0000_0000_0000
        //   10              111              1000_0000_0000_0000
        
        // IMM decode constants + B_IN/imm mux
        const logic [63:0] imm_const_table [DATA_WIDTH] = {
            //     single bit         consts   input=1       single bit        consts      input=0
            64'b0000_0000_0000_0001__0111_0111_1111_1110__0000_0000_0000_0001__0111_0111_0000_0000, // b_in[0]
            64'b0000_0000_0000_0010__0111_1011_1111_1110__0000_0000_0000_0010__0111_1011_0000_0000, // b_in[1]
            64'b0000_0000_0000_0100__0111_1101_1111_1110__0000_0000_0000_0100__0111_1101_0000_0000, // b_in[2]
            64'b0000_0000_0000_1000__0110_0001_1111_1110__0000_0000_0000_1000__0110_0001_0000_0000, // b_in[3]
                                             
            64'b0000_0000_0001_0000__0100_0001_1111_1110__0000_0000_0001_0000__0100_0001_0000_0000, // b_in[4]
            64'b0000_0000_0010_0000__0100_0001_1111_1110__0000_0000_0010_0000__0100_0001_0000_0000, // b_in[5]
            64'b0000_0000_0100_0000__0100_0001_1111_1110__0000_0000_0100_0000__0100_0001_0000_0000, // b_in[6]
            64'b0000_0000_1000_0000__0100_0001_1111_1110__0000_0000_1000_0000__0100_0001_0000_0000, // b_in[7]
                                             
            64'b0000_0001_0000_0000__1000_0001_1111_1110__0000_0001_0000_0000__1000_0001_0000_0000, // b_in[8]
            64'b0000_0010_0000_0000__1000_0001_1111_1110__0000_0010_0000_0000__1000_0001_0000_0000, // b_in[9]
            64'b0000_0100_0000_0000__1000_0001_1111_1110__0000_0100_0000_0000__1000_0001_0000_0000, // b_in[10]
            64'b0000_1000_0000_0000__1000_0001_1111_1110__0000_1000_0000_0000__1000_0001_0000_0000, // b_in[11]
                                                                                                  
            64'b0001_0000_0000_0000__1000_0001_1111_1110__0001_0000_0000_0000__1000_0001_0000_0000, // b_in[12]
            64'b0010_0000_0000_0000__1000_0001_1111_1110__0010_0000_0000_0000__1000_0001_0000_0000, // b_in[13]
            64'b0100_0000_0000_0000__1000_0001_1111_1110__0100_0000_0000_0000__1000_0001_0000_0000, // b_in[14]
            64'b1000_0000_0000_0000__1000_0001_1111_1110__1000_0000_0000_0000__1000_0001_0000_0000  // b_in[15]
        };
        // connect const table
        for (i = 0; i < DATA_WIDTH; i = i + 1)
            always_comb b_out[i] <= imm_const_table[i] [ {B_VALUE_IN[i], IMM_MODE, CONST_OR_REG_INDEX} ];
    end else begin
        $error("Unsupported data width %d", DATA_WIDTH);
    end

endgenerate

endmodule
