module Vedic_Mult_spipe #(
    parameter BIT_WIDTH  = 16,
    parameter GROUP_SIZE = 4
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     valid_i,
    input  wire [BIT_WIDTH-1:0]     a,
    input  wire [BIT_WIDTH-1:0]     b,
    output reg                      valid_o,
    output wire [2*BIT_WIDTH-1:0]   out
);

    /* This wrapper is intentionally restricted to even BIT_WIDTH >= 2. */
    localparam HALF = BIT_WIDTH / 2;

    wire [BIT_WIDTH-1:0] p_ll;
    wire [BIT_WIDTH-1:0] p_lh;
    wire [BIT_WIDTH-1:0] p_hl;
    wire [BIT_WIDTH-1:0] p_hh;

    reg [BIT_WIDTH-1:0] p_ll_r;
    reg [BIT_WIDTH-1:0] p_lh_r;
    reg [BIT_WIDTH-1:0] p_hl_r;
    reg [BIT_WIDTH-1:0] p_hh_r;

    wire [BIT_WIDTH-1:0] cross_sum;
    wire                 cross_carry;
    wire [BIT_WIDTH-1:0] middle_sum;
    wire                 middle_carry;
    wire [HALF-1:0]      upper_addend;
    wire [HALF-1:0]      upper_sum;
    wire                 upper_carry_unused;

    Vedic_Mult_comb #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_ll (
        .a   (a[HALF-1:0]),
        .b   (b[HALF-1:0]),
        .out (p_ll)
    );

    Vedic_Mult_comb #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_lh (
        .a   (a[HALF-1:0]),
        .b   (b[BIT_WIDTH-1:HALF]),
        .out (p_lh)
    );

    Vedic_Mult_comb #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_hl (
        .a   (a[BIT_WIDTH-1:HALF]),
        .b   (b[HALF-1:0]),
        .out (p_hl)
    );

    Vedic_Mult_comb #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_hh (
        .a   (a[BIT_WIDTH-1:HALF]),
        .b   (b[BIT_WIDTH-1:HALF]),
        .out (p_hh)
    );

    /* One pipeline register bank after the four internal multipliers. */
    always @(posedge clk) begin
        if (!reset) begin
            p_ll_r  <= {BIT_WIDTH{1'b0}};
            p_lh_r  <= {BIT_WIDTH{1'b0}};
            p_hl_r  <= {BIT_WIDTH{1'b0}};
            p_hh_r  <= {BIT_WIDTH{1'b0}};
            valid_o <= 1'b0;
        end else begin
            valid_o <= valid_i;

            if (valid_i) begin
                p_ll_r <= p_ll;
                p_lh_r <= p_lh;
                p_hl_r <= p_hl;
                p_hh_r <= p_hh;
            end
        end
    end

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_cross_adder (
        .a     (p_lh_r),
        .b     (p_hl_r),
        .cin   (1'b0),
        .sum   (cross_sum),
        .carry (cross_carry)
    );

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_middle_adder (
        .a     (cross_sum),
        .b     ({p_hh_r[HALF-1:0], p_ll_r[BIT_WIDTH-1:HALF]}),
        .cin   (1'b0),
        .sum   (middle_sum),
        .carry (middle_carry)
    );

    assign upper_addend = cross_carry;

    CLA #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_upper_adder (
        .a     (p_hh_r[BIT_WIDTH-1:HALF]),
        .b     (upper_addend),
        .cin   (middle_carry),
        .sum   (upper_sum),
        .carry (upper_carry_unused)
    );

    /* Combinational output from the registered partial products: one-cycle latency. */
    assign out = {upper_sum, middle_sum, p_ll_r[HALF-1:0]};

endmodule
