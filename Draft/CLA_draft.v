module CLA #(parameter BIT_WIDTH) (
    input Cin,
    input [BIT_WIDTH-1:0] A, B,
    output [BIT_WIDTH-1:0] SUM,
    output CARRY
);

    wire [BIT_WIDTH:0] g, p;
    wire [BIT_WIDTH:0] c_x;
    reg [BIT_WIDTH:0] c_temp;

    assign c_x[0] = Cin;
    $display("CLA: c_x[0] assigned to Cin: %b", Cin);

    for (int i = 0; i < BIT_WIDTH; i = i + 1) begin
        assign g[i] = A[i] & B[i];
        $display("CLA: g[%d] assigned to A[%d] & B[%d]: %b", i, i, i, g[i]);

        assign p[i] = A[i] ^ B[i];
        $display("CLA: p[%d] assigned to A[%d] ^ B[%d]: %b", i, i, i, p[i]);

        reg temp0 = c_x[0];
        $display("CLA: temp0 initialized to c_x[0]: %b", temp0);

        reg temp = 1;
        $display("CLA: temp initialized to 1");

        for (int j = i + 1; j <= BIT_WIDTH; j = j + 1) begin
            temp = temp & p[j];
            $display("CLA: temp updated to temp & p[%d]: %b", j, temp);
        end

        c_temp[BIT_WIDTH] = c_temp[BIT_WIDTH] + (temp & g[i]);
        $display("CLA: c_temp[%d] updated to c_temp[%d] + (temp & g[%d]): %b", BIT_WIDTH, BIT_WIDTH, i, c_temp[BIT_WIDTH]);
    end

    assign c_x[BIT_WIDTH] = c_temp[BIT_WIDTH] + temp0;
    $display("CLA: c_x[%d] assigned to c_temp[%d] + temp0: %b", BIT_WIDTH, BIT_WIDTH, c_x[BIT_WIDTH]);

endmodule


module cla_flat_carry_into #(
    parameter int BIT_WIDTH = 8
) (
    input  logic [BIT_WIDTH-1:0] A,
    input  logic [BIT_WIDTH-1:0] B,
    input  logic                 Cin,
    output logic [BIT_WIDTH-1:0] SUM,
    output logic                 CARRY
);

    logic [BIT_WIDTH-1:0] g, p;

    assign g = A & B;
    $display("cla_flat_carry_into: g assigned to A & B: %b", g);

    assign p = A ^ B;
    $display("cla_flat_carry_into: p assigned to A ^ B: %b", p);

    function automatic logic carry_into (
        input int idx,
        input logic [BIT_WIDTH-1:0] g_in,
        input logic [BIT_WIDTH-1:0] p_in,
        input logic                 cin_in
    );
        logic acc, prefix;
        begin
            if (idx == 0) begin
                carry_into = cin_in;
                $display("carry_into: idx == 0, carry_into assigned to cin_in: %b", carry_into);
            end
            else begin
                acc = g_in[idx-1];
                $display("carry_into: acc initialized to g_in[%d]: %b", idx-1, acc);

                prefix = p_in[idx-1];
                $display("carry_into: prefix initialized to p_in[%d]: %b", idx-1, prefix);

                for (int j = idx-2; j >= 0; j = j - 1) begin
                    acc = acc | (prefix & g_in[j]);
                    $display("carry_into: acc updated to acc | (prefix & g_in[%d]): %b", j, acc);

                    prefix = prefix & p_in[j];
                    $display("carry_into: prefix updated to prefix & p_in[%d]: %b", j, prefix);
                end

                carry_into = acc | (prefix & cin_in);
                $display("carry_into: carry_into result: %b", carry_into);
            end
        end
    endfunction

    genvar i;
    generate
        for (i = 0; i < BIT_WIDTH; i = i + 1) begin : gen_sum
            assign SUM[i] = p[i] ^ carry_into(i, g, p, Cin);
            $display("gen_sum: SUM[%d] assigned to p[%d] ^ carry_into(%d, g, p, Cin): %b", i, i, i, SUM[i]);
        end
    endgenerate

    assign CARRY = carry_into(BIT_WIDTH, g, p, Cin);
    $display("cla_flat_carry_into: CARRY assigned to carry_into(%d, g, p, Cin): %b", BIT_WIDTH, CARRY);

