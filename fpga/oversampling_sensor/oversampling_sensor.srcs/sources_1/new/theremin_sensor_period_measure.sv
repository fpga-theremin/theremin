`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 16:12:07
// Design Name: 
// Module Name: theremin_sensor_period_measure
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


module theremin_sensor_period_measure
#(
    // CLK_PARALLEL should have this frequency for proper calculation of counter sizes
    parameter ISERDES_FREQUENCY_MHZ = 150.0,

    // minimum supported pitch oscillator frequency (with lower frequencies, there will be counter overflow)
    parameter PITCH_MIN_FREQUENCY_MHZ = 0.6,
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    parameter PITCH_OVERSAMPLING = 3,
    // first stage filter for pitch axis: delay in half cycles (two edges per oscillator cycle)
    parameter PITCH_DELAY_HALFCYCLES = 512,

    // minimum supported pitch oscillator frequency (with lower frequencies, there will be counter overflow)
    parameter VOLUME_MIN_FREQUENCY_MHZ = 0.6,
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    parameter VOLUME_OVERSAMPLING = 1,
    // first stage filter for volume axis: delay in half cycles (two edges per oscillator cycle)
    parameter VOLUME_DELAY_HALFCYCLES = 512,

    // CLK_DELAY frequency value: reference frequency for delay line, in MHz
    parameter DELAY_REFCLOCK_FREQUENCY=200.0

)
(

    // oversampling sensor signals

    // ISERDES clocks: max value depends on speed grade, 600MHz is max for low speed grades
    // CLK_SHIFT, CLK_SHIFTB, CLK_PARALLEL should be phase aligned (use the same PLL)
    // ~600MHz
    input logic CLK_SHIFT,
    // ~600MHz, phase inverted CLK_SHIFT 
    input logic CLK_SHIFTB,
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    input logic CLK_PARALLEL,

    // ~200MHz clock for delay lines calibration (must match DELAY_REFCLOCK_FREQUENCY value)
    input logic CLK_DELAY,

    // reset, active 1
    input logic RESET,

    // bus clock : 100 .. 200 MHz value processing clock: all outputs will be synchronous with this clock 
    input logic CLK,

    // pitch oscillator signal
    input logic PITCH_OSC_IN,

    // volume oscillator signal
    input logic VOLUME_OSC_IN,

    // pitch pulse position (in lower bits), bit 31 is toggled after each value
    output logic [31:0] PITCH_PULSE_POSITION_OUT,
    // volume pulse position (in lower bits), bit 31 is toggled after each value
    output logic [31:0] VOLUME_PULSE_POSITION_OUT,

    // pitch period value from stage1 - delay diff filter (in lower bits), bit 31 is toggled after each new value
    output logic [31:0] PITCH_PERIOD_STAGE1_OUT,
    // volume period value from stage1 - delay diff filter (in lower bits), bit 31 is toggled after each new value
    output logic [31:0] VOLUME_PERIOD_STAGE1_OUT,
    
    // measured pitch period from stage2 IIR filter
    output logic [31:0] PITCH_PERIOD_OUT,
    // measured volume period from stage2 IIR filter
    output logic [31:0] VOLUME_PERIOD_OUT
);

localparam PITCH_COUNTER_MAX_VALUE = ISERDES_FREQUENCY_MHZ / PITCH_MIN_FREQUENCY_MHZ;
// number of bits in timer cycle counter (8 bits for 150MHz->0.6MHz min osc freq, 7 bits for 150->1.2MHz min osc freq)
localparam PITCH_COUNTER_BITS = PITCH_COUNTER_MAX_VALUE < 32 ? 5
                              : PITCH_COUNTER_MAX_VALUE < 64 ? 6
                              : PITCH_COUNTER_MAX_VALUE < 128 ? 7
                              : PITCH_COUNTER_MAX_VALUE < 256 ? 8
                              : PITCH_COUNTER_MAX_VALUE < 512 ? 9
                              :                                 10;

localparam VOLUME_COUNTER_MAX_VALUE = ISERDES_FREQUENCY_MHZ / VOLUME_MIN_FREQUENCY_MHZ;
// number of bits in timer cycle counter (8 bits for 150MHz->0.6MHz min osc freq, 7 bits for 150->1.2MHz min osc freq)
localparam VOLUME_COUNTER_BITS = VOLUME_COUNTER_MAX_VALUE < 32 ? 5
                              : VOLUME_COUNTER_MAX_VALUE < 64 ? 6
                              : VOLUME_COUNTER_MAX_VALUE < 128 ? 7
                              : VOLUME_COUNTER_MAX_VALUE < 256 ? 8
                              : VOLUME_COUNTER_MAX_VALUE < 512 ? 9
                              :                                 10;

// delay buffer address bits: filter will calculate diff with value delayed by 2**DELAY_ADDR_BITS WR cycles
localparam PITCH_DELAY_ADDR_BITS = (PITCH_DELAY_HALFCYCLES <= 4) ? 2
                                   : (PITCH_DELAY_HALFCYCLES <= 8) ? 3
                                   : (PITCH_DELAY_HALFCYCLES <= 16) ? 4
                                   : (PITCH_DELAY_HALFCYCLES <= 32) ? 5
                                   : (PITCH_DELAY_HALFCYCLES <= 64) ? 6
                                   : (PITCH_DELAY_HALFCYCLES <= 128) ? 7
                                   : (PITCH_DELAY_HALFCYCLES <= 256) ? 8
                                   : (PITCH_DELAY_HALFCYCLES <= 512) ? 9
                                   : (PITCH_DELAY_HALFCYCLES <= 1024) ? 10
                                   : (PITCH_DELAY_HALFCYCLES <= 2048) ? 11
                                   : (PITCH_DELAY_HALFCYCLES <= 4096) ? 12
                                   :                                    13;

// delay buffer address bits: filter will calculate diff with value delayed by 2**DELAY_ADDR_BITS WR cycles
localparam VOLUME_DELAY_ADDR_BITS = (VOLUME_DELAY_HALFCYCLES <= 4) ? 2
                                   : (VOLUME_DELAY_HALFCYCLES <= 8) ? 3
                                   : (VOLUME_DELAY_HALFCYCLES <= 16) ? 4
                                   : (VOLUME_DELAY_HALFCYCLES <= 32) ? 5
                                   : (VOLUME_DELAY_HALFCYCLES <= 64) ? 6
                                   : (VOLUME_DELAY_HALFCYCLES <= 128) ? 7
                                   : (VOLUME_DELAY_HALFCYCLES <= 256) ? 8
                                   : (VOLUME_DELAY_HALFCYCLES <= 512) ? 9
                                   : (VOLUME_DELAY_HALFCYCLES <= 1024) ? 10
                                   : (VOLUME_DELAY_HALFCYCLES <= 2048) ? 11
                                   : (VOLUME_DELAY_HALFCYCLES <= 4096) ? 12
                                   :                                    13;


logic reset_sync;
logic reset_sync_delay1;
logic reset_sync_delay2;
logic ce_sync;

// reset and ce signals for ISERDES: reset must be synchronous, CE should be enabled with delay after end of reset
always_ff @(CLK_PARALLEL) begin
    if (RESET) begin
        reset_sync <= 'b1;
        reset_sync_delay1 <= 'b1;
        reset_sync_delay2 <= 'b1;
        ce_sync <= 'b0;
    end else begin
        reset_sync_delay2 <= reset_sync_delay1;
        reset_sync_delay1 <= reset_sync;
        reset_sync <= 'b0;
        ce_sync <= ~(reset_sync | reset_sync_delay1 | reset_sync_delay2);
    end
end


// IDELAYCTRL is required for using of IDELAYE2
(* IODELAY_GROUP="GROUP_FQM" *)
IDELAYCTRL delayctrl_instance (
    .REFCLK(CLK_DELAY),
    .RST(reset_sync),
    .RDY()
);


localparam PITCH_EDGE_POSITION_BITS = 3 + PITCH_OVERSAMPLING + PITCH_COUNTER_BITS + PITCH_DELAY_ADDR_BITS;
localparam VOLUME_EDGE_POSITION_BITS = 3 + VOLUME_OVERSAMPLING + VOLUME_COUNTER_BITS + VOLUME_DELAY_ADDR_BITS;

logic pitch_edge;
logic [PITCH_EDGE_POSITION_BITS - 1 : 0] pitch_edge_position;
logic volume_edge;
logic [VOLUME_EDGE_POSITION_BITS - 1 : 0] volume_edge_position;

oversampling_edge_detector
#(
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    .OVERSAMPLING(PITCH_OVERSAMPLING),
    // reference frequency for delay line, in MHz
    .DELAY_REFCLOCK_FREQUENCY(DELAY_REFCLOCK_FREQUENCY),
    // number of bits in timer cycle counter (8 bits for 150MHz->1MHz, 6 bits for max filter stage1 delay)
    .COUNTER_BITS(PITCH_COUNTER_BITS)
)
pitch_oversampling_edge_detector_inst
(
    // ~600MHz
    .CLK_SHIFT,
    // ~600MHz, phase inverted CLK_SHIFT 
    .CLK_SHIFTB,
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    .CLK(CLK_PARALLEL),

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET(reset_sync),
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    .CE(ce_sync),

    // serial input
    .IN(PITCH_OSC_IN),
    
    // 1 for one cycle if state is changed
    .CHANGE_FLAG(),

    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(pitch_edge),
    
    // counter value for edge    
    .EDGE_POSITION(pitch_edge_position)
);



oversampling_edge_detector
#(
    // oversampling bits, 0=no delay based oversampling, 1=combine 2 iserdes, 2=combine 4 iserdes, 3=combine 8 iserdes
    .OVERSAMPLING(VOLUME_OVERSAMPLING),
    // reference frequency for delay line, in MHz
    .DELAY_REFCLOCK_FREQUENCY(DELAY_REFCLOCK_FREQUENCY),
    // number of bits in timer cycle counter (8 bits for 150MHz->1MHz, 6 bits for max filter stage1 delay)
    .COUNTER_BITS(VOLUME_COUNTER_BITS)
)
volume_oversampling_edge_detector_inst
(
    // ~600MHz
    .CLK_SHIFT,
    // ~600MHz, phase inverted CLK_SHIFT 
    .CLK_SHIFTB,
    // ~150MHz, must be phase aligned CLK_SHIFT/4 
    .CLK(CLK_PARALLEL),

    // reset, active 1, must be synchronous to CLK_SHIFT !!!
    .RESET(reset_sync),
    // counter enable, active 1, keep inactive for 4 CLK_SHIFT cycles adter RESET deassertion
    // must be synchronous to CLK_SHIFT !!!
    .CE(ce_sync),

    // serial input
    .IN(VOLUME_OSC_IN),
    
    // 1 for one cycle if state is changed
    .CHANGE_FLAG(),

    // 1 if change is raising edge, 0 if falling edge
    .CHANGE_EDGE(volume_edge),
    
    // counter value for edge    
    .EDGE_POSITION(volume_edge_position)
);

localparam PITCH_PULSE_POSITION_BITS = PITCH_EDGE_POSITION_BITS;
localparam VOLUME_PULSE_POSITION_BITS = VOLUME_EDGE_POSITION_BITS;

logic pitch_pulse_type;
logic pitch_pulse_position_changed;
logic [PITCH_PULSE_POSITION_BITS - 1 : 0] pitch_pulse_position;
logic volume_pulse_type;
logic volume_pulse_position_changed;
logic [VOLUME_PULSE_POSITION_BITS - 1 : 0] volume_pulse_position;

// pitch pulse position (in lower bits), bit 31 is toggled after each value
always_comb PITCH_PULSE_POSITION_OUT <= { pitch_pulse_type, {(32-1-PITCH_PULSE_POSITION_BITS){1'b0}}, pitch_pulse_position };
// volume pulse position (in lower bits), bit 31 is toggled after each value
always_comb VOLUME_PULSE_POSITION_OUT <= { volume_pulse_type, {(32-1-VOLUME_PULSE_POSITION_BITS){1'b0}}, volume_pulse_position };

// toggled on each output change
logic pitch_period_stage1_change;
// pitch period from stage1 (diff between last pitch pulse position and one delayed by PITCH_DELAY_HALFCYCLES)
logic [PITCH_PULSE_POSITION_BITS - 1 : 0] pitch_period_stage1;
// toggled on each output change
logic volume_period_stage1_change;
// volume period from stage1 (diff between last volume pulse position and one delayed by VOLUME_DELAY_HALFCYCLES)
logic [VOLUME_PULSE_POSITION_BITS - 1 : 0] volume_period_stage1;

// pitch period value from stage1 - delay diff filter (in lower bits), bit 31 is toggled after each new value
always_comb PITCH_PERIOD_STAGE1_OUT <= { pitch_period_stage1_change, {(32-1-PITCH_PULSE_POSITION_BITS){1'b0}}, pitch_period_stage1 };
// volume period value from stage1 - delay diff filter (in lower bits), bit 31 is toggled after each new value
always_comb VOLUME_PERIOD_STAGE1_OUT <= { volume_period_stage1_change, {(32-1-VOLUME_PULSE_POSITION_BITS){1'b0}}, volume_period_stage1 };

edge_to_pulse_position
#(
    .EDGE_POSITION_BITS(PITCH_EDGE_POSITION_BITS)
)
pitch_edge_to_pulse_position_inst
(
    // clock signal, outputs are being changed on raising edge of this clock
    // input signals can be clocked by another clock - clock domain conversion will be made 
    .CLK_OUT(CLK),

    // reset, active 1
    .RESET(RESET),

    // 1: raising edge, 0: falling edge -- toggled when new edge is detected
    .EDGE_TYPE(pitch_edge),
    // edge position value
    .EDGE_POSITION(pitch_edge_position),
    
    // 1: high (1) value, 0: low (0) value
    .PULSE_TYPE(pitch_pulse_type),
    // 1 for one CLK_OUT cycle when new value is ready
    .CHANGED(pitch_pulse_position_changed),
    // pulse position -- middle point between last falling and raising edges ((raising + falling) / 2) << 1
    .PULSE_POSITION(pitch_pulse_position)
);

edge_to_pulse_position
#(
    .EDGE_POSITION_BITS(PITCH_EDGE_POSITION_BITS)
)
volume_edge_to_pulse_position_inst
(
    // clock signal, outputs are being changed on raising edge of this clock
    // input signals can be clocked by another clock - clock domain conversion will be made 
    .CLK_OUT(CLK),

    // reset, active 1
    .RESET(RESET),

    // 1: raising edge, 0: falling edge -- toggled when new edge is detected
    .EDGE_TYPE(volume_edge),
    // edge position value
    .EDGE_POSITION(volume_edge_position),
    
    // 1: high (1) value, 0: low (0) value
    .PULSE_TYPE(volume_pulse_type),
    // 1 for one CLK_OUT cycle when new value is ready
    .CHANGED(volume_pulse_position_changed),
    // pulse position -- middle point between last falling and raising edges ((raising + falling) / 2) << 1
    .PULSE_POSITION(volume_pulse_position)
);


localparam BRAM_ADDR_BITS_THRESHOLD = 7;

delay_diff_filter
#(
    // filter will calculate diff with value delayed by DELAY_CYCLES WR cycles, power of two is recommended
    .DELAY_CYCLES(PITCH_DELAY_HALFCYCLES),
    // number of bits in value (the bigger is delay, the more bits in value is needed: one addr bit == +1 value bit)
    .VALUE_BITS(PITCH_PULSE_POSITION_BITS),
    // use BRAM for delays with log2(DELAY_CYCLE) >= BRAM_ADDR_BITS_THRESHOLD
    .BRAM_ADDR_BITS_THRESHOLD(BRAM_ADDR_BITS_THRESHOLD)
)
pitch_delay_diff_filter_inst
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    .CLK,

    // reset, active 1
    .RESET,

    // input value for filter
    .IN_VALUE(pitch_pulse_position),

    // set to 1 for one clock cycle to push new value
    .WR(pitch_pulse_position_changed),
    
    // toggling each time we have new value on output
    .CHANGED(pitch_period_stage1_change),
    // filter output (IN_VALUE - delay(IN_VALUE, 2**DELAY_ADDR_BITS)), updated one cycle after WR
    // delay is counted as number of input values (WR==1 count)
    .OUT_DIFF(pitch_period_stage1)
);

delay_diff_filter
#(
    // filter will calculate diff with value delayed by DELAY_CYCLES WR cycles, power of two is recommended
    .DELAY_CYCLES(VOLUME_DELAY_HALFCYCLES),
    // number of bits in value (the bigger is delay, the more bits in value is needed: one addr bit == +1 value bit)
    .VALUE_BITS(VOLUME_PULSE_POSITION_BITS),
    // use BRAM for delays with log2(DELAY_CYCLE) >= BRAM_ADDR_BITS_THRESHOLD
    .BRAM_ADDR_BITS_THRESHOLD(BRAM_ADDR_BITS_THRESHOLD)
)
volume_delay_diff_filter_inst
(
    // clock signal, inputs and outputs are being changed on raising edge of this clock 
    .CLK,

    // reset, active 1
    .RESET,

    // input value for filter
    .IN_VALUE(volume_pulse_position),

    // set to 1 for one clock cycle to push new value
    .WR(volume_pulse_position_changed),
    
    // toggling each time we have new value on output
    .CHANGED(volume_period_stage1_change),
    // filter output (IN_VALUE - delay(IN_VALUE, 2**DELAY_ADDR_BITS)), updated one cycle after WR
    // delay is counted as number of input values (WR==1 count)
    .OUT_DIFF(volume_period_stage1)
);


endmodule
