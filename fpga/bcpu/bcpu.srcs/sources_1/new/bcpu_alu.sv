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
//     Minimalistic 16-bit ALU for Xilinx Series 7 devices, based on DSP48E1
//     Add / Subtract: ADD, ADDC, SUB, SUBC, INC, DEC, MOV, CMP, CMPC
//     Logic operations: AND, ANDN, OR, XOR
//     Multiply: MUL, MULHUU, MULHSU, MULHSS -- separate ops for low and high parts of result, signed and unsigned
//     Shifts: SHL, SHR, SAR, SAL, ROR, ROL, RCL, RCR -- arithmetic, logic, rotation, rotation via carry (implemented using multiplication)
//     Pipeline latency: 3 clock cycles 
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


    // Operand A inputs:
    
    // when A_REG_INDEX==000 (RA is R0), use 0 instead of A_IN for operand A
    input logic[2:0] A_REG_INDEX,
    // operand A input
    input logic [DATA_WIDTH-1 : 0] A_IN,

    // Operand B inputs:
    
    // B_CONST_OR_REG_INDEX and B_IMM_MODE are needed to implement special cases for shifts and MOV
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    input [2:0] B_CONST_OR_REG_INDEX,
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    // when B_IMM_MODE == 00 and B_CONST_OR_REG_INDEX == 000, use 0 instead of B_IN as operand B value
    input [1:0] B_IMM_MODE,
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

// immediate constant table: override B_IN value if immediate mode != 00
logic [DATA_WIDTH-1 : 0] b_in_override;
bcpu_imm_table
#(
    .DATA_WIDTH(DATA_WIDTH)
)
bcpu_imm_table_inst
(
    // input register value
    .B_VALUE_IN(B_IN),
    // this is actually register index from instruction, unused with IMM_MODE == 00; for reg index 000 force ouput to 0
    .CONST_OR_REG_INDEX(B_CONST_OR_REG_INDEX), 
    // immediate mode from instruction: 00 for bypassing B_VALUE_IN, 01,10,11: replace value with immediate constant from table
    .IMM_MODE(B_IMM_MODE),
    .B_VALUE_OUT(b_in_override)
);


// EN signal pipelining
logic en_stage1;
logic en_stage2;
always_ff @(posedge CLK)
    if (RESET) begin
        en_stage1 <= 'b0;
        en_stage2 <= 'b0;
    end else if (CE) begin
        en_stage2 <= en_stage1;
        en_stage1 <= EN;
    end

// input flags pipelining
logic [3:0] flags_in_stage1;
logic [3:0] flags_in_stage2;
always_ff @(posedge CLK)
    if (RESET) begin
        flags_in_stage1 <= 'b0;
        flags_in_stage2 <= 'b0;
    end else if (CE) begin
        flags_in_stage2 <= flags_in_stage1;
        flags_in_stage1 <= FLAGS_IN;
    end

