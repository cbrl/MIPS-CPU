`ifndef SIGN_EXTENDER_SV
`define SIGN_EXTENDER_SV

module sign_extender #(parameter IN,
                       parameter OUT)
                      (input  logic [IN-1:0]  in,
                       output logic [OUT-1:0] out);

	assign out = { {OUT-IN{in[IN-1]}}, in };

endmodule

`endif //SIGN_EXTENDER_SV