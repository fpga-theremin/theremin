`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2018 09:17:48 AM
// Design Name: 
// Module Name: theremin_audio_i2c
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

module theremin_i2c (
    input CLK,
    input RESET,
    
    input [23:0] COMMAND,  // [23:16] - device address/op, [15:8] register address, [7:0] data to write
    input START,           // 1 for one CLK_100 cycle to start operation according to COMMAND
    output [7:0] DATA_OUT, // data read from I2C
    output READY,
    output ERROR,
    
    inout I2C_DATA,
    inout I2C_CLK        // 400KHz

`ifdef debug_theremin_audio_i2c
    , output [4:0] debug_state_reg
    , output debug_phase0
    , output debug_phase1
    , output debug_phase2
    , output debug_phase3
    , output debug_buf_tri
    , output debug_i2c_data_reg
    , output [7:0] debug_out_shift_reg
    , output [7:0] debug_input_shift_reg
    , output [23:0] debug_command_reg
`endif
);

wire buf_out;
wire buf_in;
wire buf_tri;

wire clk_in;
wire clk_tri;
assign clk_tri = 'b0;

reg [7:0] clk_counter;
reg phase0;  // CLK 1->0
reg phase1;  // middle of CLK==0
reg phase2;  // CLK 0->1
reg phase3;  // middle of CLK==1

// divider 100MHz/250 = 400KHz 
always_ff @(posedge CLK)
begin
    if (RESET) begin
        clk_counter <= 'b0;
        phase0 <= 'b0;
        phase1 <= 'b0;
        phase2 <= 'b0;
        phase3 <= 'b0;
    end else begin
        phase0 <= (clk_counter == 8'd0);
        phase1 <= (clk_counter == 8'd62);
        phase2 <= (clk_counter == 8'd124);
        phase3 <= (clk_counter == 8'd186);
        if (clk_counter == 8'd249) begin
            clk_counter <= 8'b0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end
end

reg [23:0] command_reg;
reg ready_reg;
assign READY = ready_reg;
reg start_reg;
/*
    0   idle
    1   start bit
    2   bit1 of device address
    3   bit2 of device address
    4   bit3 of device address
    5   bit4 of device address
    6   bit5 of device address
    7   bit6 of device address
    8   bit7 of device address
    9   bit8 of device address
   10   ack from slave
   11   bit1 of sub address
   12   bit2 of sub address
   13   bit3 of sub address
   14   bit4 of sub address
   15   bit5 of sub address
   16   bit6 of sub address
   17   bit7 of sub address
   18   bit8 of sub address
   19   ack from slave
   20   bit1 of data read/write
   21   bit2 of data read/write
   22   bit3 of data read/write
   23   bit4 of data read/write
   24   bit5 of data read/write
   25   bit6 of data read/write
   26   bit7 of data read/write
   27   bit8 of data read/write
   28   ack from slave
   29   stop bit
*/
reg [4:0] state_reg;
wire [29:0] state;
assign state[0] = (state_reg == 5'd0);
assign state[1] = (state_reg == 5'd1);
assign state[2] = (state_reg == 5'd2);
assign state[3] = (state_reg == 5'd3);
assign state[4] = (state_reg == 5'd4);
assign state[5] = (state_reg == 5'd5);
assign state[6] = (state_reg == 5'd6);
assign state[7] = (state_reg == 5'd7);
assign state[8] = (state_reg == 5'd8);
assign state[9] = (state_reg == 5'd9);
assign state[10] = (state_reg == 5'd10);
assign state[11] = (state_reg == 5'd11);
assign state[12] = (state_reg == 5'd12);
assign state[13] = (state_reg == 5'd13);
assign state[14] = (state_reg == 5'd14);
assign state[15] = (state_reg == 5'd15);
assign state[16] = (state_reg == 5'd16);
assign state[17] = (state_reg == 5'd17);
assign state[18] = (state_reg == 5'd18);
assign state[19] = (state_reg == 5'd19);
assign state[20] = (state_reg == 5'd20);
assign state[21] = (state_reg == 5'd21);
assign state[22] = (state_reg == 5'd22);
assign state[23] = (state_reg == 5'd23);
assign state[24] = (state_reg == 5'd24);
assign state[25] = (state_reg == 5'd25);
assign state[26] = (state_reg == 5'd26);
assign state[27] = (state_reg == 5'd27);
assign state[28] = (state_reg == 5'd28);
assign state[29] = (state_reg == 5'd29);

reg buf_tri_reg;
assign buf_tri = buf_tri_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        buf_tri_reg <= 1'b0;
    end else begin
        if (phase1) begin // TODO: select proper phase
            buf_tri_reg <= state[10] | state[19] | state[28] // ACK
             | (command_reg[23] & (|state[27:20])); // third byte in READ mode
        end
    end
end

reg error_reg;
assign ERROR = error_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        error_reg <= 1'b0;
    end else begin
        if (phase3) begin // TODO: select proper phase
            case (state_reg)
            5'd2: error_reg <= 1'b0;
            5'd10: error_reg <= buf_out;             // ack must be 0
            5'd19: error_reg <= error_reg | buf_out; // ack must be 0
            5'd28: error_reg <= error_reg | buf_out; // ack must be 0
            endcase
        end
    end
end

reg clk_out_reg;
assign clk_in = clk_out_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        clk_out_reg <= 1'b1;
    end else begin
        if (state[1]) begin
            // start bit
            if (phase0)
                clk_out_reg <= 1'b0;
        end else if (state[29]) begin
            // stop bit
            if (phase2)
                clk_out_reg <= 1'b1;
        end else if (state[0]) begin
            // idle
            clk_out_reg <= 1'b1;
        end else begin
            // normal cycle
            if (phase0)
                clk_out_reg <= 1'b0;
            else if (phase2)
                clk_out_reg <= 1'b1;
        end
    end
end

// output data byte shift register
reg [7:0] out_shift_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        out_shift_reg <= 8'b0;
    end else begin
        if (phase0) begin // TODO: select proper phase
            if (state[2-1]) begin
                out_shift_reg <= command_reg[23:16];
            end else if (state[11-1]) begin
                out_shift_reg <= command_reg[15:8];
            end else if (state[20-1]) begin
                out_shift_reg <= command_reg[7:0];
            end else if (|state[9-1:3-1] || |state[18-1:12-1] || |state[27-1:21-1]) begin
                out_shift_reg <= {out_shift_reg[6:0], 1'b0};
            end
        end
    end
end

reg i2c_data_reg;
assign buf_in = i2c_data_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        i2c_data_reg <= 1'b1;
    end else begin
        if (state[1]) begin
            if (phase1)
                i2c_data_reg <= 1'b0;
        end else if (state[29]) begin
            if (phase1)
                i2c_data_reg <= 1'b0;
            else if (phase3)
                i2c_data_reg <= 1'b1;
        end else if (state[0]) begin
            if (phase1)
                i2c_data_reg <= 1'b1;
        end else begin
            if (phase1)
                i2c_data_reg <= out_shift_reg[7];
        end
    end
end


reg [7:0] input_shift_reg;
reg [7:0] input_data_reg;
assign DATA_OUT = input_data_reg;
always_ff @(posedge CLK) 
begin
    if (RESET) begin
        input_shift_reg <= 8'b0;
        input_data_reg <= 1'b0;
    end else begin
        if (phase3) begin // TODO: select proper phase
            if (|state[27:20]) 
                input_shift_reg <= {input_shift_reg[6:0], buf_out};
            else if (state[28])
                input_data_reg <= input_shift_reg;
        end
    end
end

always_ff @(posedge CLK) begin
    if (RESET) begin
        command_reg <= 24'b0;
        ready_reg <= 1'b1;
        start_reg <= 1'b0;
        state_reg <= 5'b0;
    end else begin
        if (phase0 & ~ready_reg) begin
            if (state_reg == 5'd0) begin
                state_reg <= 5'd1;
            end if (state_reg == 5'd29) begin
                state_reg <= 5'd0;
                ready_reg <= 1'b1;
            end else begin
                state_reg <= state_reg + 1;
            end
        end else if (ready_reg & START) begin
            command_reg <= COMMAND;
            ready_reg <= 1'b0;
            state_reg <= 5'b0;
        end
    end
end


// IOBUF: Single-ended Bi-directional Buffer
//        All devices
// Xilinx HDL Language Template, version 2017.4

IOBUF #(
   .DRIVE(12), // Specify the output drive strength
   .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
   .IOSTANDARD("DEFAULT"), // Specify the I/O standard
   .SLEW("SLOW") // Specify the output slew rate
) IOBUF_data_inst (
   .O(buf_out),     // Buffer output
   .IO(I2C_DATA),   // Buffer inout port (connect directly to top-level port)
   .I(buf_in),     // Buffer input
   .T(buf_tri)      // 3-state enable input, high=input, low=output
);

// End of IOBUF_inst instantiation


// IOBUF: Single-ended Bi-directional Buffer
//        All devices
// Xilinx HDL Language Template, version 2017.4

IOBUF #(
   .DRIVE(12), // Specify the output drive strength
   .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
   .IOSTANDARD("DEFAULT"), // Specify the I/O standard
   .SLEW("SLOW") // Specify the output slew rate
) IOBUF_clk_inst (
   .O(),     // Buffer output
   .IO(I2C_CLK),   // Buffer inout port (connect directly to top-level port)
   .I(clk_in),     // Buffer input
   .T(clk_tri)      // 3-state enable input, high=input, low=output
);

// End of IOBUF_inst instantiation

`ifdef debug_theremin_audio_i2c
    assign debug_state_reg = state_reg;
    assign debug_phase0 = phase0;
    assign debug_phase1 = phase1;
    assign debug_phase2 = phase2;
    assign debug_phase3 = phase3;
    assign debug_buf_tri = buf_tri;
    assign debug_i2c_data_reg = i2c_data_reg;
    assign debug_out_shift_reg = out_shift_reg;
    assign debug_command_reg = command_reg;
    assign debug_input_shift_reg = input_shift_reg;
`endif

endmodule
