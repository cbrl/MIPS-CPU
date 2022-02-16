`include "mux.sv"

//------------------------------------------------------------
// Branch Tester
//------------------------------------------------------------
// Determintes if a branch should be taken.
//------------------------------------------------------------
//
// Inputs:
//   branch_en: enables the test
//    zero_neq: chooses the test mode (alu_zero eq/neq to 0)
//    alu_zero: set to 1 if the result of the ALU op was 0
//
// Outputs:
//   branch: set to 1 if the CPU should branch
//
//------------------------------------------------------------

module branch_tester(input  logic branch_en,
                     input  logic zero_neq,
                     input  logic alu_zero,
                     output logic branch);

	logic zero_test_out;
	mux2 #(.WIDTH(1)) zero_test(.a(alu_zero),
	                            .b(~alu_zero),
	                            .select(zero_neq),
	                            .out(zero_test_out));

	always_comb branch = branch_en & zero_test_out;

endmodule
