# Designing small but powerful Barrel CPU for using in FPGA

## When you may need softcore CPU in FPGA


## Increasing CPU speed: pipelining

## Traditional CPU pipeline

## Barrel CPU


## Design decisions


## Implementation


### 3-address operations

Many of ALU operations require two operands.

In many CPUs, 2-address instructions are used. It's destructive: result of binary operation overrides one of operands.

E.g. ADD A, B is implemented as A = A + B overriding previous value in register A


With 3-address instructions, value calculated based on two registers is being placed to third register

E.g. ADD A, B, C is implemented as A = B + C

3-address instructions decrease number of required instructions to implement the same algoririthm, but increase space in instruction required to specify all 3 registers.


### Number of registers

The more registers we have in CPU, the less LOAD/STORE operations will be required for the same algorithm.

8 registers is probably bare minimum.



In 3-address architecture, we need to store 3 register indexes for 3-address instructions.

With 8 regs, we need 3 bits for each register address, 3*3 = 9 bits only for register indexes.

With 16 regs, we need 4 bits for each register, 4*3 = 12 bits only for register indexes.

We will need ALU OP code in instruction, at least 4 bits. So, for 16 regs, 16 bits will be occupied only by register indexes and ALU opcode. Instruction length should be bigger.

In Barrel CPU, real number of registers in register bank are multiplied by number of threads.

With 8 registers per thread, 32 total registers should be stored in register bank. For 16 - 64 in total. The more regs, the more resources will be needed.

It makes sense to support some immediate constants inside instruction (power of two - single bit set - constants are must have for implementing shifts). At least, additional single bit is needed as immediate mode flag. One or more bits will be needed to specify immediate mode.

With 16 regs, single bit for imm mode allows to specify 16 constants (register index will be used as constant table index) - if const table contains only power of two values.

With 8 regs, we need at lease 2 immediate mode bits (e.g. mode 00 for register value, 01..11 for constants - 24 constants available).



### Flags

Flags are being updated as a result of ALU operations.

Other operations keep flags intact.

Minimal set of 4 flags is required for general purpse CPU.


	// flag indexes
	typedef enum logic[1:0] {
		FLAG_C,        // carry flag, 1 when there is carry out or borrow from ADD/SUB, or shifted out bit for shifts
		FLAG_Z,        // zero flag, set to 1 when all bits of result are zeroes
		FLAG_S,        // sign flag, meaningful for signed operations (usually derived from HSB of result, sign bit)
		FLAG_V         // signed overflow flag, meaningful for signed arithmetic operations
	} flag_index_t;
	typedef logic[3:0] bcpu_flags_t;



### Condition codes

To support conditional jumps, we need to encode conditions inside instruction.

Based on condition, we will check flags to decide if condition is met or no.

Following condition types are needed:

* Unconditional jumps
* Single flag test (number of flags * 2), for Z flag it's == and !=
* Unsigned comparision: Above, Above or Equal, Below, Below or Equal (>, >=, <, <=)
* Signed comparision: Less, Less or Equal, Greater, Greater or Equal (<, <=, >, >=)

4 bits are required to encode all condition codes we need.


		// condition codes for conditional jumps
		typedef enum logic[3:0] {
			COND_NONE = 4'b0000, // jmp  1                 unconditional
			
			COND_NC   = 4'b0001, // jnc  c = 0             for C==1 test, use JB code
			COND_NZ   = 4'b0010, // jnz  z = 0             jne                                        !=
			COND_Z    = 4'b0011, // jz   z = 1             je                                         ==

			COND_NS   = 4'b0100, // jns  s = 0
			COND_S    = 4'b0101, // js   s = 1
			COND_NO   = 4'b0110, // jno  v = 0
			COND_O    = 4'b0111, // jo   v = 1

			COND_A    = 4'b1000, // ja   c = 0 & z = 0     above (unsigned compare)            !jbe    >
			COND_AE   = 4'b1001, // jae  c = 0 | z = 1     above or equal (unsigned compare)           >=
			COND_B    = 4'b1010, // jb   c = 1             below (unsigned compare)            jc      <
			COND_BE   = 4'b1011, // jbe  c = 1 | z = 1     below or equal (unsigned compare)   !ja     <=

			COND_L    = 4'b1100, // jl   v != s            less (signed compare)                       <
			COND_LE   = 4'b1101, // jle  v != s | z = 1    less or equal (signed compare)      !jg     <=
			COND_G    = 4'b1110, // jg   v = s & z = 0     greater (signed compare)            !jle    >
			COND_GE   = 4'b1111  // jge  v = s | z = 1     less or equal (signed compare)              >=
		} jmp_condition_t;


### ALU operations

#### Arithmetic

* ADD: Addition
* ADDC: Addition with carry -- needed to implement higher precision arithmetic
* SUB: Subtraction
* SUBC: Subtraction with borrow -- needed to implement higher precision arithmetic
* INC: Increment - same as addition, but does not update Carry and Overflow flags
* DEC: Subtraction - same as addition, but does not update Carry and Overflow flags

Separate INC and DEC are needed to control flags update.


#### Logic

Needed to implement bit test, set, reset, toggle

* AND: bitwise AND, A & B
* ANDN: bitwise AND with inverted second operand, A & ~B
* OR: bitwise OR, A | B
* XOR: bitwise XOR, A ^ B

Individual bit operations

* AND - testing if bit is set
* ANDN - reset individual bit
* OR - set bit
* XOR - toggle bit


### LOAD / STORE / WAIT

### Peripherial access

00 1: Peripherial bus access

Up to 32 16-bit output regs : 
Up to 32 16-bit input regs


         r/w      type
		 |        |  
         |        |  
00 1 rrr w bbb mm t aaaaa
     |     |        | 
     |     |        |
     |     |         -- periph bus address
     |     |
     |      --- value B   MASK
     |
	  -- value A    VALUE or dest

address

optype

// input bus
00 BUSREAD   bus_addr, Rdst, MASK          puts read_value&mask to Rdst, calculate Z flag based on result
01 BUSWAIT   bus_addr, Rdst, MASK          same as read, but wait till (read_value & mask)!=0
// output bus
10 BUSWRITE  bus_addr, value, MASK
11 BUSTOGGLE bus_addr, value, MASK




