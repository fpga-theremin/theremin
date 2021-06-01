`timescale 1ns / 1ps


module phase_shift_ddr_tb();

localparam POSITION_BITS = 14;

// parallel data clock
logic CLK;
// serial (shift) clock, x4 times higher than CLK, phase aligned with CLK
logic CLK_X4;
// serial (shift) clock, x4 times higher than CLK, phase aligned with CLK, inverted
logic CLK_X4B;
logic RESET;
logic CE;

// serial input of reference signal
logic IN_REF;
// serial input of shifted signal
logic IN_SHIFTED;

// detected phase difference between shifted and ref signals, lower 5 bits are fractional part of CLK
logic signed [POSITION_BITS-1:0] PHASE_DIFFERENCE;

`ifdef DEBUG_PHASE_SHIFT_DDR
logic [7:0] debug_plus_bits;
logic [7:0] debug_minus_bits;
logic debug_state;
logic debug_changed;
logic [3:0] debug_plus_diff;
logic [3:0] debug_minus_diff;
`endif

phase_shift_ddr
#(.POSITION_BITS(POSITION_BITS)) 
phase_shift_ddr_inst (
    .*
);

logic signed [POSITION_BITS-1:0] last_diff;
always_ff @(posedge CLK) begin
    if (RESET) 
        last_diff <= 0;
    else begin
        if (last_diff != PHASE_DIFFERENCE) begin
            //$display("phase diff: %d", PHASE_DIFFERENCE);
            last_diff <= PHASE_DIFFERENCE;
        end 
    end
end

always_ff @(posedge IN_REF) begin
    $display("phase diff: %d", PHASE_DIFFERENCE);
end

always begin
    // 600MHz
    #0.84333 CLK_X4=0; CLK_X4B = 1;
    #0.84333 CLK_X4=1; CLK_X4B = 0; 
    #0.84333 CLK_X4=0; CLK_X4B = 1; 
    #0.84333 CLK_X4=1; CLK_X4B = 0; CLK = 0;
    #0.84333 CLK_X4=0; CLK_X4B = 1; 
    #0.84333 CLK_X4=1; CLK_X4B = 0; 
    #0.84333 CLK_X4=0; CLK_X4B = 1; 
    #0.84333 CLK_X4=1; CLK_X4B = 0; CLK = 1;
end

initial begin
    // reset, active 1
   CE = 0;
    #33 RESET = 1;
    
    #150 @(posedge CLK) RESET = 0;
    #15 @(posedge CLK) CE = 1;
end



always begin
    repeat (10) begin
        #83.33 IN_REF = 1;
        #87.33 IN_REF = 0;
    end
    repeat (35) begin
        #1.2
        #75.23 IN_REF = 1;
        #72.23 IN_REF = 0;
    end
    repeat (25) begin
        #45.23 IN_REF = 1;
        #48.23 IN_REF = 0;
    end
    repeat (25) begin
        #1.6
        #65.23 IN_REF = 1;
        #45.23 IN_REF = 0;
    end
    repeat (25) begin
        #55.23 IN_REF = 1;
        #85.23 IN_REF = 0;
    end
    repeat (25) begin
        #1.8
        #50.23 IN_REF = 1;
        #51.23 IN_REF = 0;
    end
    #100 $finish();
end

always begin
    repeat (10) begin
        #1.5
        #83.33 IN_SHIFTED = 1;
        #87.33 IN_SHIFTED = 0;
    end
    repeat (35) begin
        #75.23 IN_SHIFTED = 1;
        #72.23 IN_SHIFTED = 0;
    end
    repeat (25) begin
        #1.5
        #45.23 IN_SHIFTED = 1;
        #48.23 IN_SHIFTED = 0;
    end
    repeat (25) begin
        #65.23 IN_SHIFTED = 1;
        #45.23 IN_SHIFTED = 0;
    end
    repeat (25) begin
        #1.3
        #55.23 IN_SHIFTED = 1;
        #85.23 IN_SHIFTED = 0;
    end
    repeat (25) begin
        #50.23 IN_SHIFTED = 1;
        #51.23 IN_SHIFTED = 0;
    end
    #100 $finish();
end

endmodule
