`ifndef INSTRUCTION_SV
`define INSTRUCTION_SV

typedef struct packed {
	logic [5:0] op;
	logic [4:0] rs;
	logic [4:0] rt;
	logic [4:0] rd;
	logic [4:0] shamt;
	logic [5:0] funct;
} instruction_r;

typedef struct packed {
	logic [5:0]  op;
	logic [4:0]  rs;
	logic [4:0]  rt;
	logic [15:0] imm;
} instruction_i;

typedef struct packed {
	logic [5:0]  op;
	logic [25:0] target;
} instruction_j;

typedef union packed {
	instruction_r r;
	instruction_i i;
	instruction_j j;
} instruction_t;

`endif //INSTRUCTION_SV
