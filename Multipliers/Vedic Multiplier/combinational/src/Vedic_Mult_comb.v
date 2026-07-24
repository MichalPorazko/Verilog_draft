module Vedic_Mult_comb #(
    parameter BIT_WIDTH  = 16,
    parameter GROUP_SIZE = 4
)(
    input  wire [BIT_WIDTH-1:0]   a,
    input  wire [BIT_WIDTH-1:0]   b,
    output wire [2*BIT_WIDTH-1:0] out
);

    generate
        if (BIT_WIDTH == 1) begin : gen_one_bit
            assign out = {1'b0, (a[0] & b[0])};

        end else if (BIT_WIDTH == 2) begin : gen_two_bit
            vedic_mult_2bit u_base (
                .a   (a),
                .b   (b),
                .out (out)
            );

        end else if ((BIT_WIDTH % 2) == 0) begin : gen_even
            localparam HALF = BIT_WIDTH / 2;

            wire [BIT_WIDTH-1:0] p_ll;
            wire [BIT_WIDTH-1:0] p_lh;
            wire [BIT_WIDTH-1:0] p_hl;
            wire [BIT_WIDTH-1:0] p_hh;

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

            CLA #(
                .BIT_WIDTH (BIT_WIDTH),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_cross_adder (
                .a     (p_lh),
                .b     (p_hl),
                .cin   (1'b0),
                .sum   (cross_sum),
                .carry (cross_carry)
            );

            CLA #(
                .BIT_WIDTH (BIT_WIDTH),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_middle_adder (
                .a     (cross_sum),
                .b     ({p_hh[HALF-1:0], p_ll[BIT_WIDTH-1:HALF]}),
                .cin   (1'b0),
                .sum   (middle_sum),
                .carry (middle_carry)
            );

            /* Both carries belong at bit 3*HALF and therefore must be added. */
            assign upper_addend = cross_carry;

            CLA #(
                .BIT_WIDTH (HALF),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_upper_adder (
                .a     (p_hh[BIT_WIDTH-1:HALF]),
                .b     (upper_addend),
                .cin   (middle_carry),
                .sum   (upper_sum),
                .carry (upper_carry_unused)
            );

            assign out = {upper_sum, middle_sum, p_ll[HALF-1:0]};

        end else begin : gen_odd
            localparam EVEN_WIDTH = BIT_WIDTH - 1;

            wire [2*EVEN_WIDTH-1:0] lower_product;
            wire [EVEN_WIDTH-1:0]   cross_a;
            wire [EVEN_WIDTH-1:0]   cross_b;
            wire [EVEN_WIDTH-1:0]   cross_sum;
            wire                    cross_carry;
            wire [EVEN_WIDTH-1:0]   middle_sum;
            wire                    middle_carry;
            wire                    top_partial;
            wire                    top_sum;
            wire                    top_carry;

            Vedic_Mult_comb #(
                .BIT_WIDTH (EVEN_WIDTH),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_even_child (
                .a   (a[EVEN_WIDTH-1:0]),
                .b   (b[EVEN_WIDTH-1:0]),
                .out (lower_product)
            );

            assign cross_a = b[BIT_WIDTH-1] ?
                             a[EVEN_WIDTH-1:0] : {EVEN_WIDTH{1'b0}};
            assign cross_b = a[BIT_WIDTH-1] ?
                             b[EVEN_WIDTH-1:0] : {EVEN_WIDTH{1'b0}};

            CLA #(
                .BIT_WIDTH (EVEN_WIDTH),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_cross_adder (
                .a     (cross_a),
                .b     (cross_b),
                .cin   (1'b0),
                .sum   (cross_sum),
                .carry (cross_carry)
            );

            CLA #(
                .BIT_WIDTH (EVEN_WIDTH),
                .GROUP_SIZE(GROUP_SIZE)
            ) u_middle_adder (
                .a     (cross_sum),
                .b     (lower_product[2*EVEN_WIDTH-1:EVEN_WIDTH]),
                .cin   (1'b0),
                .sum   (middle_sum),
                .carry (middle_carry)
            );

            assign top_partial = a[BIT_WIDTH-1] & b[BIT_WIDTH-1];
            assign top_sum = top_partial ^ cross_carry ^ middle_carry;
            assign top_carry = (top_partial & cross_carry) |
                               (top_partial & middle_carry) |
                               (cross_carry & middle_carry);

            assign out = {
                top_carry,
                top_sum,
                middle_sum,
                lower_product[EVEN_WIDTH-1:0]
            };
        end
    endgenerate

endmodule
