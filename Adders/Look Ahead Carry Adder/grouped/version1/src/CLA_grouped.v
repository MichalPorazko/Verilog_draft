module CLA #(
    parameter BIT_WIDTH  = 64,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0] a,
    input  wire [BIT_WIDTH-1:0] b,
    input  wire                 cin,
    output wire [BIT_WIDTH-1:0] sum,
    output wire                 carry
);

    wire [BIT_WIDTH-1:0] p;
    wire [BIT_WIDTH-1:0] g;
    wire [BIT_WIDTH:0]   carry_internal;
    wire                 group_G_unused;
    wire                 group_P_unused;

    assign p = a ^ b;
    assign g = a & b;

    cla_tree #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_tree (
        .g     (g),
        .p     (p),
        .cin   (cin),
        .carry (carry_internal),
        .G     (group_G_unused),
        .P     (group_P_unused)
    );

    assign sum   = p ^ carry_internal[BIT_WIDTH-1:0];
    assign carry = carry_internal[BIT_WIDTH];

endmodule

/* Backward-compatible name used by older multiplier drafts. */
module CLA_grouped #(
    parameter BIT_WIDTH  = 64,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0] a,
    input  wire [BIT_WIDTH-1:0] b,
    input  wire                 cin,
    output wire [BIT_WIDTH-1:0] sum,
    output wire                 carry
);

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_cla (
        .a     (a),
        .b     (b),
        .cin   (cin),
        .sum   (sum),
        .carry (carry)
    );

endmodule
