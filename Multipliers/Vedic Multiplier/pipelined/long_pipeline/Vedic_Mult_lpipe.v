module Vedic_Mult_lpipe #(
    parameter BIT_WIDTH  = 16,
    parameter GROUP_SIZE = 4
)(
    input  wire                   clk,
    input  wire                   reset,
    input  wire                   valid_i,
    input  wire [BIT_WIDTH-1:0]   a,
    input  wire [BIT_WIDTH-1:0]   b,
    output reg                    valid_o,
    output reg  [2*BIT_WIDTH-1:0] out
);

    /* This wrapper is intentionally restricted to even BIT_WIDTH >= 2. */
    localparam HALF = BIT_WIDTH / 2;

    wire [BIT_WIDTH-1:0] p_ll;
    wire [BIT_WIDTH-1:0] p_lh;
    wire [BIT_WIDTH-1:0] p_hl;
    wire [BIT_WIDTH-1:0] p_hh;

    /* Stage 1: registered partial products. */
    reg [BIT_WIDTH-1:0] p_ll_s1;
    reg [BIT_WIDTH-1:0] p_lh_s1;
    reg [BIT_WIDTH-1:0] p_hl_s1;
    reg [BIT_WIDTH-1:0] p_hh_s1;
    reg                 valid_s1;

    wire [BIT_WIDTH-1:0] cross_sum_s1;
    wire                 cross_carry_s1;

    /* Stage 2: registered cross sum and aligned partial products. */
    reg [BIT_WIDTH-1:0] cross_sum_s2;
    reg                 cross_carry_s2;
    reg [BIT_WIDTH-1:0] p_ll_s2;
    reg [BIT_WIDTH-1:0] p_hh_s2;
    reg                 valid_s2;

    wire [BIT_WIDTH-1:0] middle_sum_s2;
    wire                 middle_carry_s2;

    /* Stage 3: registered middle sum and operands for the upper adder. */
    reg [BIT_WIDTH-1:0] middle_sum_s3;
    reg [HALF-1:0]      p_ll_low_s3;
    reg [HALF-1:0]      p_hh_high_s3;
    reg                 cross_carry_s3;
    reg                 middle_carry_s3;
    reg                 valid_s3;

    wire [HALF-1:0] upper_addend_s3;
    wire [HALF-1:0] upper_sum_s3;
    wire            upper_carry_unused;

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

    always @(posedge clk) begin
        if (!reset) begin
            p_ll_s1  <= {BIT_WIDTH{1'b0}};
            p_lh_s1  <= {BIT_WIDTH{1'b0}};
            p_hl_s1  <= {BIT_WIDTH{1'b0}};
            p_hh_s1  <= {BIT_WIDTH{1'b0}};
            valid_s1 <= 1'b0;
        end else begin
            valid_s1 <= valid_i;

            if (valid_i) begin
                p_ll_s1 <= p_ll;
                p_lh_s1 <= p_lh;
                p_hl_s1 <= p_hl;
                p_hh_s1 <= p_hh;
            end
        end
    end

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_cross_adder (
        .a     (p_lh_s1),
        .b     (p_hl_s1),
        .cin   (1'b0),
        .sum   (cross_sum_s1),
        .carry (cross_carry_s1)
    );

    always @(posedge clk) begin
        if (!reset) begin
            cross_sum_s2   <= {BIT_WIDTH{1'b0}};
            cross_carry_s2 <= 1'b0;
            p_ll_s2        <= {BIT_WIDTH{1'b0}};
            p_hh_s2        <= {BIT_WIDTH{1'b0}};
            valid_s2       <= 1'b0;
        end else begin
            valid_s2 <= valid_s1;

            if (valid_s1) begin
                cross_sum_s2   <= cross_sum_s1;
                cross_carry_s2 <= cross_carry_s1;
                p_ll_s2        <= p_ll_s1;
                p_hh_s2        <= p_hh_s1;
            end
        end
    end

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_middle_adder (
        .a     (cross_sum_s2),
        .b     ({p_hh_s2[HALF-1:0], p_ll_s2[BIT_WIDTH-1:HALF]}),
        .cin   (1'b0),
        .sum   (middle_sum_s2),
        .carry (middle_carry_s2)
    );

    always @(posedge clk) begin
        if (!reset) begin
            middle_sum_s3    <= {BIT_WIDTH{1'b0}};
            p_ll_low_s3       <= {HALF{1'b0}};
            p_hh_high_s3      <= {HALF{1'b0}};
            cross_carry_s3    <= 1'b0;
            middle_carry_s3   <= 1'b0;
            valid_s3          <= 1'b0;
        end else begin
            valid_s3 <= valid_s2;

            if (valid_s2) begin
                middle_sum_s3  <= middle_sum_s2;
                p_ll_low_s3     <= p_ll_s2[HALF-1:0];
                p_hh_high_s3    <= p_hh_s2[BIT_WIDTH-1:HALF];
                cross_carry_s3  <= cross_carry_s2;
                middle_carry_s3 <= middle_carry_s2;
            end
        end
    end

    assign upper_addend_s3 = cross_carry_s3;

    CLA #(
        .BIT_WIDTH (HALF),
        .GROUP_SIZE(GROUP_SIZE)
    ) u_upper_adder (
        .a     (p_hh_high_s3),
        .b     (upper_addend_s3),
        .cin   (middle_carry_s3),
        .sum   (upper_sum_s3),
        .carry (upper_carry_unused)
    );

    /* Stage 4: register the complete product and the matching valid bit. */
    always @(posedge clk) begin
        if (!reset) begin
            out     <= {(2*BIT_WIDTH){1'b0}};
            valid_o <= 1'b0;
        end else begin
            valid_o <= valid_s3;

            if (valid_s3) begin
                out <= {upper_sum_s3, middle_sum_s3, p_ll_low_s3};
            end
        end
    end

endmodule
