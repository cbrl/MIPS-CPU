
//------------------------------------------------------------
// Register File
//------------------------------------------------------------
// Contains the 32 registers used by the CPU
//------------------------------------------------------------
//
// Inputs
//          clk: Clock signal, writes to registers on a positive edge
//        reset: Reset signal, resets the register contents to 0
//        reg_1: The address of the first register ($rs)
//        reg_2: The address of the second register ($rt)
//        reg_3: The address of the register to write to ($rt or $rd)
//     write_en: Enables writing to the registers
//     write_ra: Write to $ra (used with jal)
//   write_data: The data to write to reg_3
//
// Outputs
//   reg_1_data: The data in reg_1
//   reg_2_data: The data in reg_2
//
//------------------------------------------------------------
module register_file(input  logic        clk,
                     input  logic        reset,
                     input  logic [4:0]  reg_1,
                     input  logic [4:0]  reg_2,
                     input  logic [4:0]  reg_3,
                     input  logic        write_en,
                     input  logic        write_ra,
                     input  logic [31:0] write_data,
                     output logic [31:0] reg_1_data,
                     output logic [31:0] reg_2_data);

	// 31x 32-bit registers. Register 0 is hard-coded to be 0.
	bit [31:1][31:0] registers;

	always_ff @(posedge clk, posedge reset) begin

		if (reset) begin
			registers <= '0;
		end
		else if (write_en) begin

			if (write_ra)
				registers[31] <= write_data;
			else if (reg_3 != 5'b0)
				registers[reg_3] <= write_data;
		end
	end

	always_comb begin
		// reg_1_data
		if (reg_1 == 5'b0) reg_1_data = '0;
		else reg_1_data = registers[reg_1];

		// reg_2_data
		if (reg_2 == 5'b0) reg_2_data = '0;
		else reg_2_data = registers[reg_2];
	end

endmodule


//Conventional register layout
//registers[1]  = $at
//registers[2]  = $v0
//registers[3]  = $v1
//registers[4]  = $a0
//registers[5]  = $a1
//registers[6]  = $a2
//registers[7]  = $a3
//registers[8]  = $t0
//registers[9]  = $t1
//registers[10] = $t2
//registers[11] = $t3
//registers[12] = $t4
//registers[13] = $t5
//registers[14] = $t6
//registers[15] = $t7
//registers[16] = $s0
//registers[17] = $s1
//registers[18] = $s2
//registers[19] = $s3
//registers[20] = $s4
//registers[21] = $s5
//registers[22] = $s6
//registers[23] = $s7
//registers[24] = $t8
//registers[25] = $t9
//registers[26] = $k0
//registers[27] = $k1
//registers[28] = $gp
//registers[29] = $sp
//registers[30] = $fp
//registers[31] = $ra
