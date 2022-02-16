`include "alu_ops.sv"

//------------------------------------------------------------
// ALU
//------------------------------------------------------------
// Performs arithmetic/logic operations on input data
//------------------------------------------------------------
//
// Inputs:
//       src_a: The first operand
//       src_b: The second operand
//       shamt: The shamt field of the instruction
//     control: Decides which operation to perform
//   use_shamt: If enabled, shifts src_b by shamt (used with type-r shift immediate instructions)
//
// Outputs:
//      result: The result of the operation
//        zero: Set to 1 if the result is 0
//   exception: Set to 1 if a signed operation overflowed
//
//------------------------------------------------------------

module al_unit(input  logic [31:0] src_a,
               input  logic [31:0] src_b,
               input  logic [4:0]  shamt,
               input  logic [3:0]  control,
               input  logic        use_shamt,
               output logic [31:0] result,
               output logic        zero,
               output logic        exception);

	always_comb begin

		// Calculate the result
		case (control)
			ALU_ADD, ALU_ADDU: result = src_a + src_b;
			ALU_SUB, ALU_SUBU: result = src_a - src_b;

			ALU_AND:  result = src_a & src_b;
			ALU_OR:   result = src_a | src_b;
			ALU_NOR:  result = ~(src_a | src_b);
			ALU_XOR:  result = src_a ^ src_b;

			ALU_SLT:  result = {31'b0, $signed(src_a) < $signed(src_b)};
			ALU_SLTU: result = {31'b0, $unsigned(src_a) < $unsigned(src_b)};
			ALU_SGT:  result = {31'b0, $signed(src_a) > $signed(src_b)};
			ALU_SGTU: result = {31'b0, $unsigned(src_a) > $unsigned(src_b)};
			
			ALU_SLL:  result = use_shamt ? src_b << shamt : src_a << src_b;
			ALU_SRL:  result = use_shamt ? src_b >> shamt : src_a >> src_b;
			ALU_SRA:  result = use_shamt ? src_b >>> shamt : src_a >>> src_b;

			ALU_LUI:  result = src_b << 16;
		endcase

		// Set zero to 1 if the result is zero
		zero = (result == 0);

		// Set exception to 1 if the signed addition/subtraction overflowed
		case (control)
			ALU_ADD: begin
				// overflow = ((a+b)^a & (a+b)^b) < 0
				exception = (result[31] ^ src_a[31]) & (result[31] ^ src_b[31]);
			end
			ALU_SUB: begin
				// overflow = ((a+b)^a & (a+b)^~b) < 0
				exception = (result[31] ^ src_a[31]) & (result[31] ^ ~src_b[31]);
			end
			default: exception = 0;
		endcase
	end

endmodule
