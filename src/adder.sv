`ifndef ADDER_SV
`define ADDER_SV

module adder #(parameter WIDTH)
             (input  logic [WIDTH-1:0] a,
              input  logic [WIDTH-1:0] b,
              output logic [WIDTH-1:0] out);

	always_comb out = a + b;

endmodule : adder

`endif //ADDER_SV