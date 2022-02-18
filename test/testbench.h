#pragma once

#include <memory>
#include <iterator>

#include <verilated.h>
#include <verilated_fst_c.h>
//#include <verilated_vcd_c.h>
#include "../obj_dir/Vcpu.h"

#include "instructions.h"


template<typename ModuleT, typename TraceT>
class Testbench {
public:

	//------------------------------------------------------------
	// Constructors
	//------------------------------------------------------------
	Testbench() {
		Verilated::traceEverOn(true);
		core = std::make_unique<ModuleT>();
	}

	Testbench(const Testbench&) = delete;
	Testbench(Testbench&&) noexcept = default;


	//------------------------------------------------------------
	// Destructor
	//------------------------------------------------------------
	virtual ~Testbench() {
		trace->close();
	}


	//------------------------------------------------------------
	// Operators
	//------------------------------------------------------------
	Testbench& operator=(const Testbench&) = delete;
	Testbench& operator=(Testbench&&) noexcept = default;


	//------------------------------------------------------------
	// Member Functions
	//------------------------------------------------------------
	virtual void openTrace(const char* file) {
		if (!trace) {
			trace = std::make_unique<TraceT>();
			core->trace(trace.get(), 99);
			trace->open(file);
		}
	}

	virtual void reset() {
		core->reset = 1;
		this->tick();
		core->reset = 0;
	}

	virtual void tick() {
		for (int i = 0; i <= 1; ++i) {
			core->clk = i;
			core->eval();
			if (trace) trace->dump(2*ticks + i);
		}

		trace->flush();
		ticks++;
	}

	virtual bool done() {
		return Verilated::gotFinish();
	}

protected:

	//------------------------------------------------------------
	// Member Variables
	//------------------------------------------------------------
	uint64_t ticks = 0;
	std::unique_ptr<ModuleT> core;
	std::unique_ptr<TraceT> trace;
};


class MIPSTestbench final : public Testbench<Vcpu, VerilatedFstC> {
public:
	void setInstruction(size_t pos, uint32_t instruction) {
		core->mips_cpu__DOT__instr_mem__DOT__memory[pos] = instruction;
	}

	void setRegister(size_t reg, uint32_t data) {
		assert(reg != 0 && reg <= 31);
		if (reg == 0 || reg > 31) return;
		core->mips_cpu__DOT__reg_file__DOT__registers[reg] = data;
	}

	void setMemory(size_t pos, uint8_t data) {
		core->mips_cpu__DOT__data_mem__DOT__memory[pos] = data;
	}
};
