#pragma once


enum Opcode : uint8_t {
	//Arithmetic
	TYPE_R = 0b000000,
	ADDI   = 0b001000,
	ADDIU  = 0b001001,
	SLTI   = 0b001010,
	SLTIU  = 0b001011,
	ANDI   = 0b001100,
	ORI    = 0b001101,
	XORI   = 0b001110,
	LUI    = 0b001111,

	//Branch
	J      = 0b000010,
	JAL    = 0b000011,
	BEQ    = 0b000100,
	BNE    = 0b000101,
	BLEZ   = 0b000110,
	BGTZ   = 0b000111,

	//Memory Access
	LB     = 0b100000,
	LH     = 0b100001,
	//LWL    = 0b100010,
	LW     = 0b100011,
	LBU    = 0b100100,
	LHU    = 0b100101,
	//LWR    = 0b100110,
	SB     = 0b101000,
	SH     = 0b101001,
	//SWL    = 0b101010,
	SW     = 0b101011,
	//SWR    = 0b101110,
};


enum Funct : uint8_t {
	NONE = 0,
	ADD  = 0b100000,
	ADDU = 0b100001,
	SUB  = 0b100010,
	SUBU = 0b100011,

	AND  = 0b100100,
	OR   = 0b100101,
	NOR  = 0b100111,
	XOR  = 0b100110,
	
	SLT  = 0b101010,
	SLTU = 0b101011,

	SLL  = 0b000000,
	SRL  = 0b000010,
	SRA  = 0b000011,
	SLLV = 0b000100,
	SRLV = 0b000110,
	SRAV = 0b000111,
	
	JR   = 0b001000,
	JALR = 0b001001,
};


enum Register : uint8_t {
	zero = 0,
	at   = 1,
	v0   = 2,
	v1   = 3,
	a0   = 4,
	a1   = 5,
	a2   = 6,
	a3   = 7,
	t0   = 8,
	t1   = 9,
	t2   = 10,
	t3   = 11,
	t4   = 12,
	t5   = 13,
	t6   = 14,
	t7   = 15,
	s0   = 16,
	s1   = 17,
	s2   = 18,
	s3   = 19,
	s4   = 20,
	s5   = 21,
	s6   = 22,
	s7   = 23,
	t8   = 24,
	t9   = 25,
	k0   = 26,
	k1   = 27,
	gp   = 28,
	sp   = 29,
	fp   = 30,
	ra   = 31,
};


constexpr uint32_t CreateInstructionR(Register rs, Register rt, Register rd, uint8_t shamt, Funct funct) {
	constexpr uint8_t bitmask_6 = 0b00111111;
	constexpr uint8_t bitmask_5 = 0b00011111;
	
	uint32_t instruction = 0;
	instruction |= ((Opcode::TYPE_R & bitmask_6) << 26);
	instruction |= ((rs & bitmask_5) << 21);
	instruction |= ((rt & bitmask_5) << 16);
	instruction |= ((rd & bitmask_5) << 11);
	instruction |= ((shamt & bitmask_5) << 6);
	instruction |= (funct & bitmask_6);

	return instruction;
}


constexpr uint32_t CreateInstructionI(Opcode op, Register rs, Register rt, uint16_t immediate) {
	constexpr uint8_t bitmask_6 = 0b00111111;
	constexpr uint8_t bitmask_5 = 0b00011111;
	
	uint32_t instruction = 0;
	instruction |= ((op & bitmask_6) << 26);
	instruction |= ((rs & bitmask_5) << 21);
	instruction |= ((rt & bitmask_5) << 16);
	instruction |= immediate;

	return instruction;
}


constexpr uint32_t CreateInstructionJ(Opcode op, uint32_t target) {
	constexpr uint8_t  bitmask_6  = 0b00111111;
	constexpr uint32_t bitmask_26 = 0xFFFFFFFF >> 6;
	
	uint32_t instruction = 0;
	instruction |= ((op & bitmask_6) << 26);
	instruction |= (target & bitmask_26);

	return instruction;
}



struct iInstruction {
public:
	virtual explicit operator uint32_t() const noexcept = 0;
};

struct InstructionR final : public iInstruction {
public:
	//------------------------------------------------------------
	// Constructors
	//------------------------------------------------------------
	constexpr InstructionR() noexcept = default;

	constexpr InstructionR(uint32_t instruction) noexcept
		: rs(static_cast<uint8_t>(instruction >> 21) & 0b00011111)
		, rt(static_cast<uint8_t>(instruction >> 16) & 0b00011111)
		, rd(static_cast<uint8_t>(instruction >> 11) & 0b00011111)
		, shamt(static_cast<uint8_t>(instruction >> 6) & 0b00011111)
		, funct(static_cast<uint8_t>(instruction) & 0b00111111) {
	}

