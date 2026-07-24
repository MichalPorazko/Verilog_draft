module formal_calc_carries;

    parameter GROUP_SIZE = 4;

    (* anyconst *) reg [GROUP_SIZE-1:0] p_in;
    (* anyconst *) reg [GROUP_SIZE-1:0] g_in;
    (* anyconst *) reg                  cin;

    wire [GROUP_SIZE:0] carries;
    wire                P;
    wire                G;

    reg [GROUP_SIZE:0] carry_ref;
    reg                G_ref;
    integer            bit_index;

    calc_carries #(
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .p_in    (p_in),
        .g_in    (g_in),
        .cin     (cin),
        .carries (carries),
        .P       (P),
        .G       (G)
    );

    /*
     * The DUT uses expanded look-ahead equations. This reference is an
     * independent ripple recurrence derived directly from the carry law.
     */
    always @* begin
        carry_ref    = {(GROUP_SIZE + 1){1'b0}};
        carry_ref[0] = cin;
        G_ref        = 1'b0;

        for (bit_index = 0;
             bit_index < GROUP_SIZE;
             bit_index = bit_index + 1) begin
            carry_ref[bit_index + 1] =
                g_in[bit_index] |
                (p_in[bit_index] & carry_ref[bit_index]);

            G_ref =
                g_in[bit_index] |
                (p_in[bit_index] & G_ref);
        end

        assert(carries == carry_ref);
        assert(P == (&p_in));
        assert(G == G_ref);
    end

endmodule
