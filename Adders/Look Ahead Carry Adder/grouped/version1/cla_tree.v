module cla_tree #(
    parameter BIT_WIDTH = 64,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0] g, p,
    input  wire                 cin,
    output wire [BIT_WIDTH:0] carry,
    output wire G, P
);
    wire [BIT_WIDTH-1:0] sum;

    localparam NUM_GROUPS = BIT_WIDTH/GROUP_SIZE;
    wire [NUM_GROUPS-1:0] grp_G, grp_P;
    wire [NUM_GROUPS:0] grp_c;

    wire [NUM_GROUPS*(GROUP_SIZE+1)-1:0] local_c_flat;
    
    generate

        if ( BIT_WIDTH <= GROUP_SIZE) begin: leaf

            calc_carries #(BIT_WIDTH, GROUP_SIZE) carries (
                .p_in(p),
                .g_in(g),
                .cin(cin),
                .carries(carry),
                .P(P),
                .G(G)
            );

        end else begin: tree

            

            cla_tree#(NUM_GROUPS, GROUP_SIZE) tree (
                .p   (grp_P),
                .g   (grp_G),
                .cin (cin),
                .carry   (grp_C),
                .P   (P),
                .G   (G)
            );

            for (i = 0; i < NUM_GROUPS; i = i + 1) begin : gen_groups
                calc_carries #(
                    .WIDTH(GROUP_SIZE)
                ) u_chunk (
                    .p   (p[i*GROUP_SIZE +: GROUP_SIZE]),
                    .g   (g[i*GROUP_SIZE +: GROUP_SIZE]),
                    .cin (grp_C[i]),
                    .c   (local_c_flat[i*(GROUP_SIZE+1) +: (GROUP_SIZE+1)]),
                    .P   (grp_P[i]),
                    .G   (grp_G[i])
                );

                assign c[i*GROUP_SIZE + 1+: GROUP_SIZE] =
                    local_c_flat[i*(GROUP_SIZE+1) +: GROUP_SIZE];
            end

            carry[BIT_WIDTH] = grp_c[NUM_GROUPS];

        end
        
    endgenerate    

    


endmodule