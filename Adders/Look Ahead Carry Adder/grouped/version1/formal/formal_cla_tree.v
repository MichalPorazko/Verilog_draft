module formal_cla_tree;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;

    (* anyconst *) reg [BIT_WIDTH-1:0] p;
    (* anyconst *) reg [BIT_WIDTH-1:0] g;
    (* anyconst *) reg                 cin;

    wire [BIT_WIDTH:0] carry;
    wire               P;
    wire               G;

    reg [BIT_WIDTH:0] carry_ref;
    reg               G_ref;
    integer           bit_index;

    cla_tree #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .g     (g),
        .p     (p),
        .cin   (cin),
        .carry (carry),
        .G     (G),
        .P     (P)
    );

    always @* begin
        carry_ref    = {(BIT_WIDTH + 1){1'b0}};
        carry_ref[0] = cin;
        G_ref        = 1'b0;

        for (bit_index = 0;
             bit_index < BIT_WIDTH;
             bit_index = bit_index + 1) begin
            carry_ref[bit_index + 1] =
                g[bit_index] |
                (p[bit_index] & carry_ref[bit_index]);

            G_ref = g[bit_index] | (p[bit_index] & G_ref);
        end

        assert(carry == carry_ref);
        assert(P == (&p));
        assert(G == G_ref);
    end

endmodule
