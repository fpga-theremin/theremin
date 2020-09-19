`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2019 02:06:18 PM
// Design Name: 
// Module Name: mux_debouncer_tb
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


module mux_debouncer_tb(

    );

localparam CLK_DIV_BITS = 5;
localparam DEBOUNCE_COUNTER_BITS = 10;
localparam MUX_ADDR_BITS = 4;

// clock, active posedge
logic CLK;
// reset, active 1
logic RESET;
// mux address for multiplexing N buttons into one MUX_OUT
logic [MUX_ADDR_BITS-1:0] MUX_ADDR;
// input value from mux
logic MUX_OUT;
// debounced output values
logic [(1<<MUX_ADDR_BITS) - 1:0] DEBOUNCED;
// change flags
logic [(1<<MUX_ADDR_BITS) - 1:0] CHANGE_FLAGS;
// 1 for one clock cycle after DEBOUNCED is updated
logic UPDATED;

//logic [DEBOUNCE_COUNTER_BITS-1:0] debug_new_counter;
//logic [DEBOUNCE_COUNTER_BITS-1:0] debug_old_counter;
//logic debug_old_state;
//logic debug_new_state;
//logic debug_mux_out;

logic [(1<<MUX_ADDR_BITS) - 1:0] button_inputs;
always_comb MUX_OUT = button_inputs[MUX_ADDR];
    

mux_debouncer
mux_debouncer_instance
(
    .*
);

initial begin
    #10 RESET = 1;
    #100 RESET = 0;
    button_inputs = 'b0;
    #1000000000 $finish();
end

int clock_counter = 0;
always begin
    #5 CLK = 1;
    #5 CLK = 0;
    clock_counter = clock_counter + 1;
end

always @(posedge UPDATED)
    @(posedge CLK) #2 $display("%f updated", clock_counter / 100000.0);

always @(posedge CLK) begin
    if (UPDATED && CHANGE_FLAGS != 0) begin
        automatic int i = 0;
        for (i = 0; i < 16; i = i + 1) begin
            if (CHANGE_FLAGS[i])
                $display("[%f] %d is changed to %d", clock_counter / 100000.0, i, DEBOUNCED[i]);
        end
    end
end

always begin
    automatic int i = 0;
    #321ms ;
    #123 button_inputs[i] = ~button_inputs[i];
    #323 button_inputs[i] = ~button_inputs[i];
    #33 button_inputs[i] = ~button_inputs[i];
    #533 button_inputs[i] = ~button_inputs[i];
    #1533 button_inputs[i] = ~button_inputs[i];
    #15 button_inputs[i] = ~button_inputs[i];
    #159 button_inputs[i] = ~button_inputs[i];
    
    #456ms ;

    #4433 button_inputs[i] = ~button_inputs[i];
    #22237 button_inputs[i] = ~button_inputs[i];
    #41233 button_inputs[i] = ~button_inputs[i];
    #1876 button_inputs[i] = ~button_inputs[i];
    #2933 button_inputs[i] = ~button_inputs[i];
    #495 button_inputs[i] = ~button_inputs[i];
    #9333 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 1;
    #121ms ;
    #4332 button_inputs[i] = ~button_inputs[i];
    #1723 button_inputs[i] = ~button_inputs[i];
    #2543 button_inputs[i] = ~button_inputs[i];
    #7565 button_inputs[i] = ~button_inputs[i];
    #12533 button_inputs[i] = ~button_inputs[i];
    #4535 button_inputs[i] = ~button_inputs[i];
    #1559 button_inputs[i] = ~button_inputs[i];
    
    #215ms ;
    
    #43433 button_inputs[i] = ~button_inputs[i];
    #2337 button_inputs[i] = ~button_inputs[i];
    #12233 button_inputs[i] = ~button_inputs[i];
    #8716 button_inputs[i] = ~button_inputs[i];
    #9233 button_inputs[i] = ~button_inputs[i];
    #1945 button_inputs[i] = ~button_inputs[i];
    #333 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 2;
    #55ms ;
    #12323 button_inputs[i] = ~button_inputs[i];
    #334723 button_inputs[i] = ~button_inputs[i];
    #9463 button_inputs[i] = ~button_inputs[i];
    #8233 button_inputs[i] = ~button_inputs[i];
    #7533 button_inputs[i] = ~button_inputs[i];
    #1565 button_inputs[i] = ~button_inputs[i];
    #8759 button_inputs[i] = ~button_inputs[i];
    
    #96ms ;

    #94433 button_inputs[i] = ~button_inputs[i];
    #8137 button_inputs[i] = ~button_inputs[i];
    #6233 button_inputs[i] = ~button_inputs[i];
    #5376 button_inputs[i] = ~button_inputs[i];
    #4233 button_inputs[i] = ~button_inputs[i];
    #3475 button_inputs[i] = ~button_inputs[i];
    #333 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 3;
    #78ms ;
    #323 button_inputs[i] = ~button_inputs[i];
    #723 button_inputs[i] = ~button_inputs[i];
    #93 button_inputs[i] = ~button_inputs[i];
    #833 button_inputs[i] = ~button_inputs[i];
    #7533 button_inputs[i] = ~button_inputs[i];
    #65 button_inputs[i] = ~button_inputs[i];
    #59 button_inputs[i] = ~button_inputs[i];
    
    #159ms ;

    #933 button_inputs[i] = ~button_inputs[i];
    #837 button_inputs[i] = ~button_inputs[i];
    #6233 button_inputs[i] = ~button_inputs[i];
    #576 button_inputs[i] = ~button_inputs[i];
    #433 button_inputs[i] = ~button_inputs[i];
    #75 button_inputs[i] = ~button_inputs[i];
    #333 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 4;
    #33ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #3723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #165 button_inputs[i] = ~button_inputs[i];
    #259 button_inputs[i] = ~button_inputs[i];
    
    #44ms ;

    #51933 button_inputs[i] = ~button_inputs[i];
    #31837 button_inputs[i] = ~button_inputs[i];
    #23233 button_inputs[i] = ~button_inputs[i];
    #1576 button_inputs[i] = ~button_inputs[i];
    #2433 button_inputs[i] = ~button_inputs[i];
    #43375 button_inputs[i] = ~button_inputs[i];
    #4333 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 5;
    #55ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #3723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #12165 button_inputs[i] = ~button_inputs[i];
    #259 button_inputs[i] = ~button_inputs[i];
    #3723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #165 button_inputs[i] = ~button_inputs[i];
    #259 button_inputs[i] = ~button_inputs[i];
    
    #66ms ;

    #2933 button_inputs[i] = ~button_inputs[i];
    #2837 button_inputs[i] = ~button_inputs[i];
    #233 button_inputs[i] = ~button_inputs[i];
    #1576 button_inputs[i] = ~button_inputs[i];
    #2433 button_inputs[i] = ~button_inputs[i];
    #3315 button_inputs[i] = ~button_inputs[i];
    #4433 button_inputs[i] = ~button_inputs[i];
end

always begin
    automatic int i = 6;
    #77ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #31723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #7165 button_inputs[i] = ~button_inputs[i];
    #6259 button_inputs[i] = ~button_inputs[i];
    
    #88ms ;

    #23193 button_inputs[i] = ~button_inputs[i];
    #23287 button_inputs[i] = ~button_inputs[i];
    #42333 button_inputs[i] = ~button_inputs[i];
    #4576 button_inputs[i] = ~button_inputs[i];
    #31433 button_inputs[i] = ~button_inputs[i];
    #31315 button_inputs[i] = ~button_inputs[i];
    #51433 button_inputs[i] = ~button_inputs[i];
end


endmodule
