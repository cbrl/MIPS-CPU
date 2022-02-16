`ifndef SHIFTER_SV
`define SHIFTER_SV

module shifter #(parameter WIDTH)
                (input  logic [WIDTH-1:0] in,
                 input  logic [WIDTH-1:0] shift_amt,
                 output logic [WIDTH-1:0] out);

	always_comb out = in << shift_amt;

endmodule

`endif //SHIFTER_SV