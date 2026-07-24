module cla_tree #(
    parameter BIT_WIDTH  = 64,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0] g,
    input  wire [BIT_WIDTH-1:0] p,
    input  wire                 cin,
    output wire [BIT_WIDTH:0]   carry,
    output wire                 G,
    output wire                 P
);

    /* Ceiling division keeps a final group that may be smaller than GROUP_SIZE. */
    localparam NUM_GROUPS = (BIT_WIDTH + GROUP_SIZE - 1) / GROUP_SIZE;

    genvar group_index;

    generate
        if (BIT_WIDTH <= GROUP_SIZE) begin : gen_leaf
            calc_carries #(
                .GROUP_SIZE(BIT_WIDTH)
            ) u_leaf (
                .p_in    (p),
                .g_in    (g),
                .cin     (cin),
                .carries (carry),
                .P       (P),
                .G       (G)
            );
        end else begin : gen_tree
            wire [NUM_GROUPS-1:0] group_G;
            wire [NUM_GROUPS-1:0] group_P;
            wire [NUM_GROUPS:0]   group_carry;

            /* The same look-ahead structure is recursively applied between groups. */
            cla_tree #(
                .BIT_WIDTH (NUM_GROUPS),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_group_tree (
                .g     (group_G),
                .p     (group_P),
                .cin   (cin),
                .carry (group_carry),
                .G     (G),
                .P     (P)
            );

            assign carry[0] = cin;

            for (group_index = 0;
                 group_index < NUM_GROUPS;
                 group_index = group_index + 1) begin : gen_group

                localparam LSB = group_index * GROUP_SIZE;
                localparam THIS_WIDTH =
                    ((LSB + GROUP_SIZE) <= BIT_WIDTH) ?
                    GROUP_SIZE : (BIT_WIDTH - LSB);

                wire [THIS_WIDTH:0] local_carry;

                calc_carries #(
                    .GROUP_SIZE(THIS_WIDTH)
                ) u_group (
                    .p_in    (p[LSB +: THIS_WIDTH]),
                    .g_in    (g[LSB +: THIS_WIDTH]),
                    .cin     (group_carry[group_index]),
                    .carries (local_carry),
                    .P       (group_P[group_index]),
                    .G       (group_G[group_index])
                );

                /* local_carry[0] is the already-known carry into this group. */
                assign carry[LSB + 1 +: THIS_WIDTH] =
                    local_carry[THIS_WIDTH:1];
            end
        end
    endgenerate

endmodule
