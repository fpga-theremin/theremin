`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2019 12:22:32 PM
// Design Name: 
// Module Name: encoders_board_tb
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


module encoders_board_tb(

    );
    
    
// clock, active posedge
logic CLK;
// reset, active 1
logic RESET;
// mux address for multiplexing N buttons into one MUX_OUT
logic [3:0] MUX_ADDR;
// input value from mux
logic MUX_OUT;

// simulate multiplexer    
logic [15:0] button_inputs;
assign MUX_OUT = button_inputs[MUX_ADDR];

// exposing processed state as controller registers

// packed state of encoders 0, 1
// [31]    encoder1 button state
// [30:24] encoder1 button state duration
// [23:20] encoder1 pressed state position
// [19:16] encoder1 normal state position
// [15]    encoder0 button state
// [14:8]  encoder0 button state duration
// [7:4]   encoder0 pressed state position
// [3:0]   encoder0 normal state position
logic[31:0] R0;
// packed state of encoders 2, 3
// [31]    encoder3 button state
// [30:24] encoder3 button state duration
// [23:20] encoder3 pressed state position
// [19:16] encoder3 normal state position
// [15]    encoder2 button state
// [14:8]  encoder2 button state duration
// [7:4]   encoder2 pressed state position
// [3:0]   encoder2 normal state position
logic[31:0] R1;
// packed state of encoder 4, button and last change counter
// [31]    button state
// [30:24] button state duration
// [23:16] duration (in 100ms intervals) since last change of any control
// [15]    encoder4 button state
// [14:8]  encoder4 button state duration
// [7:4]   encoder4 pressed state position
// [3:0]   encoder4 normal state position
logic[31:0] R2;
    
encoders_board encoders_board_instance (
    .*
);
    
initial begin
    #10 RESET = 1;
    #100 RESET = 0;
    button_inputs = 'b0;
    #10s $finish();
end

int clock_counter = 0;
always begin
    #5 CLK = 1;
    #5 CLK = 0;
    clock_counter = clock_counter + 1;
end

always begin
    #30ms @(posedge CLK) #2 $display("%f: R0=%h R1=%h R2=%h", clock_counter/100000.0, R0, R1, R2);    
end

// encoder 0
always begin
    automatic int enc = 0;
    automatic int i = 0;
    $display("** enc0 cycle");
    repeat (3) begin
        
        i = enc*3 + 0;
    
        #332ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #645ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (6) begin
        
        i = enc*3 + 1;
    
        #232ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #345ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    // change button state
    i = enc*3 + 2;
    button_inputs[i] = ~button_inputs[i];
    #120ms ;

    repeat (2) begin
        
        i = enc*3 + 0;
    
        #32ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #246ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (3) begin
        
        i = enc*3 + 1;
    
        #362ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #255ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

end

// encoder 2
always begin
    automatic int enc = 2;
    automatic int i = 0;
    $display("** enc2 cycle");
    repeat (6) begin
        
        i = enc*3 + 0;
    
        #56ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #66ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (3) begin
        
        i = enc*3 + 1;
    
        #172ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #256ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    // change button state
    i = enc*3 + 2;
    button_inputs[i] = ~button_inputs[i];
    #220ms ;

    repeat (5) begin
        
        i = enc*3 + 0;
    
        #32ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #87ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (2) begin
        
        i = enc*3 + 1;
    
        #44ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #55ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

end



// encoder 3
always begin
    automatic int enc = 3;
    automatic int i = 0;
    $display("** enc3 cycle");
    repeat (2) begin
        
        i = enc*3 + 0;
    
        #156ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #66ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (5) begin
        
        i = enc*3 + 1;
    
        #72ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #33333 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #256ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    // change button state
    i = enc*3 + 2;
    button_inputs[i] = ~button_inputs[i];
    #220ms ;

    repeat (5) begin
        
        i = enc*3 + 0;
    
        #52ms ;
        #6123 button_inputs[i] = ~button_inputs[i];
        #7323 button_inputs[i] = ~button_inputs[i];
        #33 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #9915 button_inputs[i] = ~button_inputs[i];
        #8159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 1;
        
        #87ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #1876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

    repeat (2) begin
        
        i = enc*3 + 1;
    
        #94ms ;
        #123 button_inputs[i] = ~button_inputs[i];
        #323 button_inputs[i] = ~button_inputs[i];
        #5433 button_inputs[i] = ~button_inputs[i];
        #533 button_inputs[i] = ~button_inputs[i];
        #1533 button_inputs[i] = ~button_inputs[i];
        #15 button_inputs[i] = ~button_inputs[i];
        #159 button_inputs[i] = ~button_inputs[i];

        i = enc*3 + 0;
        
        #85ms ;
    
        #4433 button_inputs[i] = ~button_inputs[i];
        #22237 button_inputs[i] = ~button_inputs[i];
        #41233 button_inputs[i] = ~button_inputs[i];
        #31876 button_inputs[i] = ~button_inputs[i];
        #2933 button_inputs[i] = ~button_inputs[i];
        #495 button_inputs[i] = ~button_inputs[i];
        #9333 button_inputs[i] = ~button_inputs[i];
    end

end


// button of enc1
always begin
    automatic int i = 5;
    #177ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #31723 button_inputs[i] = ~button_inputs[i];
    #1593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #22533 button_inputs[i] = ~button_inputs[i];
    #7165 button_inputs[i] = ~button_inputs[i];
    #6259 button_inputs[i] = ~button_inputs[i];
    
    #95ms ;

    #23193 button_inputs[i] = ~button_inputs[i];
    #23287 button_inputs[i] = ~button_inputs[i];
    #42333 button_inputs[i] = ~button_inputs[i];
    #4576 button_inputs[i] = ~button_inputs[i];
    #31433 button_inputs[i] = ~button_inputs[i];
    #31315 button_inputs[i] = ~button_inputs[i];
    #51433 button_inputs[i] = ~button_inputs[i];
end


// button of enc4
always begin
    automatic int i = 14;
    #477ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #31723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #7165 button_inputs[i] = ~button_inputs[i];
    #6259 button_inputs[i] = ~button_inputs[i];
    
    #388ms ;

    #23193 button_inputs[i] = ~button_inputs[i];
    #23287 button_inputs[i] = ~button_inputs[i];
    #42333 button_inputs[i] = ~button_inputs[i];
    #4576 button_inputs[i] = ~button_inputs[i];
    #31433 button_inputs[i] = ~button_inputs[i];
    #31315 button_inputs[i] = ~button_inputs[i];
    #51433 button_inputs[i] = ~button_inputs[i];
end


always begin
    automatic int i = 15;
    #577ms ;
    #1323 button_inputs[i] = ~button_inputs[i];
    #31723 button_inputs[i] = ~button_inputs[i];
    #593 button_inputs[i] = ~button_inputs[i];
    #4833 button_inputs[i] = ~button_inputs[i];
    #2533 button_inputs[i] = ~button_inputs[i];
    #7165 button_inputs[i] = ~button_inputs[i];
    #6259 button_inputs[i] = ~button_inputs[i];
    
    #488ms ;

    #23193 button_inputs[i] = ~button_inputs[i];
    #23287 button_inputs[i] = ~button_inputs[i];
    #42333 button_inputs[i] = ~button_inputs[i];
    #4576 button_inputs[i] = ~button_inputs[i];
    #31433 button_inputs[i] = ~button_inputs[i];
    #31315 button_inputs[i] = ~button_inputs[i];
    #51433 button_inputs[i] = ~button_inputs[i];
end

    
endmodule
