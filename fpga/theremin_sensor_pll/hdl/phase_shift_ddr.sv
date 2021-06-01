`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    phase_shift_ddr measures phase shift between two signals sampled with ISERDES (CLK*8)
    
    Resources: 63 LUTs + 2 ISERDES on Xilinx Series 7 devices.
*/

module phase_shift_ddr 
#(
    // precision (determines min frequency), lower 4 bits represent fractional part of CLK (150MHz), and the rest is number of CLK cycles between ref and shifted signal
    parameter POSITION_BITS = 14
)
(
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    input logic CLK_X4B,
    input logic RESET,
    input logic CE,
    
    // serial input of reference signal
    input logic IN_REF,
    // serial input of shifted signal
    input logic IN_SHIFTED,

    // detected phase difference between shifted and ref signals, lower 4 bits are fractional part of CLK
    output logic signed [POSITION_BITS-1:0] PHASE_DIFFERENCE

`ifdef DEBUG_PHASE_SHIFT_DDR
    , output logic [7:0] debug_plus_bits
    , output logic [7:0] debug_minus_bits
    , output logic debug_state
    , output logic debug_changed
    , output logic [3:0] debug_plus_diff
    , output logic [3:0] debug_minus_diff
`endif
);

// signal state, switches to 1 when both signals become 1, to 0 when both signals become 0 for whole 8 bits slice
logic state;

// reference signal deserialized into 8 bits
logic [7:0] parallel_ref;
// shifted signal deserialized into 8 bits
logic [7:0] parallel_shifted;

/*
state  ref    shift   delta     new_state
0      0       0       0        -
0      0       1      -1        -
0      1       0      +1        -
0      1       1       0        1 (if all 0)
1      0       0       0        0 (if all 1)
1      0       1      +1        -
1      1       0      -1        -
1      1       1       0        -
*/

logic [7:0] parallel_ref_xor_state;
logic [7:0] parallel_shifted_xor_state;

always_comb parallel_ref_xor_state <= parallel_ref ^ {8{state}};
always_comb parallel_shifted_xor_state <= parallel_shifted ^ {8{state}};

logic [7:0] plus_bits;
logic [7:0] minus_bits;

always_comb plus_bits <= parallel_ref_xor_state & ~parallel_shifted_xor_state;
always_comb minus_bits <= ~parallel_ref_xor_state & parallel_shifted_xor_state;

function logic[3:0] count_1_bits;
    input logic [7:0] bits;
    //count_1_bits = (((bits[0] + bits[1]) + (bits[2] + bits[3])) + ((bits[4] + bits[5]) + (bits[6] + bits[7])));
    count_1_bits = bits[0] + bits[1] + bits[2] + bits[3] + bits[4] + bits[5] + bits[6] + bits[7];
endfunction

logic [3:0] plus_diff;
logic [3:0] minus_diff;
always_comb plus_diff <= count_1_bits(plus_bits);
always_comb minus_diff <= count_1_bits(minus_bits);


// changed == 1 if both ref and shifted switched all bits to ~state
logic changed;
always_comb
    changed <= (~(|parallel_ref) & ~(|parallel_shifted) & state) |
               ((&parallel_ref) & (&parallel_shifted) & ~state); 

//logic [POSITION_BITS-1:0] acc;
logic [POSITION_BITS-1:0] current_shift;
logic [POSITION_BITS-1:0] prev_shift;
logic [POSITION_BITS-1:0] res;


always_ff @(posedge CLK) begin
    if (RESET) begin
        state <= 'b0;
        //acc <= 'b0;
        current_shift <= 'b0;
        prev_shift <= 'b0;
        res <= 'b0;
    end else if (CE) begin
        if (changed) begin
            state <= ~state;
            res <= current_shift + prev_shift;
            prev_shift <= current_shift;
            current_shift <= 'b0;
        end else begin
            current_shift <= current_shift + plus_diff - minus_diff;
        end
    end
end

assign PHASE_DIFFERENCE = res;

iserdes_ddr iserdes_ddr_ref (
    // parallel data clock
    .CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    .CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    .CLK_X4B,
    .RESET,
    .CE,
    // serial input
    .IN(IN_REF),
    // parallel output
    .OUT(parallel_ref)
);

iserdes_ddr iserdes_ddr_shifted (
    // parallel data clock
    .CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    .CLK_X4,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
    .CLK_X4B,
    .RESET,
    .CE,
    // serial input
    .IN(IN_SHIFTED),
    // parallel output
    .OUT(parallel_shifted)
);


`ifdef DEBUG_PHASE_SHIFT_DDR
assign debug_plus_bits = plus_bits;
assign debug_minus_bits = minus_bits;
assign debug_state = state;
assign debug_changed = changed;
assign debug_plus_diff = plus_diff;
assign debug_minus_diff = minus_diff;
`endif

endmodule
