// vedic_formula_scratch.v

module vedic_formula_scratch;

    parameter A_WIDTH = 6;
    parameter B_WIDTH = 5;

    parameter A_LO = 3;
    parameter A_HI = A_WIDTH - A_LO;

    parameter B_LO = 2;
    parameter B_HI = B_WIDTH - B_LO;

    parameter OUT_WIDTH = A_WIDTH + B_WIDTH;

    reg [A_WIDTH-1:0] a;
    reg [B_WIDTH-1:0] b;

    wire [A_LO-1:0] a_lo;
    wire [A_HI-1:0] a_hi;

    wire [B_LO-1:0] b_lo;
    wire [B_HI-1:0] b_hi;

    wire [A_LO+B_LO-1:0] p_ll;
    wire [A_LO+B_HI-1:0] p_lh;
    wire [A_HI+B_LO-1:0] p_hl;
    wire [A_HI+B_HI-1:0] p_hh;

    wire [OUT_WIDTH-1:0] pp_ll;
    wire [OUT_WIDTH-1:0] pp_lh;
    wire [OUT_WIDTH-1:0] pp_hl;
    wire [OUT_WIDTH-1:0] pp_hh;

    wire [OUT_WIDTH-1:0] decomposed_product;
    wire [OUT_WIDTH-1:0] direct_product;

    assign a_lo = a[A_LO-1:0];
    assign a_hi = a[A_WIDTH-1:A_LO];

    assign b_lo = b[B_LO-1:0];
    assign b_hi = b[B_WIDTH-1:B_LO];

    assign p_ll = a_lo * b_lo;
    assign p_lh = a_lo * b_hi;
    assign p_hl = a_hi * b_lo;
    assign p_hh = a_hi * b_hi;

    assign pp_ll = {{(OUT_WIDTH-(A_LO+B_LO)){1'b0}}, p_ll};

    assign pp_lh = ({{(OUT_WIDTH-(A_LO+B_HI)){1'b0}}, p_lh}) << B_LO;

    assign pp_hl = ({{(OUT_WIDTH-(A_HI+B_LO)){1'b0}}, p_hl}) << A_LO;

    assign pp_hh = ({{(OUT_WIDTH-(A_HI+B_HI)){1'b0}}, p_hh}) << (A_LO + B_LO);

    assign decomposed_product = pp_ll + pp_lh + pp_hl + pp_hh;

    assign direct_product = a * b;

    initial begin
        a = 6'b101101;   // 45
        b = 5'b11011;    // 27

        #1;

        $display("a                  = %b = %0d", a, a);
        $display("b                  = %b = %0d", b, b);
        $display("");

        $display("a_lo               = %b = %0d", a_lo, a_lo);
        $display("a_hi               = %b = %0d", a_hi, a_hi);
        $display("b_lo               = %b = %0d", b_lo, b_lo);
        $display("b_hi               = %b = %0d", b_hi, b_hi);
        $display("");

        $display("p_ll = a_lo*b_lo   = %b = %0d", p_ll, p_ll);
        $display("p_lh = a_lo*b_hi   = %b = %0d", p_lh, p_lh);
        $display("p_hl = a_hi*b_lo   = %b = %0d", p_hl, p_hl);
        $display("p_hh = a_hi*b_hi   = %b = %0d", p_hh, p_hh);
        $display("");

        $display("pp_ll              = %b = %0d", pp_ll, pp_ll);
        $display("pp_lh              = %b = %0d", pp_lh, pp_lh);
        $display("pp_hl              = %b = %0d", pp_hl, pp_hl);
        $display("pp_hh              = %b = %0d", pp_hh, pp_hh);
        $display("");

        $display("decomposed product = %b = %0d", decomposed_product, decomposed_product);
        $display("direct product     = %b = %0d", direct_product, direct_product);

        if (decomposed_product == direct_product)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end

endmodule