`include "instruction.sv"
`include "control_ops.sv"

module mips_testbench();

	logic clk   = 0;
	logic reset = 0;

	mips_cpu cpu(.clk(clk), .reset(reset));

	always #100 clk = ~clk;

	initial begin
		reset = 1;
		#90;
		reset = 0;
	end
	

	initial begin
		$readmemh("program1.dat", cpu.instr_mem.memory);

		/*
		static instruction_t instr;

		// 0x0: jal 0x10
		instr = '0;
		instr.j.op = JAL;
		instr.j.target = 26'b100;
		cpu.instr_mem.memory[0] = instr;

		// 0x4: addi $02, $0, 20
		instr = '0;
		instr.i.op = ADDI;
		instr.i.rs = 5'b0;
		instr.i.rt = 5'b10;
		instr.i.imm = 16'h14;
		cpu.instr_mem.memory[1] = instr;

		// 0x8: jalr $01, $02
		// $02 = 0x14
		instr = '0;
		instr.r.op = TYPE_R;
		instr.r.rs = 5'b10;
		instr.r.rd = 5'b1;
		instr.r.funct = JALR;
		cpu.instr_mem.memory[2] = instr;

		// 0xC: j 0x0
		instr = '0;
		instr.j.op = J;
		instr.j.target = 32'b0;
		cpu.instr_mem.memory[3] = instr;

		// 0x10: jr $31 ($31 = $ra)
		instr = '0;
		instr.r.op = TYPE_R;
		instr.r.rs = 5'b11111;
		instr.r.funct = JR;
		cpu.instr_mem.memory[4] = instr;

		//0x14: jr $01
		instr = '0;
		instr.r.op = TYPE_R;
		instr.r.rs = 5'b1;
		instr.r.funct = JR;
		cpu.instr_mem.memory[5] = instr;
		*/
	end

endmodule