endmodule


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

    // Optional design rule check
    initial begin
        if (BIT_WIDTH % GROUP_SIZE != 0)
            $error("BIT_WIDTH must be divisible by GROUP_SIZE");
    end

    // Group propagate = AND of all p bits in the group
    function automatic logic calc_group_p (
        input int grp,
        input logic [BIT_WIDTH-1:0] p_in
    );
        logic acc;
        int lo, hi;
        begin
            lo = grp * GROUP_SIZE;
            hi = lo + GROUP_SIZE - 1;

            acc = 1'b1;
            for (int b = lo; b <= hi; b++) begin
                acc = acc & p_in[b];
            end

            calc_group_p = acc;
        end
    endfunction

    // Group generate =
    // g[hi] | p[hi]g[hi-1] | p[hi]p[hi-1]g[hi-2] | ...
    function automatic logic calc_group_g (
        input int grp,
        input logic [BIT_WIDTH-1:0] g_in,
        input logic [BIT_WIDTH-1:0] p_in
    );
        logic acc, prefix;
        int lo, hi;
        begin
            lo = grp * GROUP_SIZE;
            hi = lo + GROUP_SIZE - 1;

            acc    = g_in[hi];
            prefix = p_in[hi];

            for (int b = hi-1; b >= lo; b--) begin
                acc    = acc | (prefix & g_in[b]);
                prefix = prefix & p_in[b];
            end

            calc_group_g = acc;
        end
    endfunction

    // Carry out of group grp
    // grp_c[grp+1] = GG[grp] | GP[grp]GG[grp-1] | ... | GP...GP[0]Cin
    function automatic logic calc_group_carry (
        input int grp,
        input logic [NUM_GROUPS-1:0] gg_in,
        input logic [NUM_GROUPS-1:0] gp_in,
        input logic                  cin_in
    );
        logic acc, prefix;
        begin
            acc    = gg_in[grp];
            prefix = gp_in[grp];

            for (int k = grp-1; k >= 0; k--) begin
                acc    = acc | (prefix & gg_in[k]);
                prefix = prefix & gp_in[k];
            end

            calc_group_carry = acc | (prefix & cin_in);
        end
    endfunction

    // Carry into a specific bit inside its group
    function automatic logic calc_bit_carry (
        input int bit_idx,
        input logic [BIT_WIDTH-1:0] g_in,
        input logic [BIT_WIDTH-1:0] p_in,
        input logic                 group_cin
    );
        logic acc, prefix;
        int lo;
        begin
            lo = (bit_idx / GROUP_SIZE) * GROUP_SIZE;

            if (bit_idx == lo) begin
                calc_bit_carry = group_cin;
            end
            else begin
                acc    = g_in[bit_idx-1];
                prefix = p_in[bit_idx-1];

                for (int b = bit_idx-2; b >= lo; b--) begin
                    acc    = acc | (prefix & g_in[b]);
                    prefix = prefix & p_in[b];
                end

                calc_bit_carry = acc | (prefix & group_cin);
            end
        end
    endfunction

    genvar gi;
    generate
        for (gi = 0; gi < NUM_GROUPS; gi++) begin : gen_groups
            assign grp_p[gi]   = calc_group_p(gi, p);
            assign grp_g[gi]   = calc_group_g(gi, g, p);
            assign grp_c[gi+1] = calc_group_carry(gi, grp_g, grp_p, Cin);
        end
    endgenerate

    genvar bi;
    generate
        for (bi = 0; bi < BIT_WIDTH; bi++) begin : gen_bits
            assign bit_c[bi] = calc_bit_carry(bi, g, p, grp_c[bi / GROUP_SIZE]);
            assign SUM[bi]   = p[bi] ^ bit_c[bi];
        end
    endgenerate

    assign CARRY = grp_c[NUM_GROUPS];

endmodule

module  calc_group_g #(
    parameter BIT_WIDTH = 4
)(
        input  wire [31:0]          grp,
        input  wire                 Cin,
        input logic [BIT_WIDTH-1:0] g_in,
        input logic [BIT_WIDTH-1:0] p_in,
        output wire [:] grp_p,
        output wire [;] grp_g
    );
        logic acc, prefix;
        int lo, hi;
        begin
            lo = grp * GROUP_SIZE;
            hi = lo + GROUP_SIZE - 1;

            acc    = g_in[hi];
            prefix = p_in[hi];

            for (int b = hi-1; b >= lo; b--) begin
                acc    = acc | (prefix & g_in[b]);
                prefix = prefix & p_in[b];
            end

            calc_group_g = acc;
        end
endmodule

module calc_group_p #(
    parameter BIT_WIDTH = 64,
    parameter GROUP_SIZE = 4
) (
        input  wire [31:0]          grp,
        input logic [BIT_WIDTH-1:0] p_in
    );
        wire prefix;
        int lo, hi;
        begin
            lo = grp * GROUP_SIZE;
            hi = lo + GROUP_SIZE - 1;

            prefix = 1'b1;
            for (int b = lo; b <= hi; b++) begin
                prefix = prefix & p_in[b];
            end

            calc_group_p = prefix;
        end
endmodule


