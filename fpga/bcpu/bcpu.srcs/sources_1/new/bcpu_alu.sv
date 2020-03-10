`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2020 11:20:04 AM
// Design Name: 
// Module Name: bcpu_alu
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

module bcpu_alu
#(
    parameter DATA_WIDTH = 16
)
(
    // input clock
    input logic CLK,
    // when 1, enable pipeline step, when 0 pipeline is paused
    input logic CE,
    // reset signal, active 1
    input logic RESET,
    // enable ALU (when disabled it should force output to 0 and flags should be kept unchanged)
    input logic EN,

    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    input [2:0] CONST_OR_REG_INDEX, 
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    input [1:0] IMM_MODE,

    // when 0, force A to 0 (e.g. can be useful for R0 = 0 as operand A)
    input logic A_IN_EN,
    // operand A input    
    input logic [DATA_WIDTH-1 : 0] A_IN,
    // operand B input    
    input logic [DATA_WIDTH-1 : 0] B_IN,

    // alu operation code    
    input logic [3:0] ALU_OP,
    
    // input flags {V, S, Z, C}
    input logic [3:0] FLAGS_IN,

    // input flags {V, S, Z, C}
    output logic [3:0] FLAGS_OUT,
    // alu result output    
    output logic [DATA_WIDTH-1 : 0] ALU_OUT
);

logic [3:0] flags_mask;
logic [3:0] flags_mask_stage1;
logic [3:0] flags_mask_stage2;

logic [3:0] flags_stage1;
logic [3:0] flags_stage2;
logic en_stage1;
logic en_stage2;
always_ff @(posedge CLK)
    if (RESET) begin
        en_stage2 <= 'b0;
        en_stage1 <= 'b0;
        flags_stage2 <= 'b0;
        flags_stage1 <= 'b0;
        flags_mask_stage2 <= 'b0;
        flags_mask_stage1 <= 'b0;
    end else if (CE) begin
        en_stage2 <= en_stage1;
        en_stage1 <= EN;
        flags_stage2 <= flags_stage1;
        flags_stage1 <= FLAGS_IN;
        flags_mask_stage2 <= flags_mask_stage1;
        flags_mask_stage1 <= flags_mask;
    end
        

// 1 to reset DSP input
logic dsp_reset_in;
logic dsp_reset_a;
// 1 to reset DSP input
logic dsp_reset_out;

always_comb dsp_reset_a <= RESET | ~(A_IN_EN & EN);
always_comb dsp_reset_in <= RESET | ~(EN);
always_comb dsp_reset_out <= RESET | ~(en_stage1);

logic dsp_ce_inputs;
logic dsp_ce_output;
always_comb dsp_ce_inputs <= CE;
always_comb dsp_ce_output <= CE;

// carry input
logic dsp_carry_in;
// Carry IN value processing
always_comb dsp_carry_in <= (ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUBC) ? FLAGS_IN[FLAG_C] : 1'b0;


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

//logic[3:0] dsp_alumode;               // 4-bit input: ALU control input
typedef enum logic[3:0] {
    DSP_ALUMODE_ADD     = 4'b0000,  // Z + X + Y + CIN
    DSP_ALUMODE_SUB     = 4'b0011,  // Z - (X + Y + CIN)
    DSP_ALUMODE_SUB_INV = 4'b0001,  // -Z + (X + Y + CIN) - 1
    DSP_ALUMODE_AND_OR  = 4'b1100,  // Z & X   -- OR requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
    //DSP_ALUMODE_OR      = 4'b1100,  // Z | X  // requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
    DSP_ALUMODE_XOR     = 4'b0101,  // Z ^ X  // requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
    DSP_ALUMODE_ANDN    = 4'b1111   // Z & ~X // requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
} dsp_alumode_t;

typedef enum logic[4:0] {
    DSP_INMODE_B2_A2 = 5'b0_0000,    // A=A2, B=B2
    DSP_INMODE_B2_D  = 5'b0_0111     // A=D, B=B2
} dsp_inmode_t;

typedef enum logic[6:0] {
    //                        Z    Y  X
    DSP_OPMODE_XAB_Y0_ZC  = 7'b011_00_11,  // X=A:B, Y=0,    Z=C
    DSP_OPMODE_XAB_YFF_ZC = 7'b011_10_11,  // X=A:B, Y=FF.., Z=C
    DSP_OPMODE_X0_YFF_Z0  = 7'b000_10_00,  // X=0,   Y=FF.., Z=0
    DSP_OPMODE_X0_Y0_Z0   = 7'b000_00_00,  // X=0,   Y=0,    Z=0
    DSP_OPMODE_XAB_Y0_Z0  = 7'b000_00_11,  // X=A:B, Y=0,    Z=0
    DSP_OPMODE_XM_YM_Z0   = 7'b000_01_01   // X=M,   Y=M,    Z=0
} dsp_opmode_t;

typedef enum logic[1:0] {
    OUT_MODE_0 =  2'b00,    // force output to zero
    OUT_MODE_L =  2'b01,    // use lower part of DSP output
    OUT_MODE_H =  2'b10,    // use higher part of DSP output
    OUT_MODE_LH = 2'b11     // combine lower and higher part of DSP output by OR
} out_mode_t;

typedef enum logic[3:0] {
    FLAGS_MASK_NONE =  4'b0000,    // don't update flags
    FLAGS_MASK_VSZC =  4'b1111,    // update all flags
    FLAGS_MASK_SZC  =  4'b0111,    // update all flags
    FLAGS_MASK_SZ   =  4'b0110,    // update ZF ans SF only
    FLAGS_MASK_C    =  4'b0001     // update CF only
} flags_mask_t;

out_mode_t out_mode;
logic out_mode_high_stage1;
logic out_mode_high_stage2;
logic out_mode_mix_stage1;
logic out_mode_mix_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        out_mode_high_stage2 <= 'b0;
        out_mode_high_stage1 <= 'b0;
        out_mode_mix_stage1 <= 'b0;
        out_mode_mix_stage2 <= 'b0;
    end else if (CE) begin
        out_mode_high_stage2 <= out_mode_high_stage1;
        out_mode_mix_stage2 <= out_mode_mix_stage1;
        out_mode_high_stage1 <= out_mode == OUT_MODE_H;
        out_mode_mix_stage1 <= out_mode == OUT_MODE_LH;
    end
end

always_comb dsp_carryinsel <= 'b000; // CARRYIN
always_comb dsp_inmode <= DSP_INMODE_B2_D;

logic a_sign;
logic b_sign;
assign a_sign = A_IN[DATA_WIDTH-1];
assign b_sign = B_IN[DATA_WIDTH-1];

logic a_signex;
logic b_signex;

always_comb case(ALU_OP)
        ALUOP_ADD:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_VSZC;   end
        ALUOP_ADDC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_VSZC;   end
        ALUOP_SUB:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_VSZC;   end
        ALUOP_SUBC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_VSZC;   end
        
        ALUOP_INC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_SZ;     end
        ALUOP_DEC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;  flags_mask <= FLAGS_MASK_SZ;     end

        ALUOP_AND:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_AND_OR;  a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;   flags_mask <= FLAGS_MASK_SZ;     end
        ALUOP_ANDN:   begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_ANDN;    a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;   flags_mask <= FLAGS_MASK_SZ;     end
        ALUOP_OR:     begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_AND_OR;  a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;   flags_mask <= FLAGS_MASK_SZ;     end
        ALUOP_XOR:    begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_XOR;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_L;   flags_mask <= FLAGS_MASK_SZ;     end

        // rotate
        ALUOP_ROTATE:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_LH;  flags_mask <= FLAGS_MASK_SZC;    end
        // rotate with shifting in carry flag bit 0 or bit 15 of result will be replaced with carry_in value
        ALUOP_ROTATEC: begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_LH;  flags_mask <= FLAGS_MASK_SZC;    end
        
        // unsigned*unsigned mul low part, arithmetic shift left, logic shift left, take carry_out from p[16]         
        ALUOP_MULL:    begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_L;   flags_mask <= FLAGS_MASK_SZC;    end
        // unsigned*unsigned mul high part, logic shift right  
        ALUOP_MULHUU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_H;   flags_mask <= FLAGS_MASK_SZC;    end
        ALUOP_MULHSS:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= a_sign; b_signex = b_sign;  out_mode <= OUT_MODE_H;   flags_mask <= FLAGS_MASK_SZ;     end
        // signed*unsigned mul high part, arithmetic shift right
        ALUOP_MULHSU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= a_sign; b_signex = 1'b0;    out_mode <= OUT_MODE_H;   flags_mask <= FLAGS_MASK_SZC;    end
    endcase


assign dsp_a_in = {30{b_signex}};
assign dsp_b_in = {b_signex, b_signex, B_IN};
assign dsp_c_in = {{32{a_signex}}, A_IN};
assign dsp_d_in = {{25{a_signex}}, A_IN};

logic [DATA_WIDTH-1 : 0] alu_out_mux;
assign ALU_OUT = alu_out_mux;

assign alu_out_mux = out_mode_high_stage2 ? dsp_p_out[31:16] : ((dsp_p_out[31:16] & {16{out_mode_mix_stage2}}) | dsp_p_out[15:0]); 
//(dsp_p_out[31:16] & {16{out_mode_high_stage2}}) |

//(dsp_p_out[31:16] & {16{out_mode_mix_stage2}}) | dsp_p_out[15:0]

//function logic[1:0] outMix2Bits;
//    input logic[1:0] low;
//    input logic[1:0] high;
//    input logic mix_low;
//    input logic use_high;
//    outMix2Bits = use_high ? high : (low | (high[1] & {mix_low, mix_low }) );
//endfunction

//assign alu_out_mux[1:0] = outMix2Bits(dsp_p_out[1:0], dsp_p_out[17:16], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[3:2] = outMix2Bits(dsp_p_out[3:2], dsp_p_out[19:18], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[5:4] = outMix2Bits(dsp_p_out[5:4], dsp_p_out[21:20], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[7:6] = outMix2Bits(dsp_p_out[7:6], dsp_p_out[23:22], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[9:8] = outMix2Bits(dsp_p_out[9:8], dsp_p_out[25:24], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[11:10] = outMix2Bits(dsp_p_out[11:10], dsp_p_out[27:26], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[13:12] = outMix2Bits(dsp_p_out[13:12], dsp_p_out[29:28], out_mode_mix_stage2, out_mode_high_stage2);
//assign alu_out_mux[15:14] = outMix2Bits(dsp_p_out[15:14], dsp_p_out[31:30], out_mode_mix_stage2, out_mode_high_stage2);

//logic [DATA_WIDTH-1 : 0] alu_out_mux_high;
//logic [DATA_WIDTH-1 : 0] alu_out_mux_low;

//always_comb alu_out_mux_high <= dsp_p_out[DATA_WIDTH*2-1:DATA_WIDTH];
//always_comb alu_out_mux_low <= (out_mode_mix_stage2 ? dsp_p_out[DATA_WIDTH*2-1:DATA_WIDTH] : 0) | dsp_p_out[DATA_WIDTH-1:0];
//always_comb alu_out_mux <= out_mode_high_stage2 ? alu_out_mux_high : alu_out_mux_low;
//        out_mode_high_stage2 <= out_mode_high_stage1;
//        out_mode_mix_stage2 <= out_mode_mix_stage1;

//always_comb case(out_mode_stage2)
//       OUT_MODE_0:  alu_out_mux <= 'b0;
//       OUT_MODE_L:  alu_out_mux <= dsp_p_out[DATA_WIDTH-1:0];
//       OUT_MODE_H:  alu_out_mux <= dsp_p_out[DATA_WIDTH*2-1:DATA_WIDTH];
//       OUT_MODE_LH: alu_out_mux <= dsp_p_out[DATA_WIDTH-1:0] | dsp_p_out[DATA_WIDTH*2-1:DATA_WIDTH];
//    endcase
//always_comb alu_out_mux <= dsp_p_out[DATA_WIDTH-1:0];

logic new_c_flag;
logic new_z_flag;
logic new_s_flag;
logic new_v_flag;

always_comb new_c_flag <= dsp_carryout;
always_comb new_z_flag <= dsp_patterndetect;
always_comb new_s_flag <= alu_out_mux[DATA_WIDTH-1];
always_comb new_v_flag <= dsp_carryout != alu_out_mux[DATA_WIDTH-1];

always_comb FLAGS_OUT[FLAG_C] <= flags_mask_stage2[FLAG_C] ? new_c_flag : flags_stage2[FLAG_C];
always_comb FLAGS_OUT[FLAG_Z] <= flags_mask_stage2[FLAG_Z] ? new_z_flag : flags_stage2[FLAG_Z];
always_comb FLAGS_OUT[FLAG_S] <= flags_mask_stage2[FLAG_S] ? new_s_flag : flags_stage2[FLAG_S];
always_comb FLAGS_OUT[FLAG_V] <= flags_mask_stage2[FLAG_V] ? new_v_flag : flags_stage2[FLAG_V];

// DSP48E1: 48-bit Multi-Functional Arithmetic Block
//          Artix-7
// Xilinx HDL Language Template, version 2017.3

DSP48E1 #(
    // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("TRUE"),               // Select D port usage (TRUE or FALSE)
    .USE_MULT("DYNAMIC"),             // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK(~(48'h00000003ffff >> (18-DATA_WIDTH))),          // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),                        // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(1),                         // Number of pipeline stages for C (0 or 1)
    .DREG(1),                         // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(0),                         // Number of multiplier pipeline stages (0 or 1)
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
    .PATTERNBDETECT(dsp_patternbdetect),         // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(dsp_patterndetect),           // 1-bit output: Pattern detect output
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
    .CEA1(1'b0),                           // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(dsp_ce_inputs),                  // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(1'b0),                           // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(dsp_ce_inputs),             // 1-bit input: Clock enable input for ALUMODE
    .CEB1(1'b0),                           // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(dsp_ce_inputs),                  // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(dsp_ce_inputs),                   // 1-bit input: Clock enable input for CREG
    .CECARRYIN(dsp_ce_inputs),             // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(dsp_ce_inputs),                // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(dsp_ce_inputs),                   // 1-bit input: Clock enable input for DREG
    .CEINMODE(dsp_ce_inputs),              // 1-bit input: Clock enable input for INMODEREG
    .CEM(1'b0),                            // 1-bit input: Clock enable input for MREG
    .CEP(dsp_ce_output),                   // 1-bit input: Clock enable input for PREG
    // reset
    .RSTA(dsp_reset_in),                   // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(dsp_reset_in),          // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(dsp_reset_in),             // 1-bit input: Reset input for ALUMODEREG
    .RSTB(dsp_reset_in),                   // 1-bit input: Reset input for BREG
    .RSTC(dsp_reset_a),                    // 1-bit input: Reset input for CREG
    .RSTCTRL(dsp_reset_in),                // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(dsp_reset_a),                    // 1-bit input: Reset input for DREG and ADREG
    .RSTINMODE(dsp_reset_in),              // 1-bit input: Reset input for INMODEREG
    .RSTM(dsp_reset_in),                   // 1-bit input: Reset input for MREG
    .RSTP(dsp_reset_out)                   // 1-bit input: Reset input for PREG
);
// End of DSP48E1_inst instantiation






endmodule
