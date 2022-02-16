`ifndef ZERO_EXTENDER_SV
`define ZERO_EXTENDER_SV

module zero_extender #(parameter IN,
                       parameter OUT)
                      (input  logic [IN-1:0]  in,
	                   output logic [OUT-1:0] out);

	assign out = { {OUT-IN{1'b0}}, in };

endmodule

`endif //ZERO_EXTENDER_SV