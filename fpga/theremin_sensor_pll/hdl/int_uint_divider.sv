`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    int_uint_divider implements signed integer A by unsigned integer B divider.
    Top bit of result is sign, the rest - fractional part (requires abs(A) < B ).
    Result is delayed by RESULT_BITS CLK cycles.   
    
    Resources: 82 LUTs and 115 FFs for 30-bit input and 25 bit output on Xilinx platform.
*/
module int_uint_divider
#(
    parameter OPERAND_BITS = 30,
    parameter RESULT_BITS = 25
)
(
    input logic CLK,
    input logic RESET,
    input logic CE,
    // operand A
    input logic signed [OPERAND_BITS-1:0] A_IN,
    // operand B, A<B
    input logic [OPERAND_BITS-1:0] B_IN,
    // when 1, new operand will be accepted in current cycle
    output logic IN_READY,
    // when 1, new result is ready
    output logic RESULT_READY,
    // result of A_IN / B_IN delayed by RESULT_BITS cycles
    output logic signed [RESULT_BITS-1:0] DIV_RESULT
);


logic signed [OPERAND_BITS-1:0] a;
logic [OPERAND_BITS-1:0] b;

logic [OPERAND_BITS-1:0] diff;

always_comb diff <= a - b - a[OPERAND_BITS-1];

logic can_subtract;
always_comb can_subtract <= (diff[OPERAND_BITS-1] == a[OPERAND_BITS-1]);

logic new_result_bit;
always_comb new_result_bit <= can_subtract ^ a[OPERAND_BITS-1];

logic signed [OPERAND_BITS-1:0] new_a;
always_comb new_a <= (can_subtract ? (diff << 1) : (a << 1)); // | a[OPERAND_BITS-1];  

logic signed [RESULT_BITS-1:0] res;

logic [4:0] phase;

always_comb IN_READY <= (phase == 0);

always_ff @(posedge CLK) begin
    if (RESET) begin
        phase <= 0;
        res <= 0;
        a <= 0;
        b <= 0;
        DIV_RESULT <= 0;
        RESULT_READY <= 0;
    end else if (CE) begin
        if (phase == 0) begin
            phase <= RESULT_BITS - 1;
            a <= A_IN;
            b <= (B_IN ^ { OPERAND_BITS { A_IN[OPERAND_BITS-1] } }); // + A_IN[OPERAND_BITS-1];
            DIV_RESULT <= (res << 1) | new_result_bit;
            RESULT_READY <= 1'b1;
        end else begin
            phase <= phase - 1;
            a <= new_a;
            RESULT_READY <= 1'b0;
        end
        res <= (res << 1) | new_result_bit;
    end
end

endmodule
