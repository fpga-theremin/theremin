`timescale 1ns / 1ps
/*
    FPGA theremin project.
    (c) Vadim Lopatin, 2021
    
    smooth_oscillator is implementation of NCO - high precision periodic signal generator with target frequency filter and period value limits
    Output is sampled at CLK*8 (1200MHz), but period value has bigger precision (fractional part).
    Smoothing / dithering is used to simulate higher precision period.  
    
    Resources: 44 LUTs 40FFs for 10.20 precision
*/

//`define OSCILLATOR_DDR_DEBUG

module oscillator_ddr
#(
    parameter PERIOD_INT_PART = 10,
    parameter PERIOD_FRAC_PART = 20
)
(
    // parallel data clock
    input logic CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    input logic CLK_X4,
    input logic RESET,
    input logic CE,
    // period value in 150MHz serdes clock cycles (29..20 - int part, 19..0 - frac part)
    input logic [PERIOD_INT_PART+PERIOD_FRAC_PART-1:0] PERIOD_IN,
    // serial output
    output logic OUT
`ifdef OSCILLATOR_DDR_DEBUG
    , output logic [PERIOD_INT_PART+PERIOD_FRAC_PART:0] debug_phase
`endif

);

// oscillator halfperiod state
logic state;
// oserdes input buffer
logic [7:0] out_buf;
//hase value, one additional bit for sign
logic [PERIOD_INT_PART+PERIOD_FRAC_PART+1:0] phase;

// subtractor for int part of phase - subtracts one CLK cycle from phase
logic [PERIOD_INT_PART+PERIOD_FRAC_PART+1:0] phase_less_one_cycle;
always_comb phase_less_one_cycle <= { phase[PERIOD_INT_PART+PERIOD_FRAC_PART:PERIOD_FRAC_PART+1] - 1, phase[PERIOD_FRAC_PART:0] };

always_ff @(posedge CLK) begin
    if (RESET) begin
        phase <= 'b0;
        out_buf <= 'b0;
        state <= 'b0;
    end else if (CE) begin
        if (!phase[PERIOD_INT_PART+PERIOD_FRAC_PART]) begin
            // decrease phase by integer part cycles
            phase <= phase_less_one_cycle;
            state <= state;
            out_buf <= { 8{ state} };
        end else begin
            // half period bound reached
            phase <= phase_less_one_cycle + PERIOD_IN;
            state <= ~state;
            case (~phase[PERIOD_FRAC_PART:PERIOD_FRAC_PART-2])
                3'b000: out_buf <= {~state, state, state, state, state, state, state, state };
                3'b001: out_buf <= {~state,~state, state, state, state, state, state, state };
                3'b010: out_buf <= {~state,~state,~state, state, state, state, state, state };
                3'b011: out_buf <= {~state,~state,~state,~state, state, state, state, state };
                3'b100: out_buf <= {~state,~state,~state,~state,~state, state, state, state };
                3'b101: out_buf <= {~state,~state,~state,~state,~state,~state, state, state };
                3'b110: out_buf <= {~state,~state,~state,~state,~state,~state,~state, state };
                3'b111: out_buf <= {~state,~state,~state,~state,~state,~state,~state,~state };
            endcase
        end
    end
end


oserdes_ddr oserdes_ddr_inst (
    // parallel data clock
    .CLK,
    // serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
    .CLK_X4,
    .RESET,
    .CE,
    // parallel input
    .IN(out_buf),
    // serial output
    .OUT
);

`ifdef OSCILLATOR_DDR_DEBUG
    assign debug_phase = phase;
`endif


endmodule
