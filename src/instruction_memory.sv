
//------------------------------------------------------------
// Instruction Memory
//------------------------------------------------------------
// Dedicated word-aligned memory for the CPU instructions
//------------------------------------------------------------
//
// Parameters
//   NUM_WORDS: The number of 32-bit words in the memory
//
// Inputs
//   addr: The address to read from
//
// Outputs
//   read_data: The data at the specified address
//
//------------------------------------------------------------
module instruction_memory #(parameter NUM_WORDS)
                           (input  logic [31:0] addr,
                            output logic [31:0] read_data);

	// 2D array of NUM_WORDS elements (32*NUM_WORDS bits)
	// Each element is 32 bits (4 bytes)
	bit [31:0] memory[NUM_WORDS-1 : 0];

	always_comb read_data = memory[addr[31:2]];

	/*
	initial begin
		$readmemh("memfile.dat", memory);
	end
	*/

endmodule
