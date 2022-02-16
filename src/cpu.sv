//https://en.wikipedia.org/wiki/MIPS_architecture#MIPS_I
//https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats#Opcodes
//https://inst.eecs.berkeley.edu/~cs61c/resources/MIPS_help.html

//http://www.ece.uah.edu/~gaede/cpe526/SystemVerilog_3.1a.pdf
//https://www.doulos.com/knowhow/sysverilog/tutorial/

`include "instruction.sv"

`include "control_unit.sv"
`include "alu.sv"
`include "register_file.sv"
`include "instruction_memory.sv"
`include "data_memory.sv"
`include "branch_tester.sv"

`include "mux.sv"
`include "shifter.sv"
`include "adder.sv"

module mips_cpu(input logic clk,
                input logic reset);

	//------------------------------------------------------------
	// Variables
	//------------------------------------------------------------
	
	// Program Counter
	logic [31:0] pc = '0;
	logic [31:0] pc_next;
	logic [31:0] pc_plus_4;
	logic [31:0] pc_branch;
	logic [31:0] branch_mux_out;

	// Instruction
	instruction_t instruct;

	// Control Unit
	logic       mem_write;
	logic [1:0] mem_rw_size;
	logic       mem_read_signed;
	logic       reg_write;
	logic       reg_dst;
	logic       mem_to_reg;
	logic       pc_to_reg;
	logic       pc_to_ra;
	logic       branch_en;
	logic       branch_zero_neq;
	logic [1:0] jump;
	logic       alu_src;
	logic [3:0] alu_control;
	logic       use_shamt;
	logic       imm_extend_mode;

	// Register File
	logic [31:0] reg_1_data;
	logic [31:0] reg_2_data;
	logic [4:0]  reg_3_addr;
	logic [31:0] alu_or_mem_output;
	logic [31:0] reg_write_data;

	// ALU
	logic [31:0] alu_src_b;
	logic [31:0] alu_result;
	logic        alu_zero;

	// Data Memory
	logic [31:0] data_mem_out;
	logic [31:0] data_mem_sign_extend_1b;
	logic [31:0] data_mem_zero_extend_1b;
	logic [31:0] data_mem_read_1b;
	logic [31:0] data_mem_sign_extend_2b;
	logic [31:0] data_mem_zero_extend_2b;
	logic [31:0] data_mem_read_2b;
	logic [31:0] data_mem_read;
	
	// Branch Tester
	logic branch;

	// Instruction Immediate Extend
	logic [31:0] imm_sign_extend;
	logic [31:0] imm_zero_extend;
	logic [31:0] alu_imm_extend;

	// Immediate Sign Extend << 2
	logic [31:0] sign_extend_shift_2;


	//------------------------------------------------------------
	// Program Counter Logic
	//------------------------------------------------------------

	// PC + 4
	adder #(.WIDTH(32)) pc_4_adder(
		.a(pc),
		.b(32'b100),
		.out(pc_plus_4)
	);

	// Sign Extend << 2
	shifter #(.WIDTH(32)) sign_extend_shifter(
		.in(imm_sign_extend),
		.shift_amt(32'b10),
		.out(sign_extend_shift_2)
	);

	// PC Branch ((sign_extend << 2) + (PC + 4))
	adder #(.WIDTH(32)) pc_branch_adder(
		.a(sign_extend_shift_2),
		.b(pc_plus_4),
		.out(pc_branch)
	);

	// Branch Tester
	branch_tester branch_test(
		.branch_en(branch_en),
		.zero_neq(branch_zero_neq),
		.alu_zero(alu_zero),
		.branch(branch)
	);

	// Branch mux
	mux2 #(.WIDTH(32)) branch_mux(
		.a(pc_plus_4),
		.b(pc_branch),
		.select(branch),
		.out(branch_mux_out)
	);

	// Jump mux
	// pc_jump = { (pc+4)[31:28], 28'b(target) << 2 }
	mux4 #(.WIDTH(32)) jump_mux(
		.a(branch_mux_out),
		.b( {pc_plus_4[31:28], instruct.j.target, 2'b00} ),
		.c(reg_1_data),
		.d(32'bx),
		.select(jump),
		.out(pc_next)
	);

	// update pc
	always_ff @(posedge clk, posedge reset) begin
		if (reset) pc <= '0;
		else       pc <= pc_next;
	end
	

	//------------------------------------------------------------
	// Instruction Memory
	//------------------------------------------------------------
	instruction_memory #(.NUM_WORDS(512)) instr_mem(.addr(pc), .read_data(instruct));


	//------------------------------------------------------------
	// Control Unit
	//------------------------------------------------------------
	control_unit ctrl_unit(
		.op(instruct.r.op),
		.funct(instruct.r.funct),
		.mem_write(mem_write),
		.mem_rw_size(mem_rw_size),
		.mem_read_signed(mem_read_signed),
		.reg_write(reg_write),
		.write_to_ra(pc_to_ra),
		.reg_dst(reg_dst),
		.mem_to_reg(mem_to_reg),
		.pc_to_reg(pc_to_reg),
		.branch_en(branch_en),
		.branch_zero_neq(branch_zero_neq),
		.jump(jump),
		.alu_src(alu_src),
		.alu_control(alu_control),
		.use_shamt(use_shamt),
		.imm_extend_mode(imm_extend_mode)
	);


	//------------------------------------------------------------
	// Register File Logic
	//------------------------------------------------------------

	// Register 3 address mux - selects rt or rd for reg_file.reg_3
	mux2 #(.WIDTH(5)) reg_3_mux(
		.a(instruct.r.rt),
		.b(instruct.r.rd),
		.select(reg_dst),
		.out(reg_3_addr)
	);

	// mem_to_reg mux - selects alu_result or data_mem.read_data
	mux2 #(.WIDTH(32)) mem_to_reg_mux(
		.a(alu_result),
		.b(data_mem_read),
		.select(mem_to_reg),
		.out(alu_or_mem_output)
	);

	// pc_to_reg mux - selects alu/memory output or pc+4 for reg_file.write_data
	mux2 #(.WIDTH(32)) pc_to_reg_mux(
		.a(alu_or_mem_output),
		.b(pc_plus_4),
		.select(pc_to_reg),
		.out(reg_write_data)
	);

	// Register File
	register_file reg_file(
		.clk(clk),
		.reset(reset),
		.reg_1(instruct.r.rs),
		.reg_2(instruct.r.rt),
		.reg_3(reg_3_addr),
		.write_en(reg_write),
		.write_ra(pc_to_ra),
		.write_data(reg_write_data),
		.reg_1_data(reg_1_data),
		.reg_2_data(reg_2_data)
	);


	//------------------------------------------------------------
	// ALU Logic
	//------------------------------------------------------------

	// Instruction immediate extend mux
	mux2 #(.WIDTH(32)) imm_extend_mux(
		.a(imm_zero_extend),
		.b(imm_sign_extend),
		.select(imm_extend_mode),
		.out(alu_imm_extend)
	);

	// ALU src_b mux - selects reg_2_data or imm_extend for alu.src_b
	mux2 #(.WIDTH(32)) alu_src_b_mux(
		.a(reg_2_data),
		.b(alu_imm_extend),
		.select(alu_src),
		.out(alu_src_b)
	);

	// ALU
	al_unit alu(
		.src_a(reg_1_data),
		.src_b(alu_src_b),
		.shamt(instruct.r.shamt),
		.control(alu_control),
		.use_shamt(use_shamt),
		.result(alu_result),
		.zero(alu_zero)
	);


	//------------------------------------------------------------
	// Data Memory Logic
	//------------------------------------------------------------
	data_memory #(.NUM_WORDS(512)) data_mem(
		.clk(clk),
		.reset(reset),
		.addr(alu_result),
		.write_en(mem_write),
		.write_size(mem_rw_size),
		.write_data(reg_2_data),
		.read_data(data_mem_out)
	);

	// 8 bit extend logic
	sign_extender #(.IN(8), .OUT(32)) data_sign_extend_1b(
		.in(data_mem_out[7:0]),
		.out(data_mem_sign_extend_1b)
	);

	zero_extender #(.IN(8), .OUT(32)) data_zero_extend_1b(
		.in(data_mem_out[7:0]),
		.out(data_mem_zero_extend_1b)
	);

	mux2 #(.WIDTH(32)) data_read_1b_mux(
		.a(data_mem_zero_extend_1b),
		.b(data_mem_sign_extend_1b),
		.select(mem_read_signed),
		.out(data_mem_read_1b)
	);

	// 16 bit extend logic
	sign_extender #(.IN(16), .OUT(32)) data_sign_extend_2b(
		.in(data_mem_out[15:0]),
		.out(data_mem_sign_extend_2b)
	);

	zero_extender #(.IN(16), .OUT(32)) data_zero_extend_2b(
		.in(data_mem_out[15:0]),
		.out(data_mem_zero_extend_2b)
	);

	mux2 #(.WIDTH(32)) data_read_2b_mux(
		.a(data_mem_zero_extend_2b),
		.b(data_mem_sign_extend_2b),
		.select(mem_read_signed),
		.out(data_mem_read_2b)
	);

	// Select 8/16/32 bit read data
	mux4 #(.WIDTH(32)) data_read_mux(
		.a(data_mem_read_1b),
		.b(data_mem_read_2b),
		.c(data_mem_out),
		.d(32'bx),
		.select(mem_rw_size),
		.out(data_mem_read)
	);


	//------------------------------------------------------------
	// Instruction Immediate Sign/Zero Extend Logic
	//------------------------------------------------------------
	sign_extender #(.IN(16), .OUT(32)) sign_extend(
		.in(instruct.i.imm),
		.out(imm_sign_extend)
	);

	zero_extender #(.IN(16), .OUT(32)) zero_extend(
		.in(instruct.i.imm),
		.out(imm_zero_extend)
	);

endmodule
