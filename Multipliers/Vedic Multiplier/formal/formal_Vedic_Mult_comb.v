module formal_Vedic_Mult_comb;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;

    (* anyconst *) reg [BIT_WIDTH-1:0] a;
    (* anyconst *) reg [BIT_WIDTH-1:0] b;

    wire [2*BIT_WIDTH-1:0] out;
    wire [2*BIT_WIDTH-1:0] a_extended;
    wire [2*BIT_WIDTH-1:0] b_extended;
    wire [2*BIT_WIDTH-1:0] product_ref;

    Vedic_Mult_comb #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .a   (a),
        .b   (b),
        .out (out)
    );

    assign a_extended = {{BIT_WIDTH{1'b0}}, a};
    assign b_extended = {{BIT_WIDTH{1'b0}}, b};
    assign product_ref = a_extended * b_extended;

    always @* begin
        assert(out == product_ref);
    end

endmodule