	constexpr InstructionR(Register rs, Register rt, Register rd, uint8_t shamt, Funct funct) noexcept
		: rs(rs << 3)
		, rt(rt << 3)
		, rd(rd << 3)
		, shamt(shamt << 3)
		, funct(funct << 2) {
	}

	constexpr InstructionR(const InstructionR&) noexcept = default;
	constexpr InstructionR(InstructionR&&) noexcept = default;


	//------------------------------------------------------------
	// Destructor
	//------------------------------------------------------------
	~InstructionR() = default;


	//------------------------------------------------------------
	// Operators
	//------------------------------------------------------------
	constexpr InstructionR& operator=(const InstructionR&) noexcept = default;
	constexpr InstructionR& operator=(InstructionR&&) noexcept = default;

	constexpr explicit operator uint32_t() const noexcept override {
		uint32_t out = 0;
		out |= static_cast<uint32_t>(Opcode::TYPE_R) << 26;
		out |= static_cast<uint32_t>(rs) << 21;
		out |= static_cast<uint32_t>(rt) << 16;
		out |= static_cast<uint32_t>(rd) << 11;
		out |= static_cast<uint32_t>(shamt) << 6;
		out |= funct;
		return out;
	}


	//------------------------------------------------------------
	// Member Variables
	//------------------------------------------------------------
	uint8_t rs         : 5 = 0;
	uint8_t rt         : 5 = 0;
	uint8_t rd         : 5 = 0;
	uint8_t shamt      : 5 = 0;
	uint8_t funct      : 6 = 0;
};


struct InstructionI final : public iInstruction {
public:
	//------------------------------------------------------------
	// Constructors
	//------------------------------------------------------------
	constexpr InstructionI() noexcept = default;

	constexpr InstructionI(uint32_t instruction) noexcept
		: op(static_cast<uint8_t>(instruction >> 26) & 0b00111111)
		, rs(static_cast<uint8_t>(instruction >> 21) & 0b00011111)
		, rt(static_cast<uint8_t>(instruction >> 16) & 0b00011111)
		, immediate(static_cast<uint16_t>(instruction)) {
	}

	constexpr InstructionI(Opcode op, Register rs, Register rt, uint16_t immediate) noexcept
		: op(op << 2)
		, rs(rs << 3)
		, rt(rt << 3)
		, immediate(immediate) {
	}

	constexpr InstructionI(const InstructionI&) noexcept = default;
	constexpr InstructionI(InstructionI&&) noexcept = default;


	//------------------------------------------------------------
	// Destructor
	//------------------------------------------------------------
	~InstructionI() = default;


	//------------------------------------------------------------
	// Operators
	//------------------------------------------------------------
	constexpr InstructionI& operator=(const InstructionI&) noexcept = default;
	constexpr InstructionI& operator=(InstructionI&&) noexcept = default;

	constexpr explicit operator uint32_t() const noexcept override {
		uint32_t out = 0;
		out |= static_cast<uint32_t>(op) << 26;
		out |= static_cast<uint32_t>(rs) << 21;
		out |= static_cast<uint32_t>(rt) << 16;
		out |= immediate;
		return out;
	}


	//------------------------------------------------------------
	// Member Variables
	//------------------------------------------------------------
	uint8_t  op        : 6 = 0;
	uint8_t  rs        : 5 = 0;
	uint8_t  rt        : 5 = 0;
	uint16_t immediate     = 0;
};


struct InstructionJ final : public iInstruction {
public:
	//------------------------------------------------------------
	// Constructors
	//------------------------------------------------------------
	constexpr InstructionJ() noexcept = default;

	constexpr InstructionJ(uint32_t instruction) noexcept
		: op(static_cast<uint8_t>(instruction >> 26) & 0b00111111)
		, target(instruction & (0xFFFFFFFF >> 6)) {
	}

	constexpr InstructionJ(Opcode op, uint32_t target) noexcept
		: op(op << 2)
		, target(target & (0xFFFFFFFF >> 6)) {
	}

	constexpr InstructionJ(const InstructionJ&) noexcept = default;
	constexpr InstructionJ(InstructionJ&&) noexcept = default;


	//------------------------------------------------------------
	// Destructor
	//------------------------------------------------------------
	~InstructionJ() = default;


	//------------------------------------------------------------
	// Operators
	//------------------------------------------------------------
	constexpr InstructionJ& operator=(const InstructionJ&) noexcept = default;
	constexpr InstructionJ& operator=(InstructionJ&&) noexcept = default;

	constexpr explicit operator uint32_t() const noexcept override {
		uint32_t out = 0;
		out |= static_cast<uint32_t>(op) << 26;
		out |= target;
		return out;
	}


	//------------------------------------------------------------
	// Member Variables
	//------------------------------------------------------------
	uint8_t  op     : 6  = 0;
	uint32_t target : 26 = 0;
};