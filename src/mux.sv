`ifndef MUX_SV
`define MUX_SV

module mux2 #(parameter WIDTH)
             (input  logic [WIDTH-1:0] a,
              input  logic [WIDTH-1:0] b,
              input  logic             select,
              output logic [WIDTH-1:0] out);

	always_comb out = select ? b : a;

endmodule : mux2


module mux4 #(parameter WIDTH)
             (input  logic [WIDTH-1:0] a,
              input  logic [WIDTH-1:0] b,
              input  logic [WIDTH-1:0] c,
              input  logic [WIDTH-1:0] d,
              input  logic [1:0]       select,
              output logic [WIDTH-1:0] out);

	always_comb
		case (select)
			0'b00: out = a;
			0'b01: out = b;
			0'b10: out = c;
			0'b11: out = d;
			default: out = {WIDTH{1'bx}};
		endcase

endmodule : mux4

`endif //MUX_SV