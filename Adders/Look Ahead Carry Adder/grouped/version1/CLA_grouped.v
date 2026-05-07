module CLA_grouped #(
    parameter BIT_WIDTH = 64,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0] a,
    input  wire [BIT_WIDTH-1:0] b,
    input  wire                 cin,
    output wire [BIT_WIDTH-1:0] sum,
    output wire                 carry
);
    wire [BIT_WIDTH:0] carry_internal;

    wire [BIT_WIDTH-1:0] g, p;
    wire G, P;

    assign p = a ^ b;
    assign g = a & b;

    cla_tree#(BIT_WIDTH, GROUP_SIZE) tree (
        .g(g),
        .p(p),
        .cin(Cin),
        .carry(carry_internal),
        .G(G),
        .P(P)
    );

    assign sum   = p ^ c[BIT_WIDTH-1:0];
    assign carry = c[BIT_WIDTH];       
    


endmodule