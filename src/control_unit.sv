`include "alu_ops.sv"
`include "control_ops.sv"

//------------------------------------------------------------
// Control Unit
//------------------------------------------------------------
// Controls the flow of data in the CPU
//------------------------------------------------------------
//
// Inputs
//      op: The instruction's opcode field
//   funct: The instruction's funct field
//
// Outputs
//         mem_write: Data memory write signal
//       mem_rw_size: Chooses how many bytes to read/write in data memory (2^n bytes, max 4)
//   mem_read_signed: Sign extends the value read from data memory (no effect on 4-byte value)
//         reg_write: Register file write signal
//       write_to_ra: Write to $ra (used with jal)
//           reg_dst: Write to $rt or $rd (0 or 1 respectively)
//        mem_to_reg: Write the output of data memory to register (alu result if 0)
//         pc_to_reg: Write the program counter to the register
//         branch_en: Enable branch testing
//   branch_zero_neq: Test if alu_zero is not equal to 1 (alu_result != 0)
//              jump: Set on jump opcodes (01 for target jump, 10 for register jump)
//           alu_src: Selects register data or immediate value for alu (0 or 1 respectively)
//       alu_control: ALU operation
//         use_shamt: Set on sll, srl, sra instructions
//   imm_extend_mode: 0 for zero-extend, 1 for sign-extend
//
//------------------------------------------------------------


//------------------------------------------------------------
// The following should always be set when an
// instruction is parsed
//------------------------------------------------------------
// reg_write
// mem_write
// branch_en
// jump
//------------------------------------------------------------


//------------------------------------------------------------
// If one of the following is enabled (set to 1) then their
// dependencies must be set
//------------------------------------------------------------
//  reg_write: reg_dst, mem_to_reg, pc_to_reg, write_to_ra, alu_src, alu_control, use_shamt
//  mem_write: mem_rw_size, alu_src, alu_control, use_shamt
// mem_to_reg: mem_rw_size, mem_read_signed
//    alu_src: imm_extend_mode
//  branch_en: branch_zero_neq
//------------------------------------------------------------

typedef enum logic [1:0] {
	J_NONE   = 2'b00,
	J_TARGET = 2'b01,
	J_REG    = 2'b10
} jump_signal;

module control_unit(input  logic [5:0] op,
                    input  logic [5:0] funct,
                    output logic       mem_write,
                    output logic [1:0] mem_rw_size,
                    output logic       mem_read_signed,
                    output logic       reg_write,
                    output logic       write_to_ra,
                    output logic       reg_dst,
                    output logic       mem_to_reg,
                    output logic       pc_to_reg,
                    output logic       branch_en,
                    output logic       branch_zero_neq,
                    output logic [1:0] jump,
                    output logic       alu_src,
                    output logic [3:0] alu_control,
                    output logic       use_shamt,
                    output logic       imm_extend_mode);

	logic       type_r;
	logic [3:0] alu_op;

	// Main Decoder
	main_decoder d_main(.op(op),
	                    .funct(funct),
	                    .mem_write(mem_write),
	                    .mem_rw_size(mem_rw_size),
	                    .mem_read_signed(mem_read_signed),
	                    .reg_write(reg_write),
                        .write_to_ra(write_to_ra),
	                    .reg_dst(reg_dst),
	                    .mem_to_reg(mem_to_reg),
                        .pc_to_reg(pc_to_reg),
	                    .branch_en(branch_en),
	                    .branch_zero_neq(branch_zero_neq),
	                    .jump(jump),
	                    .alu_src(alu_src),
	                    .type_r(type_r),
	                    .alu_op(alu_op));

	// ALU Decoder
	alu_decoder d_alu(.type_r(type_r),
	                  .funct(funct),
	                  .alu_op(alu_op),
	                  .alu_control(alu_control),
	                  .use_shamt(use_shamt),
	                  .imm_extend_mode(imm_extend_mode));

endmodule : control_unit