module cla_generic #(
    parameter BIT_WIDTH  = 64,
    parameter GROUP_SIZE = 4
) (
    input  wire [BIT_WIDTH-1:0] A,
    input  wire [BIT_WIDTH-1:0] B,
    input  wire                 Cin,
    output wire [BIT_WIDTH-1:0] SUM,
    output wire                 CARRY
);

    wire [BIT_WIDTH-1:0] p;
    wire [BIT_WIDTH-1:0] g;
    wire [BIT_WIDTH:0]   c;

    wire P_unused;
    wire G_unused;

    assign p = A ^ B;
    assign g = A & B;

    cla_tree #(
        .WIDTH(BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_tree (
        .p   (p),
        .g   (g),
        .cin (Cin),
        .c   (c),
        .P   (P_unused),
        .G   (G_unused)
    );

    assign SUM   = p ^ c[BIT_WIDTH-1:0];
    assign CARRY = c[BIT_WIDTH];

endmodule


module cla_tree #(
    parameter WIDTH      = 64,
    parameter GROUP_SIZE = 4
) (
    input  wire [WIDTH-1:0] p,
    input  wire [WIDTH-1:0] g,
    input  wire             cin,
    output wire [WIDTH:0]   c,
    output wire             P,
    output wire             G
);

    generate
        // ------------------------------------------------------------
        // Leaf: directly compute carries for up to GROUP_SIZE bits
        // ------------------------------------------------------------
        if (WIDTH <= GROUP_SIZE) begin : gen_leaf

            function [WIDTH:0] calc_carries;
                input [WIDTH-1:0] p_in;
                input [WIDTH-1:0] g_in;
                input             cin_in;

                integer i, j;
                reg acc;
                reg prefix;

                begin
                    calc_carries[0] = cin_in;

                    for (i = 0; i < WIDTH; i = i + 1) begin
                        acc    = g_in[i];
                        prefix = p_in[i];

                        for (j = i - 1; j >= 0; j = j - 1) begin
                            acc    = acc | (prefix & g_in[j]);
                            prefix = prefix & p_in[j];
                        end

                        calc_carries[i+1] = acc | (prefix & cin_in);
                    end
                end
            endfunction

            function calc_group_generate;
                input [WIDTH-1:0] p_in;
                input [WIDTH-1:0] g_in;
                reg   [WIDTH:0] tmp;
                begin
                    tmp = calc_carries(p_in, g_in, 1'b0);
                    calc_group_generate = tmp[WIDTH];
                end
            endfunction

            wire [WIDTH:0] c_leaf;

            assign c_leaf = calc_carries(p, g, cin);

            assign c = c_leaf;
            assign P = &p;
            assign G = calc_group_generate(p, g);

        end else begin : gen_node
            // ------------------------------------------------------------
            // Recursive case:
            // 1) compute P/G for each GROUP_SIZE-bit chunk
            // 2) recursively compute carry into each chunk
            // 3) recursively compute internal carries inside each chunk
            // ------------------------------------------------------------
            localparam NUM_GROUPS = WIDTH / GROUP_SIZE;

            wire [NUM_GROUPS-1:0] grp_P;
            wire [NUM_GROUPS-1:0] grp_G;
            wire [NUM_GROUPS:0]   grp_C;

            // Flattened local carry vectors:
            // each child chunk returns GROUP_SIZE+1 carry bits
            wire [NUM_GROUPS*(GROUP_SIZE+1)-1:0] local_c_flat;

            genvar i;

            // Compute carries between groups, and also overall P/G
            cla_tree #(
                .WIDTH(NUM_GROUPS),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_group_tree (
                .p   (grp_P),
                .g   (grp_G),
                .cin (cin),
                .c   (grp_C),
                .P   (P),
                .G   (G)
            );

            // Each GROUP_SIZE chunk is itself solved by the same tree
            for (i = 0; i < NUM_GROUPS; i = i + 1) begin : gen_groups
                cla_tree #(
                    .WIDTH(GROUP_SIZE),
                    .GROUP_SIZE(GROUP_SIZE)
                ) u_chunk (
                    .p   (p[i*GROUP_SIZE +: GROUP_SIZE]),
                    .g   (g[i*GROUP_SIZE +: GROUP_SIZE]),
                    .cin (grp_C[i]),
                    .c   (local_c_flat[i*(GROUP_SIZE+1) +: (GROUP_SIZE+1)]),
                    .P   (grp_P[i]),
                    .G   (grp_G[i])
                );

                // Copy local carries into the global carry vector.
                // We copy only GROUP_SIZE entries from each chunk:
                // c[group_base + 0] .. c[group_base + GROUP_SIZE-1]
                // The final c[WIDTH] is assigned once below.
                assign c[i*GROUP_SIZE +: GROUP_SIZE] =
                    local_c_flat[i*(GROUP_SIZE+1) +: GROUP_SIZE];
            end

            assign c[WIDTH] = grp_C[NUM_GROUPS];

        end
    endgenerate

endmodule