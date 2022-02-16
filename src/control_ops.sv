`ifndef CONTROL_OPS_SV
`define CONTROL_OPS_SV

typedef enum bit [5:0] {

	//Arithmetic
	TYPE_R = 6'b000000,
	ADDI   = 6'b001000,
	ADDIU  = 6'b001001,
	SLTI   = 6'b001010,
	SLTIU  = 6'b001011,
	ANDI   = 6'b001100,
	ORI    = 6'b001101,
	XORI   = 6'b001110,
	LUI    = 6'b001111,

	//Branch
	J      = 6'b000010,
	JAL    = 6'b000011,
	BEQ    = 6'b000100,
	BNE    = 6'b000101,
	BLEZ   = 6'b000110,
	BGTZ   = 6'b000111,

	//Memory Access
	LB     = 6'b100000,
	LH     = 6'b100001,
	//LWL    = 6'b100010,
	LW     = 6'b100011,
	LBU    = 6'b100100,
	LHU    = 6'b100101,
	//LWR    = 6'b100110,
	SB     = 6'b101000,
	SH     = 6'b101001,
	//SWL    = 6'b101010,
	SW     = 6'b101011
	//SWR    = 6'b101110

} OPCODE;


typedef enum bit [5:0] {

	ADD  = 6'b100000,
	ADDU = 6'b100001,
	SUB  = 6'b100010,
	SUBU = 6'b100011,

	AND  = 6'b100100,
	OR   = 6'b100101,
	NOR  = 6'b100111,
	XOR  = 6'b100110,
	
	SLT  = 6'b101010,
	SLTU = 6'b101011,

	SLL  = 6'b000000,
	SRL  = 6'b000010,
	SRA  = 6'b000011,
	SLLV = 6'b000100,
	SRLV = 6'b000110,
	SRAV = 6'b000111,
	
	JR   = 6'b001000,
	JALR = 6'b001001
	
} FUNCT;

`endif //CONTROL_OPS_SV