//------------------------------------------------------------
// Main Decoder
//------------------------------------------------------------
module main_decoder(input  logic [5:0] op,
                    input  logic [5:0] funct,
                    output logic       mem_write,
                    output logic [1:0] mem_rw_size,
                    output logic       mem_read_signed,
                    output logic       reg_write,
                    output logic       write_to_ra,
                    output logic       reg_dst,
                    output logic       mem_to_reg,
                    output logic       pc_to_reg,
                    output logic       branch_en,
                    output logic       branch_zero_neq,
                    output logic [1:0] jump,
                    output logic       alu_src,
                    output logic       type_r,
                    output logic [3:0] alu_op);

	always_comb begin
		type_r = (op == TYPE_R);

		case (op)
			TYPE_R: begin
				case (funct)
					JR:      exec_jr();
					JALR:    exec_jalr();
					default: exec_type_r_arithmetic();
				endcase
			end
			ADDI:   exec_addi();
			ADDIU:  exec_addiu();
			SLTI:   exec_slti();
			SLTIU:  exec_sltiu();
			ANDI:   exec_andi();
			ORI:    exec_ori();
			XORI:   exec_xori();
			LUI:    exec_lui();

			J:      exec_j();
			JAL:    exec_jal();
			BEQ:    exec_beq();
			BNE:    exec_bne();
			BLEZ:   exec_blez();
			BGTZ:   exec_bgtz();

			LB:     exec_lb();
			LH:     exec_lh();
			LW:     exec_lw();
			LBU:    exec_lbu();
			LHU:    exec_lhu();
			SB:     exec_sb();
			SH:     exec_sh();
			SW:     exec_sw();

			default: exec_noop();
		endcase
	end


	//------------------------------------------------------------
	// No-op
	//------------------------------------------------------------

	task exec_noop();
		reg_write = 0;
		mem_write = 0;
		branch_en = 0;
		jump      = J_NONE;
	endtask


	//------------------------------------------------------------
	// Type R Ops
	//------------------------------------------------------------

	task exec_type_r_arithmetic();
		mem_write   = 0;
		reg_write   = 1;
		write_to_ra = 0;
		reg_dst     = 1;
		mem_to_reg  = 0;
		pc_to_reg   = 0;
		branch_en   = 0;
		jump        = J_NONE;
		alu_src     = 0;
	endtask

	task exec_jr();
		mem_write = 0;
		reg_write = 0;
		jump      = J_REG;
	endtask

	task exec_jalr();
		mem_write   = 0;
		reg_write   = 1;
		write_to_ra = 0;
		reg_dst     = 1;
		pc_to_reg   = 1;
		jump        = J_REG;
	endtask


	//------------------------------------------------------------
	// Arithmetic Ops
	//------------------------------------------------------------

	task exec_arithmetic_imm();
		mem_write   = 0;
		reg_write   = 1;
		write_to_ra = 0;
		mem_to_reg  = 0;
		reg_dst     = 0;
		pc_to_reg   = 0;
		branch_en   = 0;
		jump        = J_NONE;
		alu_src     = 1;
	endtask
	

	task exec_addi();
		exec_arithmetic_imm();
		alu_op = ALU_ADD;
	endtask;

	task exec_addiu();
		exec_arithmetic_imm();
		alu_op = ALU_ADDU;
	endtask
	
	task exec_slti();
		exec_arithmetic_imm();
		alu_op = ALU_SLT;
	endtask

	task exec_sltiu();
		exec_arithmetic_imm();
		alu_op = ALU_SLTU;
	endtask

	task exec_andi();
		exec_arithmetic_imm();
		alu_op = ALU_AND;
	endtask

	task exec_ori();
		exec_arithmetic_imm();
		alu_op = ALU_OR;
	endtask

	task exec_xori();
		exec_arithmetic_imm();
		alu_op = ALU_XOR;
	endtask

	task exec_lui();
		exec_arithmetic_imm();
		alu_op = ALU_LUI;
	endtask


	//------------------------------------------------------------
	// Branch/Jump Ops
	//------------------------------------------------------------

	task exec_branch();
		mem_write       = 0;
		reg_write       = 0;
		branch_en       = 1;
		jump            = J_NONE;
		alu_src         = 0;
	endtask


	task exec_beq();
		exec_branch();
		branch_zero_neq = 0;
		alu_op          = ALU_SUBU;
	endtask

	task exec_bne();
		exec_branch();
		branch_zero_neq = 1;
		alu_op          = ALU_SUBU;
	endtask

	task exec_blez();
		exec_branch();
		branch_zero_neq = 0;
		alu_op          = ALU_SGT;
	endtask

	task exec_bgtz();
		exec_branch();
		branch_zero_neq = 0;
		alu_op          = ALU_SGT;
	endtask


	task exec_j();
		mem_write = 0;
		reg_write = 0;
		jump      = J_TARGET;
	endtask

	task exec_jal();
		mem_write   = 0;
		reg_write   = 1;
		write_to_ra = 1;
		pc_to_reg   = 1;
		jump        = J_TARGET;
	endtask


	//------------------------------------------------------------
	// Memory Access Ops
	//------------------------------------------------------------

	task exec_load();
		mem_write       = 0;
		reg_write       = 1;
		write_to_ra     = 0;
		reg_dst         = 0;
		mem_to_reg      = 1;
		pc_to_reg       = 0;
		branch_en       = 0;
		jump            = J_NONE;
		alu_src         = 1;
		alu_op          = ALU_ADDU;
	endtask

	task exec_store();
		mem_write   = 1;
		reg_write   = 0;
		branch_en   = 0;
		jump        = J_NONE;
		alu_src     = 1;
		alu_op      = ALU_ADDU;
	endtask


	task exec_lb();
		exec_load();
		mem_rw_size     = 2'b00;
		mem_read_signed = 1;
	endtask;

	task exec_lh();
		exec_load();
		mem_rw_size     = 2'b01;
		mem_read_signed = 1;
	endtask;

	task exec_lw();
		exec_load();
		mem_rw_size     = 2'b10;
		mem_read_signed = 0;
	endtask

	task exec_lbu();
		mem_rw_size     = 2'b00;
		mem_read_signed = 0;
	endtask;

	task exec_lhu();
		exec_load();
		mem_rw_size     = 2'b01;
		mem_read_signed = 0;
	endtask;


	task exec_sb();
		exec_store();
		mem_rw_size = 2'b00;
	endtask;

	task exec_sh();
		exec_store();
		mem_rw_size = 2'b01;
	endtask;

	task exec_sw();
		exec_store();
		mem_rw_size = 2'b10;
	endtask

