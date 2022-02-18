#include <iostream>
#include "testbench.h"

int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);

	MIPSTestbench testbench;
	testbench.openTrace("sim_data.fst");

	testbench.reset();

	//constexpr InstructionI i;
	//constexpr InstructionJ j;
	//constexpr InstructionR r;

	constexpr uint32_t instructions[] = {
		CreateInstructionI(Opcode::ORI,  Register::zero, Register::t0,   0x8000),
		CreateInstructionI(Opcode::ADDI, Register::zero, Register::t1,   0x8000),
		CreateInstructionI(Opcode::ORI,  Register::t0,   Register::t2,   0x8001),
		CreateInstructionI(Opcode::BEQ,  Register::t0,   Register::t1,   5),
		CreateInstructionR(Register::t1, Register::t0,   Register::t3,   0, Funct::SLT),
		CreateInstructionI(Opcode::BNE,  Register::t3,   Register::zero, 1),
		CreateInstructionJ(Opcode::J, 8),
		CreateInstructionR(Register::t2, Register::t0,   Register::t2,   0, Funct::SUB),
		CreateInstructionI(Opcode::ORI,  Register::t0,   Register::t0,   0xFF),
		CreateInstructionR(Register::t3, Register::t2,   Register::t3,   0, Funct::ADD),
		CreateInstructionR(Register::t2, Register::t0,   Register::t0,   0, Funct::SUBU),
		CreateInstructionI(Opcode::SW,   Register::t3,   Register::t0,   0x52)
	};

	for (size_t i = 0; i < std::size(instructions); ++i) {
		testbench.setInstruction(i, instructions[i]);
	}

	while (!testbench.done()) {
		testbench.tick();
	}

	return 0;
}
