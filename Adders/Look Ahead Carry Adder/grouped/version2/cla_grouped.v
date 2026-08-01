module cla_grouped #(
    parameter int BIT_WIDTH  = 16,
    parameter int GROUP_SIZE = 4
) (
    input  logic [BIT_WIDTH-1:0] A,
    input  logic [BIT_WIDTH-1:0] B,
    input  logic                 Cin,
    output logic [BIT_WIDTH-1:0] SUM,
    output logic                 CARRY
);

    localparam int NUM_GROUPS = BIT_WIDTH / GROUP_SIZE;

    logic [BIT_WIDTH-1:0] g, p;
    logic [NUM_GROUPS-1:0] grp_g, grp_p;
    logic [NUM_GROUPS:0]   grp_c;   // carry into each group
    logic [BIT_WIDTH-1:0]  bit_c;   // carry into each bit

    assign g = A & B;
    assign p = A ^ B;

    assign grp_c[0] = Cin;


    genvar gi;
    generate
        for (gi = 0; gi < NUM_GROUPS; gi++) begin : gen_groups
            calc_group_c#(GROUP_SIZE)(
                g[i*(GROUP_SIZE-1) +: (GROUP_SIZE+1)],
                p[i*(GROUP_SIZE-1) +: (GROUP_SIZE+1)],
                grp_c[i],
                grp_c[i+1]);
        end
    endgenerate

    genvar bi;
    generate
        for (bi = 0; bi < BIT_WIDTH; bi++) begin : gen_bits
            assign bit_c[bi] = calc_group_c(bi, g, p, grp_c[bi / GROUP_SIZE]);
            assign SUM[bi]   = p[bi] ^ bit_c[bi];
        end
    endgenerate

    assign CARRY = grp_c[NUM_GROUPS];

endmodule