// shifts support, C flag generation
// is multiplier operation which can be treated as left shift - for shifted out C flag generation
logic is_left_shift;
always_comb is_left_shift  <= ((ALU_OP == ALUOP_MUL) && B_IMM_MODE[1]) // any MUL with single bit immediate
                           || ((ALU_OP == ALUOP_ROTATE || ALU_OP == ALUOP_ROTATEC) && B_IMM_MODE == 2'b10); // rotations with single bit < 1<<8
logic is_right_shift;
always_comb is_right_shift <= ((ALU_OP == ALUOP_MULHUU || ALU_OP == ALUOP_MULHSU)  && B_IMM_MODE[1])         // any MULH with single bit immediate
                           || ((ALU_OP == ALUOP_ROTATE || ALU_OP == ALUOP_ROTATEC) && B_IMM_MODE == 2'b11); // rotations with single bit >= 1<<8

// shifts support, shifting in C flag with rotation (ROTATEC: RCL, RCR)
// rotate left through C: need to replace lower bit with C_in
logic is_rcl;
// rotate right through C: need to replace upper bit with C_in
logic is_rcr;
always_comb is_rcl <= (ALU_OP == ALUOP_ROTATEC) & (B_IMM_MODE == 2'b10); // ROTATEC with single bit imm < 1<<8
always_comb is_rcr <= (ALU_OP == ALUOP_ROTATEC) & (B_IMM_MODE == 2'b11); // ROTATEC with single bit imm >= 1<<8


// flags update mask decoding
logic [3:0] flags_mask;
always_comb flags_mask[FLAG_V] <= (ALU_OP == ALUOP_ADD || ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUB || ALU_OP == ALUOP_SUBC);
always_comb flags_mask[FLAG_S] <= 'b1;
always_comb flags_mask[FLAG_Z] <= 'b1;
always_comb flags_mask[FLAG_C] <= (ALU_OP == ALUOP_ADD || ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUB || ALU_OP == ALUOP_SUBC);

// special case: INC RC, R0, RB_imm    (RC=0+RB_imm) is treated as MOV operation, w/o flags
logic disable_flags_update;
always_comb disable_flags_update <= ((ALU_OP == ALUOP_INC) & (A_REG_INDEX == 3'b000)) | ~EN | RESET; // move or ~EN - to disable flags update

// flags update mask pipelining
logic [3:0] flags_mask_stage1;
logic [3:0] flags_mask_stage2;
always_ff @(posedge CLK)
    if (disable_flags_update) begin
        flags_mask_stage1 <= 'b0;
    end else if (CE) begin
        flags_mask_stage1 <= flags_mask;
    end
always_ff @(posedge CLK)
    if (RESET) begin
        flags_mask_stage2 <= 'b0;
    end else if (CE) begin
        flags_mask_stage2 <= flags_mask_stage1;
    end
        

// 1 to reset DSP input
logic dsp_reset_in;
logic dsp_reset_a;
// 1 to reset DSP input
logic dsp_reset_out;

always_comb dsp_reset_a <= RESET                      // set dsp A to 0 for reset 
                         | (A_REG_INDEX == 3'b000)    // set dsp A to 0 for R0 as A operand
                         | ~EN;                       // set dsp A to 0 when ALU is disabled
                         
always_comb dsp_reset_in <= RESET | ~(EN);
always_comb dsp_reset_out <= RESET | ~(en_stage1);

logic dsp_ce_inputs;
logic dsp_ce_output;
always_comb dsp_ce_inputs <= CE;
always_comb dsp_ce_output <= CE;

// carry input
logic dsp_carry_in;
// Carry IN value processing
always_comb dsp_carry_in <= ((ALU_OP == ALUOP_ADDC || ALU_OP == ALUOP_SUBC) ? FLAGS_IN[FLAG_C]
                          : 1'b0) & EN;


// shift options pipeline
logic is_left_shift_stage1;
logic is_left_shift_stage2;
logic is_right_shift_stage1;
logic is_right_shift_stage2;
logic is_rcl_stage1;
logic is_rcl_stage2;
logic is_rcr_stage1;
logic is_rcr_stage2;
always_ff @(posedge CLK)
    if (RESET | (CE & ~EN)) begin
        is_left_shift_stage1 <= 'b0;
        is_right_shift_stage1 <= 'b0;
        is_rcl_stage1 <= 'b0;
        is_rcr_stage1 <= 'b0;
    end else if (CE) begin
        is_left_shift_stage1 <= is_left_shift;
        is_right_shift_stage1 <= is_right_shift;
        is_rcl_stage1 <= is_rcl;
        is_rcr_stage1 <= is_rcr;
    end

always_ff @(posedge CLK)
    if (RESET) begin
        is_left_shift_stage2 <= 'b0;
        is_right_shift_stage2 <= 'b0;
        is_rcl_stage2 <= 'b0;
        is_rcr_stage2 <= 'b0;
    end else if (CE) begin
        is_left_shift_stage2 <= is_left_shift_stage1;
        is_right_shift_stage2 <= is_right_shift_stage1;
        is_rcl_stage2 <= is_rcl_stage1;
        is_rcr_stage2 <= is_rcr_stage1;
    end

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
    DSP_ALUMODE_AND_OR  = 4'b1100,  // Z & X   -- OR requires opmode[3:2]=10 (DSP_OPMODE_XAB_YFF_ZC)
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

out_mode_t out_mode;
out_mode_t out_mode_stage1;
out_mode_t out_mode_stage2;
always_ff @(posedge CLK) begin
    if (RESET) begin
        out_mode_stage2 <= OUT_MODE_0;
        out_mode_stage1 <= OUT_MODE_0;
    end else if (CE) begin
        out_mode_stage2 <= out_mode_stage1;
        out_mode_stage1 <= out_mode;
    end
end

always_comb dsp_carryinsel <= 'b000; // CARRYIN
always_comb dsp_inmode <= DSP_INMODE_B2_D;

logic a_sign;
logic b_sign;
assign a_sign = A_IN[DATA_WIDTH-1];
assign b_sign = b_in_override[DATA_WIDTH-1];

logic a_signex;
logic b_signex;

always_comb case(ALU_OP)
        ALUOP_ADD:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end
        ALUOP_ADDC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end
        ALUOP_SUB:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end
        ALUOP_SUBC:   begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end
        
        ALUOP_INC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end
        ALUOP_DEC:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_SUB;     a_signex <= 1'b1; b_signex = 1'b1;  out_mode <= OUT_MODE_L;  end

        ALUOP_AND:    begin    dsp_opmode <= DSP_OPMODE_XAB_Y0_ZC;    dsp_alumode <= DSP_ALUMODE_AND_OR;  a_signex <= 1'b0; b_signex = 1'b0;  out_mode <= OUT_MODE_L;  end
        ALUOP_ANDN:   begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_ANDN;    a_signex <= 1'b0; b_signex = 1'b0;  out_mode <= OUT_MODE_L;  end
        ALUOP_OR:     begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_AND_OR;  a_signex <= 1'b0; b_signex = 1'b0;  out_mode <= OUT_MODE_L;  end
        ALUOP_XOR:    begin    dsp_opmode <= DSP_OPMODE_XAB_YFF_ZC;   dsp_alumode <= DSP_ALUMODE_XOR;     a_signex <= 1'b0; b_signex = 1'b0;  out_mode <= OUT_MODE_L;  end

        // rotate
        ALUOP_ROTATE:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_LH; end
        // rotate with shifting in carry flag bit 0 or bit 15 of result will be replaced with carry_in value
        ALUOP_ROTATEC: begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_LH; end
        
        // unsigned*unsigned mul low part, arithmetic shift left, logic shift left, take carry_out from p[16]         
        ALUOP_MUL:     begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_L;  end
        // unsigned*unsigned mul high part, logic shift right  
        ALUOP_MULHUU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b0;   b_signex = 1'b0;    out_mode <= OUT_MODE_H;  end
        ALUOP_MULHSS:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b1;   b_signex = 1'b1;    out_mode <= OUT_MODE_H;  end
        // signed*unsigned mul high part, arithmetic shift right
        ALUOP_MULHSU:  begin    dsp_opmode <= DSP_OPMODE_XM_YM_Z0;    dsp_alumode <= DSP_ALUMODE_ADD;     a_signex <= 1'b1;   b_signex = 1'b0;    out_mode <= OUT_MODE_H;  end
    endcase


assign dsp_a_in = { 30{b_signex & b_sign}};
assign dsp_b_in = {b_signex & b_sign, b_signex & b_sign,  b_in_override};
assign dsp_c_in = { {32{a_signex & a_sign}},              A_IN};
assign dsp_d_in = { {25{a_signex & a_sign}},              A_IN};

logic [DATA_WIDTH-1 : 0] alu_out_mux;


// result MUX: use low half, high half, or mix high|low part of result 
//assign alu_out_mux = out_mode_high_stage2 ? dsp_p_out[31:16] : ((dsp_p_out[31:16] & {16{out_mode_mix_stage2}}) | dsp_p_out[15:0]); 

assign alu_out_mux = ( {16{out_mode_stage2[1]}} & dsp_p_out[31:16] )   // higher part
                   | ( {16{out_mode_stage2[0]}} & dsp_p_out[15:0]  );  // lower part

logic [DATA_WIDTH-1:0] alu_out_stage2;
always_comb alu_out_stage2 <= { 
        is_rcr_stage2 ? flags_in_stage2[FLAG_C] : alu_out_mux[15],  // override for ROTATEC
        alu_out_mux[14:1],
        is_rcl_stage2 ? flags_in_stage2[FLAG_C] : alu_out_mux[0]     // override for ROTATEC
};

logic [3:0] new_flags;

always_comb new_flags[FLAG_C] <=
          is_left_shift_stage2 ? dsp_p_out[16] 
        : is_right_shift_stage2 ? dsp_p_out[15]
        : dsp_carryout;

always_comb new_flags[FLAG_Z] <= dsp_patterndetect;
always_comb new_flags[FLAG_S] <= alu_out_mux[DATA_WIDTH-1];
always_comb new_flags[FLAG_V] <= dsp_carryout != alu_out_mux[DATA_WIDTH-1];

logic [3:0] flags_stage2;
always_comb flags_stage2 <= (flags_in_stage2 & ~flags_mask_stage2) | (new_flags & flags_mask_stage2);

// result flags
logic [3:0] flags_stage3;
always_ff @(posedge CLK)
    if (RESET)
        flags_stage3 <= 'b0;
    else if (CE)
        flags_stage3 <= flags_stage2;
        
assign FLAGS_OUT = flags_stage3;

// result value
logic [DATA_WIDTH-1 : 0] alu_out_stage3;
always_ff @(posedge CLK)
    if (RESET | (CE & ~en_stage2))
        alu_out_stage3 <= 'b0;
    else if (CE)
        alu_out_stage3 <= alu_out_stage2;

assign ALU_OUT = alu_out_stage3;


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
