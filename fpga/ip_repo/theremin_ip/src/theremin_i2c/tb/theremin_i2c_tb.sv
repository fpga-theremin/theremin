`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2018 01:11:14 PM
// Design Name: 
// Module Name: theremin_audio_i2c_tb
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


//`define debug_theremin_audio_i2c

module theremin_i2c_tb(

    );

reg CLK;
reg RESET;

reg [23:0] COMMAND;  // [23:16] - device address/op, [15:8] register address, [7:0] data to write
reg START;           // 1 for one CLK_100 cycle to start operation according to COMMAND
wire [7:0] DATA_OUT; // data read from I2C
wire READY;
wire ERROR;

wire I2C_DATA;
wire I2C_CLK;        // 400KHz

`ifdef debug_theremin_audio_i2c
    wire [4:0] debug_state_reg;
    wire debug_phase0;
    wire debug_phase1;
    wire debug_phase2;
    wire debug_phase3;
    wire debug_buf_tri;
    wire debug_i2c_data_reg;
    wire [7:0] debug_out_shift_reg;
    wire [7:0] debug_input_shift_reg;
    wire [23:0] debug_command_reg;
`endif


theremin_i2c theremin_i2c_inst (
    .*
);

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value (%h != %h)   dec (%d != %d)", signal, value, signal, value); \
            $finish; \
        end

`define assertRange(signal, valueMin, valueMax) \
        if (signal < valueMin || signal > valueMax) begin \
            $display("ASSERTION FAILED in %m: signal is not in range (%h not in %h .. %h)", signal, valueMin, valueMax); \
            $finish; \
        end

`define i2cWrite(devaddr, regaddr, data) \
    $display("I2C Write: dev=%h, reg=%h, data=%h", devaddr, regaddr, data); \
    @(posedge CLK) #1 COMMAND = {devaddr, regaddr, data}; START = 1; \
    @(posedge CLK) #1 START = 0; \
    @(posedge READY) #1 @(posedge CLK) $display("Write result: error=%h, ready=%h, data=%h", ERROR, READY, DATA_OUT); \
    @(posedge CLK) @(posedge CLK) @(posedge CLK)
    

initial begin
    START = 0;
    COMMAND = 0;
    RESET = 0;
    #20
    RESET = 1;
    #120
    RESET = 0;
end

always begin
    #5 CLK = 0;
    #5 CLK = 1;
end

always @(negedge I2C_DATA) begin
    if (I2C_CLK)
        $display(" *** start bit condition detected");
end

always @(posedge I2C_DATA) begin
    if (I2C_CLK)
        $display(" *** stop bit condition detected");
end

initial begin
    #180
    $display("====== Starting I2C test ========");
    
    $display("write op:");    
    `i2cWrite(8'b00010110, 8'b00001010, 8'b01010101)    
    #8000 `i2cWrite(8'b00010110, 8'b00001011, 8'b10101010)   
    #8000 `i2cWrite(8'b01111110, 8'b01111011, 8'b11111111)   
    #8000 `i2cWrite(8'b01111110, 8'b01111011, 8'b00000000)   
    $display("read op:");    
    #8000 `i2cWrite(8'b10010110, 8'b00101111, 8'b00001000)    
    
    #5000
    $display("====== Finished I2C test ========");
    $finish();
end

endmodule