endmodule : main_decoder




//------------------------------------------------------------
// ALU Decoder
//------------------------------------------------------------
module alu_decoder(input  logic       type_r,
                   input  logic [5:0] funct,
                   input  logic [3:0] alu_op,
                   output logic [3:0] alu_control,
                   output logic       use_shamt,
                   output logic       imm_extend_mode);

	always_comb begin
		// Decide ALU op based on funct if the instruction was type r
		if (type_r) begin : decode_type_r
			case (funct)
				AND:  alu_control = ALU_AND;
				OR:   alu_control = ALU_OR;
				NOR:  alu_control = ALU_NOR;
				XOR:  alu_control = ALU_XOR;

				ADD:  alu_control = ALU_ADD;
				SUB:  alu_control = ALU_SUB;
				ADDU: alu_control = ALU_ADDU;
				SUBU: alu_control = ALU_SUBU;
				
				SLT:  alu_control = ALU_SLT;
				SLTU: alu_control = ALU_SLTU;

				SLL, SLLV: alu_control = ALU_SLL;
				SRL, SRLV: alu_control = ALU_SRL;
				SRA, SRAV: alu_control = ALU_SRA;
			endcase

			// Use shamt for Type R shift immediate instructions
			case (funct)
				SLL, SRL, SRA: use_shamt = 1;
				default:       use_shamt = 0;
			endcase
		end : decode_type_r

		// The correct ALU op is set in the main decoder for type i instructions
		else begin
			alu_control = alu_op;
			use_shamt   = 0;
		end

		// Immediate extend mode for ALU input (zero/sign extend)
		case (alu_control)
			ALU_ADD, ALU_SUB, ALU_SLT, ALU_SGT: imm_extend_mode = 1;
			default: imm_extend_mode = 0;
		endcase
	end

endmodule : alu_decoder
