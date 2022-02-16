
//------------------------------------------------------------
// Data Memory
//------------------------------------------------------------
// The system memory module
//------------------------------------------------------------
//
// Parameters
//   NUM_WORDS: The number of 32-bit words in the memory module
//
// Inputs:
//          clk: triggers the write operation if write_en is 1
//        reset: resets the contents of the memory to 0
//         addr: the address of the memory to read or write
//     write_en: decides if data should be written to memory
//   write_size: writes 2^n bytes of data (max 4 bytes)
//   write_data: the data to write to memory
//
// Outputs:
//   read_data: the data at the address specified by addr
//
//------------------------------------------------------------

module data_memory #(parameter NUM_WORDS)
                    (input  logic        clk,
                     input  logic        reset,
                     input  logic [31:0] addr,
                     input  logic        write_en,
                     input  logic [1:0]  write_size,
                     input  logic [31:0] write_data,
                     output logic [31:0] read_data);

	// Packed 2d array totaling 4*NUM_WORDS elements
	// (32*NUM_WORDS bits). Each element is 8 bits (1 byte).
	bit [(4*NUM_WORDS)-1 : 0][7:0] memory = '0;

	always_ff @(posedge clk, posedge reset)
		if (reset) memory <= '0;
		else if (write_en) begin
			case (write_size)
				2'b00: memory[addr]    <= write_data[7:0];
				2'b01: memory[addr+:2] <= write_data[15:0];
				2'b10: memory[addr+:4] <= write_data;
			endcase
		end

	always_comb
		read_data = memory[addr+:4];

endmodule
