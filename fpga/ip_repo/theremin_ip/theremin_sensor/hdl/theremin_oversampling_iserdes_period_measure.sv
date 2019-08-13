`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vadim Lopatin 
// 
// Create Date: 07/30/2019 11:03:32 AM
// Design Name: 
// Module Name: theremin_oversampling_iserdes_period_measure
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Theremin sensor frequency measure module.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module theremin_oversampling_iserdes_period_measure
#(
    parameter PITCH_PERIOD_BITS = 16,
    parameter VOLUME_PERIOD_BITS = 16,
    parameter DATA_BITS = 32,
    parameter FILTER_SHIFT_BITS = 8
)
(
    // 600MHz - ISERDESE2 DDR mode shift clock
    input logic CLK_SHIFT,
    // 600MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
    input logic CLK_SHIFTB,
    // 150MHz - ISERDESE2 parallel output clock - clock should be 1/4 of CLK_SHIFT, phase aligned 
    input logic CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    input logic CLK_DELAY,
    
    // main clock ~100MHz for measured value outputs
    input logic CLK,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    input logic RESET,

    // serial input of pitch signal
    input logic PITCH_FREQ_IN,
    // serial input of volume signal
    input logic VOLUME_FREQ_IN,
    
    // measured pitch period value - number of 1.2GHz*oversampling ticks since last change  (in CLK clock domain)
    //output logic [PITCH_PERIOD_BITS-1:0] PITCH_PERIOD_NOFILTER,
    // measured volume period value - number of 1.2GHz*oversampling ticks since last change (in CLK clock domain)
    //output logic [VOLUME_PERIOD_BITS-1:0] VOLUME_PERIOD_NOFILTER,

    // output value for channel A (in CLK clock domain)
    output logic [DATA_BITS-1:0] PITCH_PERIOD_FILTERED,
    // output value for channel B (in CLK clock domain)
    output logic [DATA_BITS-1:0] VOLUME_PERIOD_FILTERED

    //, output logic debug_pitch_change_flag
    //, output logic debug_volume_change_flag
    //, output logic debug_pitch_change_flag_sync
    //, output logic debug_volume_change_flag_sync
);

// reset / ce sequence for ISERDESE2
logic reset_sync;
logic ce_sync;
logic [2:0] ce_counter;
always_ff @(posedge CLK_PARALLEL) begin
    if (reset_sync) begin
        ce_counter <= 'b0;
        ce_sync <= 'b0;
    end else begin
        if (~ce_sync) begin
            if (ce_counter == 3'b111)
                ce_sync <= 1'b1;
            ce_counter <= ce_counter + 1;
        end
    end
    reset_sync <= RESET;
end

// IDELAYCTRL is required for using of IDELAYE2
(* IODELAY_GROUP="GROUP_FQM" *)
IDELAYCTRL delayctrl_instance (
    .REFCLK(CLK_DELAY),
    .RST(reset_sync),
    .RDY()
);

logic pitch_change_flag;
logic [PITCH_PERIOD_BITS-1:0] pitch_period;
//logic pitch_change_flag_sync;
//logic [PITCH_PERIOD_BITS-1:0] pitch_period_sync;

//clock_domain_adapter
//#(
//    .DATA_WIDTH(PITCH_PERIOD_BITS)
//) pitch_clock_domain_adapter_inst
//(
//    .CLK_IN(CLK_PARALLEL),
//    .CLK_OUT(CLK),

//    .RESET(reset_sync),
    
//    .CHANGE_FLAG_IN(pitch_change_flag),
//    .DATA_IN(pitch_period),
    
//    .CHANGE_FLAG_OUT(pitch_change_flag_sync),
//    .DATA_OUT(pitch_period_sync)
//);

oversampling_iserdes_period_measure
#(
    .PERIOD_BITS(PITCH_PERIOD_BITS)
) pitch_oversampling_iserdes_period_measure_inst
(
    // 600MHz - ISERDESE2 DDR mode shift clock
    .CLK_SHIFT,
    // 600MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
    .CLK_SHIFTB,
    // 150MHz - ISERDESE2 parallel output clock - clock should be 1/4 of CLK_SHIFT, phase aligned 
    .CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    .CLK_DELAY,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET(reset_sync),
    .CE(ce_sync),
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    //.CE(ce_sync),

    // serial input
    .FREQ_IN(PITCH_FREQ_IN),
    
    // change flag: 1 if value is changed
    .CHANGE_FLAG(pitch_change_flag),
    // measured period value - number of 1.2GHz*oversampling ticks since last change
    .PERIOD(pitch_period)
);

logic volume_change_flag;
logic [VOLUME_PERIOD_BITS-1:0] volume_period;

//logic volume_change_flag_sync;
//logic [VOLUME_PERIOD_BITS-1:0] volume_period_sync;
//clock_domain_adapter
//#(
//    .DATA_WIDTH(VOLUME_PERIOD_BITS)
//) volume_clock_domain_adapter_inst
//(
//    .CLK_IN(CLK_PARALLEL),
//    .CLK_OUT(CLK),

//    .RESET(reset_sync),
    
//    .CHANGE_FLAG_IN(volume_change_flag),
//    .DATA_IN(volume_period),
    
//    .CHANGE_FLAG_OUT(volume_change_flag_sync),
//    .DATA_OUT(volume_period_sync)
//);


oversampling_iserdes_period_measure
#(
    .PERIOD_BITS(VOLUME_PERIOD_BITS)
) volume_oversampling_iserdes_period_measure_inst
(
    // 600MHz - ISERDESE2 DDR mode shift clock
    .CLK_SHIFT,
    // 600MHz - ISERDESE2 DDR mode shift clock inverted (phase 180 relative to CLK_SHIFT) 
    .CLK_SHIFTB,
    // 150MHz - ISERDESE2 parallel output clock - clock should be 1/4 of CLK_SHIFT, phase aligned 
    .CLK_PARALLEL,

    // 200MHz input for driving IDELAYE2
    .CLK_DELAY,

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET(reset_sync),
    .CE(ce_sync),
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    //.CE(ce_sync),

    // serial input
    .FREQ_IN(VOLUME_FREQ_IN),
    
    // change flag: 1 if value is changed
    .CHANGE_FLAG(volume_change_flag),
    // measured period value - number of 1.2GHz*oversampling ticks since last change
    .PERIOD(volume_period)
);

//always_comb PITCH_PERIOD_NOFILTER <= pitch_period_sync;
//always_comb VOLUME_PERIOD_NOFILTER <= volume_period_sync;

// input value for channel A    
logic [DATA_BITS-1:0] filter_in_a;
// input value for channel B    
logic [DATA_BITS-1:0] filter_in_b;

//always_comb filter_in_a <= { pitch_period_sync, { (DATA_BITS - PITCH_PERIOD_BITS) {1'b0}} };
//always_comb filter_in_b <= { volume_period_sync, { (DATA_BITS - VOLUME_PERIOD_BITS) {1'b0}} };
always_comb filter_in_a <= { pitch_period, { (DATA_BITS - PITCH_PERIOD_BITS) {1'b0}} };
always_comb filter_in_b <= { volume_period, { (DATA_BITS - VOLUME_PERIOD_BITS) {1'b0}} };

// output value for channel A    
logic [DATA_BITS-1:0] filter_out_a;
// output value for channel B    
logic [DATA_BITS-1:0] filter_out_b;


//iir_filter_pow2_k
iir_multistage_dblchannel
#(
    .FILTER_K_SHIFT(FILTER_SHIFT_BITS),
    .DATA_BITS(DATA_BITS)
) iir_multistage_dblchannel_inst
//iir_filter_pow2_k_inst
(
    // input clock, ~100MHz
    .CLK(CLK_PARALLEL),
    // reset signal, active 1
    .RESET,
    
    // number of filter stages less one
    .MAX_STAGE(3),

    // input value for channel A    
    .IN_VALUE_A(filter_in_a),
    // input value for channel B    
    .IN_VALUE_B(filter_in_b),
    // output value for channel A    
    .OUT_VALUE_A(filter_out_a),
    // output value for channel B    
    .OUT_VALUE_B(filter_out_b)

);

always_comb PITCH_PERIOD_FILTERED <= filter_out_a;
always_comb VOLUME_PERIOD_FILTERED <= filter_out_b;


//always_comb debug_pitch_change_flag <= pitch_change_flag;
//always_comb debug_volume_change_flag <= volume_change_flag;
//always_comb debug_pitch_change_flag_sync <= pitch_change_flag_sync;
//always_comb debug_volume_change_flag_sync <= volume_change_flag_sync;

endmodule
