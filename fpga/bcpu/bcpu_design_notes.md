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

In Barrel CPU, real number of registers in register bank are multiplied by number of threads.

With 8 registers per thread, 32 total registers should be stored in register bank.


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

