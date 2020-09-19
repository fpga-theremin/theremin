`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2020 11:33:57 AM
// Design Name: 
// Module Name: bcpu_alu_dsp48e1
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

import bcpu_defs::*;

module bcpu_alu_dsp48e1
#(
    parameter DATA_WIDTH = 16
)
(
    // input clock, ~200..260MHz
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,

    // enable ALU, (when 1, inputs contain new ALU operation, result will be available after 3 CLK cycles)
    input logic ALU_EN,

    // operand A input
    input logic [DATA_WIDTH-1 : 0] A_IN,

    // operand B input
    input logic [DATA_WIDTH-1 : 0] B_IN,

    // alu operation code, see aluop_t enum 
    input logic [3:0] ALU_OP,

    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,
        
    // output flags {V, S, Z, C} - delayed by 3 clock cycles from inputs
    output logic [3:0] FLAGS_OUT,
    
    // alu result output         - delayed by 3 clock cycles from inputs
    output logic [DATA_WIDTH-1 : 0] ALU_OUT
);

// buffer all inputs
logic [DATA_WIDTH-1:0] a_in_reg;
//logic [DATA_WIDTH-1:0] b_in_reg;
logic [3:0] alu_op_reg;
logic alu_en_reg;
logic [3:0] flags_in_reg;

always_ff @(posedge CLK) begin
    if (RESET) begin
        a_in_reg <= 'b0;
//        b_in_reg <= 'b0;
        flags_in_reg <= 'b0;
        alu_op_reg <= 'b0;
        alu_en_reg <= 'b0;
    end else if (CE) begin
        a_in_reg <= A_IN;
//        b_in_reg <= B_IN;
        flags_in_reg <= FLAGS_IN;
        alu_op_reg <= ALU_OP;
        alu_en_reg <= ALU_EN;
    end
end

// two additional pipeline stages for storing of flags 
logic [3:0] flags_in_stage1;
logic [3:0] flags_in_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        flags_in_stage1 <= 'b0;
        flags_in_stage2 <= 'b0;
    end else if (CE) begin
        flags_in_stage2 <= flags_in_stage1;
        flags_in_stage1 <= flags_in_reg;
    end
end

// Flags update mask
logic [3:0] flags_update_mask_stage1;
logic [3:0] flags_update_mask_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        flags_update_mask_stage1 <= 'b0;
        flags_update_mask_stage2 <= 'b0;
    end else if (CE) begin
        flags_update_mask_stage2 <= flags_update_mask_stage1;
        if (~alu_en_reg) begin
            flags_update_mask_stage1 <= 'b0;
        end else begin
            case (alu_op_reg)
                ALUOP_INCNF:  flags_update_mask_stage1 <= 4'b0000; //    = 4'b0000, //   RC = RA + RB                                 ....       MOV, NOP
                ALUOP_DECNF:  flags_update_mask_stage1 <= 4'b0000; //    = 4'b0001, //   RC = RA - RB                                 ....
                ALUOP_INC:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b0010, //   RC = RA + RB                                 .SZ.
                ALUOP_DEC:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b0011, //   RC = RA - RB                                 .SZ.
            
                ALUOP_ADD:    flags_update_mask_stage1 <= 4'b1111; //    = 4'b0100, //   RC = RA + RB                                 VSZC
                ALUOP_SUB:    flags_update_mask_stage1 <= 4'b1111; //    = 4'b0101, //   RC = RA - RB                                 VSZC       CMP
                ALUOP_ADDC:   flags_update_mask_stage1 <= 4'b1111; //    = 4'b0110, //   RC = RA + RB + CF                            VSZC
                ALUOP_SUBC:   flags_update_mask_stage1 <= 4'b1111; //    = 4'b0111, //   RC = RA - RB - CF                            VSZC       CMPC
                
                ALUOP_AND:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b1000, //   RC = RA & RB                                 .SZ.
                ALUOP_XOR:    flags_update_mask_stage1 <= 4'b0110; //    = 4'b1001, //   RC = RA ^ RB                                 .SZ.
                ALUOP_OR:     flags_update_mask_stage1 <= 4'b0110; //    = 4'b1010, //   RC = RA | RB                                 .SZ.
                ALUOP_ANDN:   flags_update_mask_stage1 <= 4'b0110; //    = 4'b1011, //   RC = RA & ~RB                                .SZ.
                
                ALUOP_MUL:    flags_update_mask_stage1 <= 4'b0000; //    = 4'b1100, //   RC = low(RA * RB)                            .SZ.       SHL, SAL
                ALUOP_MULHUU: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1101, //   RC = high(unsigned RA * unsigned RB)         .SZ.       SHR
                ALUOP_MULHSS: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1110, //   RC = high(signed RA * signed RB)             .SZ.
                ALUOP_MULHSU: flags_update_mask_stage1 <= 4'b0000; //    = 4'b1111  //   RC = high(signed RA * unsigned RB)           .SZ.       SAR
            endcase
        end
            
    end
end

// result mux: 0 for lower half, 1 for upper half of result (for multiplication only)
logic result_mux_index;
logic result_mux_index_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        result_mux_index <= 'b0;
        result_mux_index_stage2 <= 'b0;
    end else if (CE) begin 
        result_mux_index_stage2 <= result_mux_index;
        result_mux_index <= (alu_op_reg == ALUOP_MULHUU) || (alu_op_reg == ALUOP_MULHSU) || (alu_op_reg == ALUOP_MULHSS);
    end
end 



// 1 to reset DSP
logic dsp_reset;
// 1 to enable DSP
logic dsp_ce;

// carry input
logic dsp_carry_in;

// data inputs
logic [29:0] dsp_a_in; // 30-bit A data input
logic [17:0] dsp_b_in; // 18-bit B data input
logic [47:0] dsp_c_in; // 48-bit C data input
logic [24:0] dsp_d_in; // 25-bit D data input
// data output
logic [47:0] dsp_p_out; // 48-bit P data output
logic[3:0] dsp_carryout;                // 7-bit input: Operation mode input
logic dsp_patterndetect;          // 1-bit output: Pattern detect output   (1 when P[17:0] == 18'b0)
logic dsp_patternbdetect;         // 1-bit output: Pattern detect output   (1 when P[17:0] == 18'h3ffff)

// mode
logic[3:0] dsp_alumode;               // 4-bit input: ALU control input
logic[2:0] dsp_carryinsel;            // 3-bit input: Carry select input
logic[4:0] dsp_inmode;                // 5-bit input: INMODE control input
logic[6:0] dsp_opmode;                // 7-bit input: Operation mode input

typedef enum logic[4:0] {
    DSP_INMODE_B2_A2 = 5'b0_0000,    // A=A2, B=B2
    DSP_INMODE_B2_D  = 5'b0_0111,    // A=D, B=B2
    DSP_INMODE_B1_D  = 5'b1_1111     // A=D, B=B2
} dsp_inmode_t;

typedef enum logic[3:0] {
    DSP_ALUMODE_ADD     = 4'b0000,  // Z + X + Y + CIN
    DSP_ALUMODE_SUB     = 4'b0011,  // Z - (X + Y + CIN)
    DSP_ALUMODE_AND_OR  = 4'b1100,  // Z & X   -- OR requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
    DSP_ALUMODE_XOR     = 4'b0100,  // Z ^ X 
    DSP_ALUMODE_ANDN    = 4'b1111   // Z & ~X // requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
} dsp_alumode_t;

typedef enum logic[6:0] {
    //                        Z    Y  X
    DSP_OPMODE_XAB_Y0_ZC  = 7'b011_00_11,  // X=A:B, Y=0,    Z=C
    DSP_OPMODE_XAB_YFF_ZC = 7'b011_10_11,  // X=A:B, Y=FF.., Z=C
    //DSP_OPMODE_X0_YFF_Z0  = 7'b000_10_00,  // X=0,   Y=FF.., Z=0
    //DSP_OPMODE_X0_Y0_Z0   = 7'b000_00_00,  // X=0,   Y=0,    Z=0
    //DSP_OPMODE_XAB_Y0_Z0  = 7'b000_00_11,  // X=A:B, Y=0,    Z=0
    DSP_OPMODE_XM_YM_Z0   = 7'b000_01_01   // X=M,   Y=M,    Z=0
} dsp_opmode_t;


// 1 to reset DSP
always_comb dsp_reset <= RESET;
// 1 to enable DSP
always_comb dsp_ce <= CE;

// carry in mode - normal
always_comb dsp_carryinsel <= 'b000; // CARRYIN
// multiplier inputs: B, D
assign dsp_inmode = DSP_INMODE_B1_D;

// Carry in logic
logic adder_op_is_subtract;
logic carry_in;
always_comb adder_op_is_subtract <= (alu_op_reg==ALUOP_SUB) || (alu_op_reg==ALUOP_SUBC) || (alu_op_reg==ALUOP_DEC);
always_comb carry_in <= ((alu_op_reg==ALUOP_ADDC) || (alu_op_reg==ALUOP_SUBC)) ? flags_in_reg[FLAG_C] : 1'b0;

always_comb dsp_carry_in <= carry_in ^ adder_op_is_subtract; // invert carry in for subtract

logic d_signex;  
logic b_signex;  
always_comb d_signex <= A_IN[DATA_WIDTH-1] & (ALU_OP == ALUOP_MULHSS || ALU_OP == ALUOP_MULHSU);  
always_comb b_signex <= B_IN[DATA_WIDTH-1] & (ALU_OP == ALUOP_MULHSS);  

assign dsp_c_in = { {48-DATA_WIDTH{1'b0}},          a_in_reg};     // add/subtract operand 1 C
assign dsp_d_in = { {25-DATA_WIDTH{d_signex}},          A_IN};    // multiplier 1
assign dsp_b_in = { {18-DATA_WIDTH{b_signex}},          B_IN};    // multiplier 2, A:B add/subtract operand 2
assign dsp_a_in = 'b0;                                            // sign only: top part of A:B for add/subtract operand 2  


always_comb 
    case(alu_op_reg)
        ALUOP_INCNF:  begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        ALUOP_DECNF:  begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;    end
        ALUOP_INC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        ALUOP_DEC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;    end

        ALUOP_ADD:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        ALUOP_SUB:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;    end
        ALUOP_ADDC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        ALUOP_SUBC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;    end
        
        ALUOP_AND:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_AND_OR; end
        ALUOP_XOR:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC ;   dsp_alumode <= DSP_ALUMODE_XOR;    end
        ALUOP_ANDN:   begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_ANDN;   end
        ALUOP_OR:     begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_AND_OR; end

        
        // unsigned*unsigned mul low part, arithmetic shift left, logic shift left, take carry_out from p[16]         
        ALUOP_MUL:     begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        // unsigned*unsigned mul high part, logic shift right  
        ALUOP_MULHUU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        ALUOP_MULHSS:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;    end
        // signed*unsigned mul high part, arithmetic shift right
        ALUOP_MULHSU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;    end
    endcase 


// output value
always_comb ALU_OUT <= result_mux_index_stage2 
            ? dsp_p_out[DATA_WIDTH*2-1:DATA_WIDTH]   // higher half 
            : dsp_p_out[DATA_WIDTH-1:0];             // lower half

// output flags
logic [3:0] new_flags;
always_comb
     FLAGS_OUT <= (new_flags & flags_update_mask_stage2) 
                | (flags_in_stage2 & ~flags_update_mask_stage2);

always_comb new_flags[FLAG_Z] <= dsp_patterndetect;                               // 1 when all bits of result are 0 
always_comb new_flags[FLAG_S] <= dsp_p_out[DATA_WIDTH-1];                         // upper bit is sign
always_comb new_flags[FLAG_C] <= dsp_p_out[DATA_WIDTH];                           // carry out
always_comb new_flags[FLAG_V] <= dsp_p_out[DATA_WIDTH-1] ^ dsp_p_out[DATA_WIDTH]; // overflow



// DSP48E1: 48-bit Multi-Functional Arithmetic Block
//          Artix-7
// Xilinx HDL Language Template, version 2017.3

DSP48E1 #(
    // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("TRUE"),               // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK(48'h00000000ffff),          // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("PATDET"),    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(2),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(2),                         // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(2),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(2),                         // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(1),                         // Number of pipeline stages for C (0 or 1)
    .DREG(1),                         // Number of pipeline stages for D (0 or 1)
    .INMODEREG(0),                    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1)                          // Number of pipeline stages for P (0 or 1)
)
DSP48E1_inst (
    // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),                   // 30-bit output: A port cascade output
    .BCOUT(),                   // 18-bit output: B port cascade output
    .CARRYCASCOUT(),            // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),             // 1-bit output: Multiplier sign cascade output
    .PCOUT(),                   // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),                // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(dsp_patternbdetect), // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(dsp_patterndetect),   // 1-bit output: Pattern detect output
    .UNDERFLOW(),               // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(dsp_carryout),    // 4-bit output: Carry output
    .P(dsp_p_out),              // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(),                     // 30-bit input: A cascade data input
    .BCIN(),                     // 18-bit input: B cascade input
    .CARRYCASCIN(),              // 1-bit input: Cascade carry input
    .MULTSIGNIN(),               // 1-bit input: Multiplier sign input
    .PCIN(),                     // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .ALUMODE(dsp_alumode),               // 4-bit input: ALU control input
    .CARRYINSEL(dsp_carryinsel),         // 3-bit input: Carry select input
    .CLK(CLK),                       // 1-bit input: Clock input
    .INMODE(dsp_inmode),                 // 5-bit input: INMODE control input
    .OPMODE(dsp_opmode),                 // 7-bit input: Operation mode input
    // Data: 30-bit (each) input: Data Ports
    .A(dsp_a_in),                           // 30-bit input: A data input
    .B(dsp_b_in),                           // 18-bit input: B data input
    .C(dsp_c_in),                           // 48-bit input: C data input
    .CARRYIN(dsp_carry_in),        // 1-bit input: Carry input signal
    .D(dsp_d_in),                           // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(dsp_ce),                         // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(dsp_ce),                         // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(),                         // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(dsp_ce),                    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(dsp_ce),                         // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(dsp_ce),                         // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(dsp_ce),                          // 1-bit input: Clock enable input for CREG
    .CECARRYIN(dsp_ce),                    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(dsp_ce),                       // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(dsp_ce),                                // 1-bit input: Clock enable input for DREG
    .CEINMODE(),                           // 1-bit input: Clock enable input for INMODEREG
    .CEM(dsp_ce),                          // 1-bit input: Clock enable input for MREG
    .CEP(dsp_ce),                          // 1-bit input: Clock enable input for PREG
    // reset
    .RSTA(dsp_reset),                      // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(dsp_reset),             // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(dsp_reset),                // 1-bit input: Reset input for ALUMODEREG
    .RSTB(dsp_reset),                      // 1-bit input: Reset input for BREG
    .RSTC(dsp_reset),                      // 1-bit input: Reset input for CREG
    .RSTCTRL(dsp_reset),                   // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(dsp_reset),                      // 1-bit input: Reset input for DREG and ADREG
    .RSTINMODE(),                          // 1-bit input: Reset input for INMODEREG
    .RSTM(dsp_reset),                      // 1-bit input: Reset input for MREG
    .RSTP(dsp_reset)                       // 1-bit input: Reset input for PREG
);
// End of DSP48E1_inst instantiation

endmodule
